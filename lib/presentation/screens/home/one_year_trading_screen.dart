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

  // Premium color palette
  final Color _primary = const Color(0xFF1A2C3E);   // deep slate
  final Color _accent = const Color(0xFFC9A227);    // gold accent
  final Color _backgroundStart = const Color(0xFFFFFFFF);
  final Color _backgroundEnd = const Color(0xFFF0F4F8);
  final Color _cardColor = Colors.white;
  final Color _text = const Color(0xFF1E293B);
  final Color _hint = const Color(0xFF64748B);

  static const String _apiUrl = 'https://loan.edugaondev.com/api/v1/trade/one-year';

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

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OneYearResultScreen(resultData: data),
            ),
          );
        }
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Financial Projection",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundStart, _backgroundEnd],
            stops: const [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                            spreadRadius: -2,
                          ),
                        ],
                        border: Border.all(
                          color: _accent.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_accent.withOpacity(0.15), _accent.withOpacity(0.05)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(Icons.insights, color: _accent, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "3-Year Financial Projection",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Enter 5 key inputs to generate detailed projections",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _hint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Revenue Section
                    _buildInputSection(
                      title: "Revenue",
                      icon: Icons.currency_rupee,
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
                    const SizedBox(height: 24),

                    // Assets Section
                    _buildInputSection(
                      title: "Assets",
                      icon: Icons.account_balance_wallet,
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
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fetchOneYearTrading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: _primary.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isLoading ? Icons.hourglass_empty : Icons.analytics, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _isLoading ? "Generating..." : "Generate 3-Year Report",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A2C3E)),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Generating financial projections...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _text,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(children: children),
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
                fontWeight: FontWeight.w600,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
            if (isRequired)
              Text(
                " *",
                style: TextStyle(color: Colors.red.shade600, fontSize: 14),
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
            hintStyle: TextStyle(color: _hint.withOpacity(0.6), fontSize: 14),
            prefixIcon: Icon(icon, color: _accent, size: 20),
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFD),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _hint.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _hint.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
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