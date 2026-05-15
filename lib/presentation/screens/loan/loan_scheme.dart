import 'package:flutter/material.dart';
import '../plan/choose_plan_screen.dart';

class LoanSchemeFormScreen extends StatefulWidget {
  const LoanSchemeFormScreen({super.key});

  @override
  State<LoanSchemeFormScreen> createState() => _LoanSchemeFormScreenState();
}

class _LoanSchemeFormScreenState extends State<LoanSchemeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Government schemes data – exactly as per PDF (unchanged)
  final List<Map<String, dynamic>> _allGovtSchemes = [
    // PM SVANidhi
    {
      'name': 'PM SVANidhi (Street Vendors)',
      'category': 'Street Vendors',
      'typeOfLoan': 'Working Capital',
      'targetGroups': ['Street Vendors', 'Urban Street Vendors'],
      'loanAmount': '₹10,000 - ₹50,000',
      'tenure': '1 year',
      'margin': 'Nil',
      'guarantee': 'No',
      'purpose': 'Working capital loan to street vendors',
      'benefits': 'No collateral, incentive for digital transactions',
      'documents': 'Aadhaar, Voter ID, street vending certificate, bank account',
      'collateral': 'No Collateral',
    },
    // PM Vishwakarma Yojana
    {
      'name': 'PM Vishwakarma Yojana',
      'category': 'Artisan',
      'typeOfLoan': 'Term Loan',
      'targetGroups': [
        'Carpenter (Suthar)', 'Boat Maker', 'Armourer', 'Blacksmith (Lohar)',
        'Hammer and Tool Kit Maker', 'Locksmith', 'Sculptor (Moortikar, Stone Carver)',
        'Goldsmith (Sunar)', 'Potter (Kumhaar)', 'Cobbler (Charmaker)/Footwear Artisan',
        'Masons (Raaj Mistri)', 'Basket/Mat/Broom Maker', 'Doll & Toy Maker (Traditional)',
        'Barber (Naai)', 'Garland Maker (Malakaar)', 'Washerman (Dhobi)',
        'Tailor (Darzi)', 'Fishing Net Maker',
      ],
      'loanAmount': '1st Tranche: ₹1,00,000, 2nd Tranche: ₹2,00,000',
      'tenure': '18 months (1st), 30 months (2nd)',
      'margin': 'Nil (collateral free)',
      'guarantee': 'Yes (collateral free credit)',
      'purpose': 'Enable recognition of artisans, skill upgradation, support for modern tools, collateral free credit, digital incentives, brand promotion.',
      'benefits': 'Interest subvention to make effective rate 5%',
      'documents': 'Aadhaar, artisan proof, bank account, recent photograph',
      'collateral': 'No Collateral',
    },
    // PM Mudra Yojana
    {
      'name': 'PM Mudra Yojana',
      'category': 'Business',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Micro Enterprises', 'Small Business'],
      'loanAmount': 'Shishu: up to ₹50,000; Kishore: ₹50,001-₹5 lakh; Tarun: ₹5-10 lakh; Tarun Plus: ₹10-20 lakh',
      'tenure': 'Up to 5 years (below ₹5 lakh), up to 7 years (₹5-20 lakh)',
      'margin': 'Up to ₹50,000: Nil; above: 20%',
      'guarantee': 'CGFMU',
      'purpose': 'Promote livelihood and income generation through credit to micro enterprises.',
      'benefits': 'Credit guarantee cover under CGFMU',
      'documents': 'KYC, business proof, project report if applicable',
      'collateral': 'No Collateral',
    },
    // Stand-Up India
    {
      'name': 'Stand-Up India',
      'category': 'SC/ST/Women',
      'typeOfLoan': 'Composite Loan',
      'targetGroups': ['SC Entrepreneurs', 'ST Entrepreneurs', 'Women Entrepreneurs'],
      'loanAmount': '₹10 lakh - ₹1 Crore (composite)',
      'tenure': '7 years (max moratorium 18 months)',
      'margin': '15% (can be converged with other schemes)',
      'guarantee': 'CGSSI – Max 80%',
      'purpose': 'Setting up a new enterprise in manufacturing, trading, or services sector by SC/ST/women.',
      'benefits': 'Credit guarantee up to 80%',
      'documents': 'KYC, business plan, project report, caste/category certificate',
      'collateral': 'No Collateral',
    },
    // PMEGP
    {
      'name': 'PMEGP',
      'category': 'Employment',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Individuals (18+ years)', 'SHGs', 'Trusts', 'Institutions'],
      'loanAmount': 'Manufacturing: up to ₹50 lakh; Service/Business: up to ₹20 lakh; Upgradation: up to ₹1 crore',
      'tenure': '3-7 years',
      'margin': 'General: 10%; Special (SC/ST/OBC/etc): 5%',
      'guarantee': 'CGFMU (up to ₹10 lakh) / CGTMSE (above ₹10 lakh)',
      'purpose': 'Generate employment opportunities through new self‑employment ventures/micro enterprises.',
      'benefits': 'Subsidy 15-35% of project cost provided by KVIC',
      'documents': 'Project report, educational qualification proof (if applicable), KYC',
      'collateral': 'No Collateral',
    },
    // DAY-NULM
    {
      'name': 'DAY-NULM',
      'category': 'Urban',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Urban Poor', 'Street Vendors', 'SHGs'],
      'loanAmount': 'Individual: up to ₹2 lakh; SHG: up to ₹2 lakh per member or ₹10 lakh whichever lower',
      'tenure': '5-7 years (moratorium 6-18 months)',
      'margin': 'Up to ₹50,000: Nil; above: 5-10%',
      'guarantee': 'CGTMSE',
      'purpose': 'Financial assistance to urban poor for self‑employment ventures.',
      'benefits': 'Interest subvention over and above 7% rate of interest on bank loans',
      'documents': 'KYC, proof of urban poor status, SHG resolution if applicable',
      'collateral': 'No Collateral',
    },
    // PM Awas Yojana
    {
      'name': 'PM Awas Yojana (Housing Loan Subsidy)',
      'category': 'Housing',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['EWS/LIG', 'MIG', 'Home Owners'],
      'loanAmount': 'Up to ₹12 lakh',
      'tenure': '20 years',
      'margin': '10-20%',
      'guarantee': 'No',
      'purpose': 'Provide housing for all by 2022',
      'benefits': 'Interest subsidy on home loans',
      'documents': 'Aadhaar, income proof, property documents',
      'collateral': 'No Collateral',
    },
    // PM Surya Ghar Yojana
    {
      'name': 'PM Surya Ghar Yojana',
      'category': 'Solar',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Home Owners'],
      'loanAmount': 'Up to 3 KW: max ₹2 lakh; >3-10 KW: max ₹6 lakh',
      'tenure': 'Max 120 months (incl. 6 months moratorium)',
      'margin': 'Up to 3 KW: 10%; >3-10 KW: 20%',
      'guarantee': 'No (hypothecation of assets)',
      'purpose': 'Installation of rooftop solar panels',
      'benefits': 'Subsidy under PM Surya Ghar scheme',
      'documents': 'Up to 3 KW: KYC, electricity bill; >3 KW: KYC, IT returns/Form-16, salary statement, electricity bill',
      'collateral': 'No Collateral',
    },
    // Agriculture Infrastructure Fund
    {
      'name': 'Agriculture Infrastructure Fund (AIF)',
      'category': 'Agriculture',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Farmers', 'FPOs', 'Agri-entrepreneurs'],
      'loanAmount': 'Up to ₹2 Crores',
      'tenure': '10 years',
      'margin': '10-25%',
      'guarantee': 'Yes',
      'purpose': 'Develop post-harvest management and community farming assets',
      'benefits': 'Interest subvention of 3%',
      'documents': 'Project report, land records, KYC',
      'collateral': 'No Collateral',
    },
    // ACABC Scheme
    {
      'name': 'ACABC Scheme',
      'category': 'Agriculture',
      'typeOfLoan': 'Term Loan',
      'targetGroups': [
        'Agriculture Graduates', 'Diploma Holders in Agriculture',
        'Biological Science Graduates with PG in Agriculture', 'Plus two with agriculture',
      ],
      'loanAmount': '₹25,000 - ₹2 Crores',
      'tenure': 'As per project',
      'margin': 'Up to ₹5 lakh: Nil; ₹5-10 lakh: 10%; above ₹10 lakh: 25%',
      'guarantee': 'May require collateral for higher loans',
      'purpose': 'Setting up Agri‑Clinics (expert advice) or Agri‑Business Centers (custom hiring, input sales, etc.)',
      'benefits': 'Training by MANAGE, handholding support',
      'documents': 'Educational certificates, project report, KYC',
      'collateral': 'No Collateral',
    },
    // PM FME
    {
      'name': 'PM FME',
      'category': 'Food Processing',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Individuals', 'FPOs', 'SHGs', 'Cooperatives'],
      'loanAmount': '₹25,000 - ₹9 Crores',
      'tenure': 'Max 10 years (moratorium up to 24 months)',
      'margin': '10%',
      'guarantee': 'Yes (credit guarantee available)',
      'purpose': 'Build capability of micro food processing enterprises, integrate with supply chain, access to common services.',
      'benefits': 'Credit linked capital subsidy @35% (max ₹10 lakh) for individuals; 35% grant for groups; convergence with AIF gives additional 3% interest subvention',
      'documents': 'Project report, KYC, business plan',
      'collateral': 'No Collateral',
    },
    // CSIS Education Loan
    {
      'name': 'CSIS (Education Loan Interest Subsidy)',
      'category': 'Education',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Students from EWS (family income ≤ ₹4.5 lakh)'],
      'loanAmount': 'As per IBA Model Education Loan (typically up to ₹20 lakh)',
      'tenure': 'Course duration + 1 year moratorium',
      'margin': 'Nil',
      'guarantee': 'No collateral for loans up to ₹4 lakh; may require for higher',
      'purpose': 'Interest subsidy during moratorium for technical/professional courses in India',
      'benefits': 'Government pays interest during moratorium for eligible students',
      'documents': 'Income certificate from authorised authority, admission proof, KYC',
      'collateral': 'No Collateral',
    },
  ];

  List<Map<String, dynamic>> _filteredSchemes = [];

  // Form controllers
  final TextEditingController _schemeNameController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _tenureController = TextEditingController();
  final TextEditingController _marginController = TextEditingController();
  final TextEditingController _targetGroupController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _documentsController = TextEditingController();
  final TextEditingController _collateralController = TextEditingController();

  String _selectedScheme = '';
  String _selectedCategory = '';
  String _loanType = 'Term Loan';
  bool _hasSubsidy = false;
  bool _hasGuarantee = false;

  @override
  void initState() {
    super.initState();
    _filteredSchemes = List.from(_allGovtSchemes);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filteredSchemes = List.from(_allGovtSchemes));
      return;
    }
    setState(() {
      _filteredSchemes = _allGovtSchemes.where((scheme) {
        if (scheme['name'].toLowerCase().contains(query)) return true;
        if (scheme['category'].toLowerCase().contains(query)) return true;
        if (scheme['targetGroups'] is List) {
          for (var group in scheme['targetGroups']) {
            if (group.toLowerCase().contains(query)) return true;
          }
        }
        return false;
      }).toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _schemeNameController.dispose();
    _loanAmountController.dispose();
    _tenureController.dispose();
    _marginController.dispose();
    _targetGroupController.dispose();
    _purposeController.dispose();
    _benefitsController.dispose();
    _documentsController.dispose();
    _collateralController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _selectedScheme.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a scheme first'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    if (_currentPage < 2 && _formKey.currentState?.validate() == true) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  void _selectScheme(Map<String, dynamic> scheme) {
    setState(() {
      _schemeNameController.clear();
      _loanAmountController.clear();
      _tenureController.clear();
      _marginController.clear();
      _targetGroupController.clear();
      _purposeController.clear();
      _benefitsController.clear();
      _documentsController.clear();
      _collateralController.clear();

      _selectedScheme = scheme['name'];
      _selectedCategory = scheme['category'];

      _schemeNameController.text = scheme['name'];
      _loanAmountController.text = scheme['loanAmount'] ?? '';
      _tenureController.text = scheme['tenure'] ?? '';
      _marginController.text = scheme['margin'] ?? '';
      if (scheme['targetGroups'] is List) {
        _targetGroupController.text = (scheme['targetGroups'] as List).join(', ');
      }
      _purposeController.text = scheme['purpose'] ?? '';
      _benefitsController.text = scheme['benefits'] ?? '';
      _documentsController.text = scheme['documents'] ?? '';
      _collateralController.text = scheme['collateral'] ?? 'No Collateral';
      _loanType = scheme['typeOfLoan'] ?? 'Term Loan';
      _hasSubsidy = scheme['benefits']?.toLowerCase().contains('subsidy') ?? false;
      final guarantee = (scheme['guarantee'] ?? '').toString().toLowerCase();
      _hasGuarantee = guarantee != 'no' && guarantee.isNotEmpty;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChoosePlanScreen()),
      );
    }
  }

  Map<String, dynamic> _createFormData() {
    return {
      'schemeName': _schemeNameController.text.trim(),
      'category': _selectedCategory,
      'loanAmount': _loanAmountController.text.trim(),
      'tenure': _tenureController.text.trim(),
      'margin': _marginController.text.trim(),
      'targetGroup': _targetGroupController.text.trim(),
      'purpose': _purposeController.text.trim(),
      'benefits': _benefitsController.text.trim(),
      'documents': _documentsController.text.trim(),
      'collateral': _collateralController.text.trim(),
      'loanType': _loanType,
      'hasSubsidy': _hasSubsidy,
      'hasGuarantee': _hasGuarantee,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Loan Scheme',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A2C3E), // matching slate
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFFFFFFF), Color(0xFFF0F4F8)],
          ),
        ),
        child: Column(
          children: [
            // Step indicator (premium style)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2C3E).withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStepIndicator(0, 'Select'),
                  _buildStepConnector(),
                  _buildStepIndicator(1, 'Details'),
                  _buildStepConnector(),
                  _buildStepIndicator(2, 'Review'),
                ],
              ),
            ),
            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2C3E).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF1A2C3E), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: const Color(0xFF1A2C3E),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentPage == 2 ? _submitForm : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2C3E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF1A2C3E).withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _currentPage == 2 ? 'Submit' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 30,
      height: 1,
      color: const Color(0xFFC9A227).withOpacity(0.3),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label) {
    bool isActive = _currentPage == stepNumber;
    bool isCompleted = _currentPage > stepNumber;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? const Color(0xFF1A2C3E) : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
              BoxShadow(
                color: const Color(0xFF1A2C3E).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
              '${stepNumber + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFF1A2C3E) : const Color(0xFF94A3B8),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // Step 1: Select Scheme (Premium Cards)
  Widget _buildStep1() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2C3E).withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A227).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.search_rounded, color: Color(0xFFC9A227), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search by name, category, or target group...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchController.clear(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredSchemes.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No schemes found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _filteredSchemes.length,
            itemBuilder: (context, index) {
              final scheme = _filteredSchemes[index];
              bool isSelected = _selectedScheme == scheme['name'];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFC9A227) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A2C3E).withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectScheme(scheme),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2C3E).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.account_balance, size: 24, color: Color(0xFF1A2C3E)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  scheme['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A2C3E),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  scheme['category'],
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  scheme['loanAmount'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC9A227),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A227).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 18, color: Color(0xFFC9A227)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Step 2: View Details (Editable + Read-only)
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheme Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2C3E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Category, Loan Type, and Features are editable',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, letterSpacing: -0.2),
          ),
          const SizedBox(height: 24),
          // Scheme Name (read-only)
          _buildPremiumFormField(
            label: 'Scheme Name',
            controller: _schemeNameController,
            hint: 'Select a scheme first',
            readOnly: true,
            isRequired: true,
          ),
          const SizedBox(height: 20),
          // Category (editable dropdown)
          _buildPremiumDropdown(
            label: 'Category',
            value: _selectedCategory,
            items: const [
              'Street Vendors', 'Artisan', 'Business', 'SC/ST/Women', 'Employment',
              'Urban', 'Housing', 'Solar', 'Agriculture', 'Food Processing', 'Education', 'Other'
            ],
            onChanged: (val) => setState(() => _selectedCategory = val!),
            isRequired: true,
          ),
          const SizedBox(height: 20),
          // Loan Amount + Collateral (both read-only)
          Row(
            children: [
              Expanded(
                child: _buildPremiumFormField(
                  label: 'Loan Amount Range',
                  controller: _loanAmountController,
                  hint: 'e.g., ₹50,000 - ₹5 lakh',
                  readOnly: true,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPremiumFormField(
                  label: 'Collateral',
                  controller: _collateralController,
                  hint: 'No Collateral',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tenure + Margin
          Row(
            children: [
              Expanded(
                child: _buildPremiumFormField(
                  label: 'Tenure',
                  controller: _tenureController,
                  hint: 'e.g., 5 years',
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPremiumFormField(
                  label: 'Margin %',
                  controller: _marginController,
                  hint: 'e.g., 10%',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Loan Type (editable dropdown)
          _buildPremiumDropdown(
            label: 'Type of Loan',
            value: _loanType,
            items: const ['Term Loan', 'Working Capital', 'Composite Loan', 'Overdraft', 'CC/OD'],
            onChanged: (val) => setState(() => _loanType = val!),
          ),
          const SizedBox(height: 20),
          // Target Group (read-only)
          _buildPremiumFormField(
            label: 'Target Group / Eligibility',
            controller: _targetGroupController,
            hint: 'Eligible groups',
            maxLines: 2,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          // Purpose (read-only)
          _buildPremiumFormField(
            label: 'Purpose of Loan',
            controller: _purposeController,
            hint: 'Loan purpose',
            maxLines: 2,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          // ========== FIXED: Responsive Scheme Features (Wrap instead of Row) ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scheme Features',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A2C3E)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24, // horizontal gap between items
                  runSpacing: 12, // vertical gap when wrapped
                  children: [
                    // Subsidy Checkbox
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _hasSubsidy,
                          onChanged: (val) => setState(() => _hasSubsidy = val ?? false),
                          activeColor: const Color(0xFFC9A227),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        const Text('Government Subsidy', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    // Guarantee Checkbox
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _hasGuarantee,
                          onChanged: (val) => setState(() => _hasGuarantee = val ?? false),
                          activeColor: const Color(0xFFC9A227),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        const Text('Credit Guarantee', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ================================================================
          const SizedBox(height: 20),
          // Benefits (read-only)
          _buildPremiumTextArea(
            label: 'Special Benefits',
            controller: _benefitsController,
            hint: 'Benefits description',
            readOnly: true,
          ),
          const SizedBox(height: 20),
          // Documents (read-only)
          _buildPremiumTextArea(
            label: 'Documents Required',
            controller: _documentsController,
            hint: 'List of documents',
            readOnly: true,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Step 3: Review & Submit
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2C3E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text('Review all details before submission', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A2C3E).withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A227).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'SCHEME SUMMARY',
                      style: TextStyle(
                        color: Color(0xFFC9A227),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPremiumSummaryRow('Scheme Name', _schemeNameController.text),
                _buildPremiumSummaryRow('Category', _selectedCategory),
                _buildPremiumSummaryRow('Target Group', _targetGroupController.text),
                _buildPremiumSummaryRow('Loan Amount', _loanAmountController.text),
                _buildPremiumSummaryRow('Tenure', _tenureController.text),
                _buildPremiumSummaryRow('Margin', _marginController.text),
                _buildPremiumSummaryRow('Collateral', _collateralController.text),
                _buildPremiumSummaryRow('Loan Type', _loanType),
                _buildPremiumSummaryRow('Subsidy', _hasSubsidy ? 'Yes' : 'No'),
                _buildPremiumSummaryRow('Credit Guarantee', _hasGuarantee ? 'Yes' : 'No'),
                if (_purposeController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Purpose:', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A2C3E))),
                  const SizedBox(height: 6),
                  Text(_purposeController.text, style: const TextStyle(color: Color(0xFF475569))),
                ],
                if (_benefitsController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Benefits:', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A2C3E))),
                  const SizedBox(height: 6),
                  Text(_benefitsController.text, style: const TextStyle(color: Color(0xFF475569))),
                ],
                if (_documentsController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Documents:', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A2C3E))),
                  const SizedBox(height: 6),
                  Text(_documentsController.text, style: const TextStyle(color: Color(0xFF475569))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC9A227).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFFC9A227), size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'I confirm that all details provided are accurate and complete.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1A2C3E), fontWeight: FontWeight.w500),
                  ),
                ),
                Checkbox(
                  value: true,
                  onChanged: null,
                  activeColor: const Color(0xFFC9A227),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Premium Form Field
  Widget _buildPremiumFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
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
                color: Color(0xFF1A2C3E),
                letterSpacing: -0.2,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A2C3E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF8FAFD) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFC9A227), width: 1.5),
            ),
          ),
          validator: isRequired
              ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  // Premium Dropdown
  Widget _buildPremiumDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
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
                color: Color(0xFF1A2C3E),
                letterSpacing: -0.2,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFC9A227)),
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A2C3E), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: 'Select $label',
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
            onChanged: onChanged,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            validator: isRequired
                ? (value) => value == null || value.isEmpty ? 'Required' : null
                : null,
          ),
        ),
      ],
    );
  }

  // Premium Text Area
  Widget _buildPremiumTextArea({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2C3E),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A2C3E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF8FAFD) : Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFC9A227), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A2C3E),
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}