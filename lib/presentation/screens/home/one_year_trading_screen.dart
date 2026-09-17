import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:loanready_app/providers/one_year_trading_provider.dart';
import 'one_year_result_screen.dart';

// ─────────────────────────────────────────────
//  Thousand-separator formatter
// ─────────────────────────────────────────────
class ThousandSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
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

// ─────────────────────────────────────────────
//  INPUT SCREEN
// ─────────────────────────────────────────────
class OneYearTradingScreen extends StatefulWidget {
  const OneYearTradingScreen({super.key});

  @override
  State<OneYearTradingScreen> createState() => _OneYearTradingScreenState();
}

class _OneYearTradingScreenState extends State<OneYearTradingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _salesController = TextEditingController();
  final _commissionController = TextEditingController();
  final _cashInHandController = TextEditingController();
  final _cashInBankController = TextEditingController();
  final _landController = TextEditingController();

  static const Color _primary = Color(0xFF1A2C3E);
  static const Color _accent = Color(0xFFC9A227);
  static const Color _backgroundStart = Color(0xFFFFFFFF);
  static const Color _backgroundEnd = Color(0xFFF0F4F8);
  static const Color _cardColor = Colors.white;
  static const Color _text = Color(0xFF1E293B);
  static const Color _hint = Color(0xFF64748B);

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '')) ?? 0.0;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<OneYearTradingProvider>();

    final result = await provider.generateReport(
      sales: _parse(_salesController),
      commissionReceived: _parse(_commissionController),
      cashInHand: _parse(_cashInHandController),
      cashInBank: _parse(_cashInBankController),
      landAndBuilding: _parse(_landController),
    );

    if (!mounted) return;

    if (result != null) {
      final shouldClear = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => OneYearResultScreen(resultData: result),
        ),
      );

      // Back aaya aur clear chahiye
      if (shouldClear == true && mounted) {
        _clearForm();
      }
    }
    else if (provider.errorMessage != null) {
      _showMessage(provider.errorMessage!);
    }
  }

  void _clearForm() {
    _salesController.clear();
    _commissionController.clear();
    _cashInHandController.clear();
    _cashInBankController.clear();
    _landController.clear();
    _formKey.currentState?.reset();
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
          'Financial Projection',
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundStart, _backgroundEnd],
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
                        border: Border.all(color: _accent.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _accent.withOpacity(0.15),
                                  _accent.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.insights,
                              color: _accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3-Year Financial Projection',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Enter 5 key inputs to generate detailed projections',
                                  style: TextStyle(fontSize: 13, color: _hint),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildSection(
                      title: 'Revenue',
                      icon: Icons.currency_rupee,
                      children: [
                        _buildField(
                          label: 'Total Sales',
                          controller: _salesController,
                          icon: Icons.shopping_cart,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Commission Received',
                          controller: _commissionController,
                          icon: Icons.request_page,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSection(
                      title: 'Assets',
                      icon: Icons.account_balance_wallet,
                      children: [
                        _buildField(
                          label: 'Cash in Hand',
                          controller: _cashInHandController,
                          icon: Icons.wallet,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Cash in Bank',
                          controller: _cashInBankController,
                          icon: Icons.account_balance,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Land & Building',
                          controller: _landController,
                          icon: Icons.home_work,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Generate Button
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Consumer<OneYearTradingProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed: provider.isLoading ? null : _generate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Generate 3-Year Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
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
                style: const TextStyle(
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

  Widget _buildField({
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _text,
                letterSpacing: -0.2,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: Colors.red.shade600, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandSeparatorInputFormatter()],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _text,
          ),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            hintStyle: TextStyle(color: _hint.withOpacity(0.6), fontSize: 14),
            prefixIcon: Icon(icon, color: _accent, size: 20),
            prefixText: '₹ ',
            prefixStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _primary,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFD),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Required field';
            }
            final cleaned = value?.replaceAll(',', '') ?? '';
            if (cleaned.isNotEmpty &&
                (double.tryParse(cleaned) == null ||
                    double.parse(cleaned) < 0)) {
              return 'Invalid amount';
            }
            return null;
          },
        ),
      ],
    );
  }
}