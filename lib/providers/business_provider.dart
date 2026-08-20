import 'package:flutter/material.dart';
import 'package:loanready_app/Model/bussiness_details_model.dart';
import 'package:loanready_app/services/business_service.dart';


class BusinessProvider extends ChangeNotifier {
  final BusinessApiService _apiService = BusinessApiService();

  bool _isLoading = false;
  bool _sameAsAddress = false;
  bool _isDropdownOpen = false;
  String? _selectedBusinessType;

  bool get isLoading => _isLoading;
  bool get sameAsAddress => _sameAsAddress;
  bool get isDropdownOpen => _isDropdownOpen;
  String? get selectedBusinessType => _selectedBusinessType;

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController turnoverController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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

  void setSelectedBusinessType(String? value) {
    _selectedBusinessType = value;
    _isDropdownOpen = false;
    notifyListeners();
  }

  void toggleDropdown() {
    _isDropdownOpen = !_isDropdownOpen;
    notifyListeners();
  }

  void setSameAsAddress(bool value, String defaultAddress) {
    _sameAsAddress = value;
    if (_sameAsAddress) {
      addressController.text = defaultAddress;
    } else {
      addressController.clear();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> saveBusinessDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      final businessModel = BusinessDetailsModel(
        businessName:
        businessNameController.text.trim(),

        businessType:
        _selectedBusinessType,

        turnover:
        double.tryParse(
          turnoverController.text.trim(),
        ) ??
            0,

        cost:
        double.tryParse(
          costController.text.trim(),
        ) ??
            0,

        businessAddress:
        addressController.text.trim(),
      );

      final result =
      await _apiService.saveBusinessDetails(
        businessModel,
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    businessNameController.dispose();
    turnoverController.dispose();
    costController.dispose();
    addressController.dispose();
    super.dispose();
  }
}