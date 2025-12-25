import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'one_year_result_screen.dart';

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final String newText = newValue.text.replaceAll(',', '');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(newText)) return oldValue;
    final String formatted = _formatNumber(newText);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(String number) {
    if (number.isEmpty) return '';
    final parts = number.split('.');
    String integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '$integerPart.${parts[1]}' : integerPart;
  }
}

class OneYearTradingScreen extends StatefulWidget {
  const OneYearTradingScreen({super.key});

  @override
  State<OneYearTradingScreen> createState() => _OneYearTradingScreenState();
}

class _OneYearTradingScreenState extends State<OneYearTradingScreen> {
  final _formKey = GlobalKey<FormState>();


  final TextEditingController _salesController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _cashInHandController = TextEditingController();
  final TextEditingController _cashInBankController = TextEditingController();
  final TextEditingController _landController = TextEditingController();

  bool _isLoading = false;


  final Color _primary = const Color(0xFF1A237E);
  final Color _background = const Color(0xFFF8FAFC);
  final Color _cardColor = Colors.white;
  final Color _text = const Color(0xFF1E293B);
  final Color _hint = const Color(0xFF64748B);

  static const String _apiUrl = 'https://loan-approval-api-faur.onrender.com/api/v1/trade/one-year';

  Future<void> _fetchOneYearTrading() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {

      final Map<String, dynamic> requestBody = {
        'sales': double.tryParse(_salesController.text.replaceAll(',', '')) ?? 0,
        'commissionReceived': double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 0,
        'cashInHand': double.tryParse(_cashInHandController.text.replaceAll(',', '')) ?? 0,
        'cashInBank': double.tryParse(_cashInBankController.text.replaceAll(',', '')) ?? 0,
        'landAndBuilding': double.tryParse(_landController.text.replaceAll(',', '')) ?? 0,
      };

      print('API Request: $requestBody');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('API Response Received Successfully');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OneYearResultScreen(resultData: data),
          ),
        );
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _salesController.dispose();
    _commissionController.dispose();
    _cashInHandController.dispose();
    _cashInBankController.dispose();
    _landController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          "Financial Projection",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white, // 👈 text white
          ),
        ),
        centerTitle: true,
        backgroundColor: _primary, // 👈 0xFF1A237E
        foregroundColor: Colors.white,
        elevation: 1,
      ),

      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insights, color: _primary, size: 24),
                            const SizedBox(width: 12),
                            const Text(
                              "3-Year Financial Projection",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter 5 key financial inputs to generate detailed 3-year projections",
                          style: TextStyle(
                            fontSize: 13,
                            color: _hint,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  _buildInputSection(
                    title: "Revenue",
                    children: [
                      _buildInputField(
                        label: "Total Sales",
                        controller: _salesController,
                        icon: Icons.shopping_cart,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Commission Received",
                        controller: _commissionController,
                        icon: Icons.request_page,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildInputSection(
                    title: "Assets",
                    children: [
                      _buildInputField(
                        label: "Cash in Hand",
                        controller: _cashInHandController,
                        icon: Icons.wallet,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Cash in Bank",
                        controller: _cashInBankController,
                        icon: Icons.account_balance,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Land & Building",
                        controller: _landController,
                        icon: Icons.home_work,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fetchOneYearTrading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Generate 3-Year Report",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Generating financial projections...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _text,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _text,
              ),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandSeparatorInputFormatter()],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _text,
          ),
          decoration: InputDecoration(
            hintText: "Enter amount",
            hintStyle: TextStyle(color: _hint, fontSize: 14),
            prefixIcon: Icon(icon, color: _primary, size: 20),
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _primary,
            ),
            filled: true,
            fillColor: _background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _hint.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _hint.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primary, width: 1.5),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return "Required field";
            }
            final cleaned = value?.replaceAll(',', '') ?? '';
            if (cleaned.isNotEmpty && (double.tryParse(cleaned) == null || double.parse(cleaned) < 0)) {
              return "Invalid amount";
            }
            return null;
          },
        ),
      ],
    );
  }
}