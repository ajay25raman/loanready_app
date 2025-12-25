import 'package:flutter/material.dart';

class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController turnoverController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? selectedBusinessType;
  bool sameAsAddress = false;
  bool isDropdownOpen = false;

  final List<String> businessTypes = [
    'Retail (Grocery)',
    'Wholesale',
    'Manufacturing',
    'Services',
    'Food & Beverages',
    'Transport / Logistics',
    'Textile / Garments',
    'Electronics',
    'Others',
  ];

  // Validation functions
  String? _validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter business name';
    if (!RegExp(r'^[a-zA-Z0-9&.,() ]+$').hasMatch(value.trim())) {
      return 'Enter a valid business name';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter amount';
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Only numbers allowed';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter address';
    return null;
  }

  @override
  void dispose() {
    businessNameController.dispose();
    turnoverController.dispose();
    costController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Business Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.66,
                        backgroundColor: Colors.grey.shade300,
                        color: const Color(0xFF1A237E),
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '66%',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Business Name
                _buildTextField(
                  controller: businessNameController,
                  label: 'Business Name*',
                  hint: 'Ramesh Kirana Store',
                  validator: _validateBusinessName,
                ),
                const SizedBox(height: 15),

                // Business Type Dropdown
                const Text(
                  'Business Type*',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedBusinessType,
                  decoration: _dropDecoration(),
                  items: businessTypes
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBusinessType = value;
                      isDropdownOpen = false;
                    });
                  },
                  onTap: () {
                    setState(() {
                      isDropdownOpen = !isDropdownOpen;
                    });
                  },
                  icon: Icon(
                    isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                  validator: (value) =>
                  value == null ? 'Please select your business type' : null,
                ),
                const SizedBox(height: 15),

                // Turnover
                _buildTextField(
                  controller: turnoverController,
                  label: 'Monthly / Annual Turnover (₹)*',
                  hint: '50000',
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 15),

                // Cost / Expenses
                _buildTextField(
                  controller: costController,
                  label: 'Monthly / Annual Cost (₹)*',
                  hint: '10000',
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 15),

                // Same as address checkbox
                Row(
                  children: [
                    Checkbox(
                      value: sameAsAddress,
                      activeColor: const Color(0xFF1A237E),
                      onChanged: (value) {
                        setState(() {
                          sameAsAddress = value!;
                          if (sameAsAddress) {
                            addressController.text =
                            "Patna, Bihar"; // default or from previous form
                          } else {
                            addressController.clear();
                          }
                        });
                      },
                    ),
                    const Text(
                      "Same as address",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                // Business Address
                _buildTextField(
                  controller: addressController,
                  label: 'Business Address*',
                  hint: 'Patna, Bihar',
                  validator: _validateAddress,
                ),
                const SizedBox(height: 40),

                // Save & Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002D72),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Business Details Saved!'),
                          ),
                        );
                        Navigator.pushNamed(context, '/uploadDocuments');
                      }
                    },
                    child: const Text(
                      'Save & Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Common TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide:
              const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown decoration
  InputDecoration _dropDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
      ),
    );
  }
}
