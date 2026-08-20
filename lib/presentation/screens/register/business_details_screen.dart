// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BusinessDetailsScreen extends StatefulWidget {
//   const BusinessDetailsScreen({super.key});
//
//   @override
//   State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
// }
//
// class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController businessNameController = TextEditingController();
//   final TextEditingController turnoverController = TextEditingController();
//   final TextEditingController costController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//
//   static const String baseUrl =
//       "https://loan-approval-api-faur.onrender.com/api/v1";
//   bool _isLoading = false;
//
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString("auth_token");
//   }
//
//   String? selectedBusinessType;
//   bool sameAsAddress = false;
//   bool isDropdownOpen = false;
//
//   Future<void> _saveBusinessDetails() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final token = await _getToken();
//
//       if (token == null || token.isEmpty) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Authentication token not found")),
//         );
//         return;
//       }
//
//       // ✅ FIX 1: Corrected payload keys to match backend expected keys (turnover & cost)
//       final requestBody = {
//         "businessName": businessNameController.text.trim(),
//         "businessType": selectedBusinessType,
//         "turnover": double.tryParse(turnoverController.text.trim()) ?? 0,
//         "cost": double.tryParse(costController.text.trim()) ?? 0,
//         "businessAddress": addressController.text.trim(),
//       };
//
//       // ✅ FIX 2: Corrected Endpoint URL from '/business/profile' to '/business'
//       final response = await http.post(
//         Uri.parse("$baseUrl/business"),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode(requestBody),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (!mounted) return;
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data["message"] ?? "Business details saved"),
//           ),
//         );
//
//         Navigator.pushNamed(context, "/uploadDocuments");
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data["message"] ?? "Failed to save business details"),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   final List<String> businessTypes = [
//     'Retail (Grocery)',
//     'Wholesale',
//     'Manufacturing',
//     'Services',
//     'Food & Beverages',
//     'Transport / Logistics',
//     'Textile / Garments',
//     'Electronics',
//     'Others',
//   ];
//
//   // Validation functions
//   String? _validateBusinessName(String? value) {
//     if (value == null || value.trim().isEmpty) return 'Please enter business name';
//     if (!RegExp(r'^[a-zA-Z0-9&.,() ]+$').hasMatch(value.trim())) {
//       return 'Enter a valid business name';
//     }
//     return null;
//   }
//
//   String? _validateAmount(String? value) {
//     if (value == null || value.trim().isEmpty) return 'Please enter amount';
//     if (!RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(value.trim())) {
//       return 'Only numbers allowed';
//     }
//     return null;
//   }
//
//   String? _validateAddress(String? value) {
//     if (value == null || value.trim().isEmpty) return 'Please enter address';
//     return null;
//   }
//
//   @override
//   void dispose() {
//     businessNameController.dispose();
//     turnoverController.dispose();
//     costController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Business Details"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Form(
//             key: _formKey,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Progress bar
//                 Row(
//                   children: [
//                     Expanded(
//                       child: LinearProgressIndicator(
//                         value: 0.66,
//                         backgroundColor: Colors.grey.shade300,
//                         color: const Color(0xFF1A237E),
//                         minHeight: 3,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     const Text(
//                       '66%',
//                       style: TextStyle(color: Colors.black54, fontSize: 13),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//
//                 // Business Name
//                 _buildTextField(
//                   controller: businessNameController,
//                   label: 'Business Name*',
//                   hint: 'Ramesh Kirana Store',
//                   validator: _validateBusinessName,
//                 ),
//                 const SizedBox(height: 15),
//
//                 // Business Type Dropdown
//                 const Text(
//                   'Business Type*',
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 6),
//                 DropdownButtonFormField<String>(
//                   value: selectedBusinessType,
//                   decoration: _dropDecoration(),
//                   items: businessTypes
//                       .map((type) => DropdownMenuItem(
//                     value: type,
//                     child: Text(type),
//                   ))
//                       .toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedBusinessType = value;
//                       isDropdownOpen = false;
//                     });
//                   },
//                   onTap: () {
//                     setState(() {
//                       isDropdownOpen = !isDropdownOpen;
//                     });
//                   },
//                   icon: Icon(
//                     isDropdownOpen
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                     color: Colors.black54,
//                   ),
//                   validator: (value) =>
//                   value == null ? 'Please select your business type' : null,
//                 ),
//                 const SizedBox(height: 15),
//
//                 // Turnover
//                 _buildTextField(
//                   controller: turnoverController,
//                   label: 'Monthly / Annual Turnover (₹)*',
//                   hint: '50000',
//                   keyboardType: TextInputType.number,
//                   validator: _validateAmount,
//                 ),
//                 const SizedBox(height: 15),
//
//                 // Cost / Expenses
//                 _buildTextField(
//                   controller: costController,
//                   label: 'Monthly / Annual Cost (₹)*',
//                   hint: '10000',
//                   keyboardType: TextInputType.number,
//                   validator: _validateAmount,
//                 ),
//                 const SizedBox(height: 15),
//
//                 // Same as address checkbox
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: sameAsAddress,
//                       activeColor: const Color(0xFF1A237E),
//                       onChanged: (value) {
//                         setState(() {
//                           sameAsAddress = value!;
//                           if (sameAsAddress) {
//                             addressController.text = "Patna, Bihar";
//                           } else {
//                             addressController.clear();
//                           }
//                         });
//                       },
//                     ),
//                     const Text(
//                       "Same as address",
//                       style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//
//                 // Business Address
//                 _buildTextField(
//                   controller: addressController,
//                   label: 'Business Address*',
//                   hint: 'Patna, Bihar',
//                   validator: _validateAddress,
//                 ),
//                 const SizedBox(height: 40),
//
//                 // Save & Continue Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF002D72),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: _isLoading
//                         ? null
//                         : () {
//                       FocusScope.of(context).unfocus();
//                       _saveBusinessDetails();
//                     },
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text(
//                       'Save & Continue',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Common TextField Widget
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 15,
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w500)),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           validator: validator,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: Colors.black54),
//             filled: true,
//             fillColor: const Color(0xFFF5F7FA),
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: const BorderSide(color: Colors.transparent),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide:
//               const BorderSide(color: Color(0xFF1A237E), width: 2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Dropdown decoration
//   InputDecoration _dropDecoration() {
//     return InputDecoration(
//       filled: true,
//       fillColor: const Color(0xFFF5F7FA),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(5),
//         borderSide: const BorderSide(color: Colors.transparent),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(5),
//         borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:loanready_app/providers/business_provider.dart';
import 'package:provider/provider.dart';


class BusinessDetailsScreen extends StatelessWidget {
  BusinessDetailsScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  String? _validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter business name';
    if (!RegExp(r'^[a-zA-Z0-9&.,() ]+$').hasMatch(value.trim())) {
      return 'Enter a valid business name';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter amount';
    if (!RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(value.trim())) {
      return 'Only numbers allowed';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter address';
    return null;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessProvider>();

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

                _buildTextField(
                  controller: provider.businessNameController,
                  label: 'Business Name*',
                  hint: 'Ramesh Kirana Store',
                  validator: _validateBusinessName,
                ),
                const SizedBox(height: 15),

                const Text(
                  'Business Type*',
                  style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: provider.selectedBusinessType,
                  decoration: _dropDecoration(),
                  items: provider.businessTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => provider.setSelectedBusinessType(value),
                  onTap: () => provider.toggleDropdown(),
                  icon: Icon(
                    provider.isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                  validator: (value) => value == null ? 'Please select your business type' : null,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: provider.turnoverController,
                  label: 'Monthly / Annual Turnover (₹)*',
                  hint: '50000',
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: provider.costController,
                  label: 'Monthly / Annual Cost (₹)*',
                  hint: '10000',
                  keyboardType: TextInputType.number,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Checkbox(
                      value: provider.sameAsAddress,
                      activeColor: const Color(0xFF1A237E),
                      onChanged: (value) => provider.setSameAsAddress(value ?? false, "Patna, Bihar"),
                    ),
                    const Text(
                      "Same as address",
                      style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                _buildTextField(
                  controller: provider.addressController,
                  label: 'Business Address*',
                  hint: 'Patna, Bihar',
                  validator: _validateAddress,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002D72),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        final res = await provider.saveBusinessDetails();
                        if (!context.mounted) return;
                        _showSnackBar(context, res['message']);
                        if (res['success']) {
                          Navigator.pushNamed(context, "/uploadDocuments");
                        }
                      }
                    },
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Save & Continue',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
        Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _dropDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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