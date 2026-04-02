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

  // Government schemes data – exactly as per PDF
  final List<Map<String, dynamic>> _allGovtSchemes = [
    // PM SVANidhi (not in PDF, kept as is)
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
    // PM Vishwakarma Yojana (PDF page 3)
    {
      'name': 'PM Vishwakarma Yojana',
      'category': 'Artisan',
      'typeOfLoan': 'Term Loan',
      'targetGroups': [
        'Carpenter (Suthar)',
        'Boat Maker',
        'Armourer',
        'Blacksmith (Lohar)',
        'Hammer and Tool Kit Maker',
        'Locksmith',
        'Sculptor (Moortikar, Stone Carver)',
        'Goldsmith (Sunar)',
        'Potter (Kumhaar)',
        'Cobbler (Charmaker)/Footwear Artisan',
        'Masons (Raaj Mistri)',
        'Basket/Mat/Broom Maker',
        'Doll & Toy Maker (Traditional)',
        'Barber (Naai)',
        'Garland Maker (Malakaar)',
        'Washerman (Dhobi)',
        'Tailor (Darzi)',
        'Fishing Net Maker',
      ],
      'loanAmount': '1st Tranche: ₹1,00,000, 2nd Tranche: ₹2,00,000',
      'tenure': '18 months (1st), 30 months (2nd)',
      'margin': 'Nil (collateral free)',
      'guarantee': 'Yes (collateral free credit)',
      'purpose':
      'Enable recognition of artisans, skill upgradation, support for modern tools, collateral free credit, digital incentives, brand promotion.',
      'benefits': 'Interest subvention to make effective rate 5%',
      'documents': 'Aadhaar, artisan proof, bank account, recent photograph',
      'collateral': 'No Collateral',
    },
    // PM Mudra Yojana (PDF page 4)
    {
      'name': 'PM Mudra Yojana',
      'category': 'Business',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Micro Enterprises', 'Small Business'],
      'loanAmount':
      'Shishu: up to ₹50,000; Kishore: ₹50,001-₹5 lakh; Tarun: ₹5-10 lakh; Tarun Plus: ₹10-20 lakh',
      'tenure': 'Up to 5 years (below ₹5 lakh), up to 7 years (₹5-20 lakh)',
      'margin': 'Up to ₹50,000: Nil; above: 20%',
      'guarantee': 'CGFMU',
      'purpose': 'Promote livelihood and income generation through credit to micro enterprises.',
      'benefits': 'Credit guarantee cover under CGFMU',
      'documents': 'KYC, business proof, project report if applicable',
      'collateral': 'No Collateral',
    },
    // Stand-Up India (PDF page 4)
    {
      'name': 'Stand-Up India',
      'category': 'SC/ST/Women',
      'typeOfLoan': 'Composite Loan',
      'targetGroups': ['SC Entrepreneurs', 'ST Entrepreneurs', 'Women Entrepreneurs'],
      'loanAmount': '₹10 lakh - ₹1 Crore (composite)',
      'tenure': '7 years (max moratorium 18 months)',
      'margin': '15% (can be converged with other schemes)',
      'guarantee': 'CGSSI – Max 80%',
      'purpose':
      'Setting up a new enterprise in manufacturing, trading, or services sector by SC/ST/women.',
      'benefits': 'Credit guarantee up to 80%',
      'documents': 'KYC, business plan, project report, caste/category certificate',
      'collateral': 'No Collateral',
    },
    // PMEGP (PDF page 5)
    {
      'name': 'PMEGP',
      'category': 'Employment',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Individuals (18+ years)', 'SHGs', 'Trusts', 'Institutions'],
      'loanAmount':
      'Manufacturing: up to ₹50 lakh; Service/Business: up to ₹20 lakh; Upgradation: up to ₹1 crore',
      'tenure': '3-7 years',
      'margin': 'General: 10%; Special (SC/ST/OBC/etc): 5%',
      'guarantee': 'CGFMU (up to ₹10 lakh) / CGTMSE (above ₹10 lakh)',
      'purpose': 'Generate employment opportunities through new self‑employment ventures/micro enterprises.',
      'benefits': 'Subsidy 15-35% of project cost provided by KVIC',
      'documents': 'Project report, educational qualification proof (if applicable), KYC',
      'collateral': 'No Collateral',
    },
    // DAY-NULM (PDF page 6)
    {
      'name': 'DAY-NULM',
      'category': 'Urban',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Urban Poor', 'Street Vendors', 'SHGs'],
      'loanAmount':
      'Individual: up to ₹2 lakh; SHG: up to ₹2 lakh per member or ₹10 lakh whichever lower',
      'tenure': '5-7 years (moratorium 6-18 months)',
      'margin': 'Up to ₹50,000: Nil; above: 5-10%',
      'guarantee': 'CGTMSE',
      'purpose': 'Financial assistance to urban poor for self‑employment ventures.',
      'benefits': 'Interest subvention over and above 7% rate of interest on bank loans',
      'documents': 'KYC, proof of urban poor status, SHG resolution if applicable',
      'collateral': 'No Collateral',
    },
    // PM Awas Yojana (kept as is – not in PDF)
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
    // PM Surya Ghar Yojana (PDF page 8)
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
      'documents':
      'Up to 3 KW: KYC, electricity bill; >3 KW: KYC, IT returns/Form-16, salary statement, electricity bill',
      'collateral': 'No Collateral',
    },
    // Agriculture Infrastructure Fund (AIF) – kept as is, not in PDF
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
    // ACABC Scheme (PDF page 10)
    {
      'name': 'ACABC Scheme',
      'category': 'Agriculture',
      'typeOfLoan': 'Term Loan',
      'targetGroups': [
        'Agriculture Graduates',
        'Diploma Holders in Agriculture',
        'Biological Science Graduates with PG in Agriculture',
        'Plus two with agriculture',
      ],
      'loanAmount': '₹25,000 - ₹2 Crores',
      'tenure': 'As per project',
      'margin': 'Up to ₹5 lakh: Nil; ₹5-10 lakh: 10%; above ₹10 lakh: 25%',
      'guarantee': 'May require collateral for higher loans',
      'purpose':
      'Setting up Agri‑Clinics (expert advice) or Agri‑Business Centers (custom hiring, input sales, etc.)',
      'benefits': 'Training by MANAGE, handholding support',
      'documents': 'Educational certificates, project report, KYC',
      'collateral': 'No Collateral',
    },
    // PM FME (PDF page 12-13)
    {
      'name': 'PM FME',
      'category': 'Food Processing',
      'typeOfLoan': 'Term Loan',
      'targetGroups': ['Individuals', 'FPOs', 'SHGs', 'Cooperatives'],
      'loanAmount': '₹25,000 - ₹9 Crores',
      'tenure': 'Max 10 years (moratorium up to 24 months)',
      'margin': '10%',
      'guarantee': 'Yes (credit guarantee available)',
      'purpose':
      'Build capability of micro food processing enterprises, integrate with supply chain, access to common services.',
      'benefits':
      'Credit linked capital subsidy @35% (max ₹10 lakh) for individuals; 35% grant for groups; convergence with AIF gives additional 3% interest subvention',
      'documents': 'Project report, KYC, business plan',
      'collateral': 'No Collateral',
    },
    // CSIS Education Loan (PDF page 14)
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

  // Selected values (editable ones)
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
      setState(() {
        _filteredSchemes = List.from(_allGovtSchemes);
      });
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
    // 🚨 Step 1 validation
    if (_currentPage == 0 && _selectedScheme.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a scheme first'),
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
      // ✅ clear first (pro UX)
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


      // Auto-fill all read‑only fields
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

      // Auto-fill editable fields
      _loanType = scheme['typeOfLoan'] ?? 'Term Loan';
      _hasSubsidy = scheme['benefits']?.toLowerCase().contains('subsidy') ?? false;
      final guarantee =
      (scheme['guarantee'] ?? '').toString().toLowerCase();
      _hasGuarantee = guarantee != 'no' && guarantee.isNotEmpty;

    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ChoosePlanScreen(),
        ),
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
      appBar: AppBar(
        title: const Text(
          'Loan Scheme',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 60,
              maxHeight: 80,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Select Scheme'),
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  _buildStepIndicator(1, 'View Details'),
                  Container(
                    width: 40,
                    height: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  _buildStepIndicator(2, 'Review'),
                ],
              ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
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
                      side: const BorderSide(color: Color(0xFF1A237E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentPage == 2 ? _submitForm : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
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

  Widget _buildStepIndicator(int stepNumber, String label) {
    bool isActive = _currentPage == stepNumber;
    bool isCompleted = _currentPage > stepNumber;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive || isCompleted ? const Color(0xFF1A237E) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
              '${stepNumber + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF1A237E) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Government Scheme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose from existing schemes (details are read‑only)',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by name, category, or target group...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                      },
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
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No schemes found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredSchemes.length,
            itemBuilder: (context, index) {
              final scheme = _filteredSchemes[index];
              bool isSelected = _selectedScheme == scheme['name'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A237E) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () => _selectScheme(scheme),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 24,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  title: Text(
                    scheme['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        scheme['category'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme['loanAmount'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF1A237E),
                  )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Step 2: only Category, Loan Type, and checkboxes are editable
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheme Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Category, Loan Type, and Features are editable; all other fields are read‑only.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Scheme Name (read‑only)
          _buildFormField(
            label: 'Scheme Name*',
            controller: _schemeNameController,
            hint: 'e.g., PM Mudra Yojana',
            readOnly: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Scheme name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Category (editable)
          _buildDropdownField(
            label: 'Category*',
            value: _selectedCategory,
            items: const [
              'Street Vendors',
              'Artisan',
              'Business',
              'SC/ST/Women',
              'Employment',
              'Urban',
              'Housing',
              'Solar',
              'Agriculture',
              'Food Processing',
              'Education',
              'Other'
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            enabled: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Category is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Loan Amount + Collateral (both read‑only)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Loan Amount Range*',
                  controller: _loanAmountController,
                  hint: 'e.g., ₹50,000 - ₹5 lakh',
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Loan amount is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Collateral',
                  controller: _collateralController,
                  hint: 'No Collateral',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tenure + Margin (read‑only)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Tenure',
                  controller: _tenureController,
                  hint: 'e.g., 5 years',
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Margin %',
                  controller: _marginController,
                  hint: 'e.g., 10% or Nil',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loan Type (editable)
          _buildDropdownField(
            label: 'Type of Loan',
            value: _loanType,
            items: const ['Term Loan', 'Working Capital', 'Composite Loan', 'Overdraft', 'CC/OD'],
            onChanged: (value) {
              if (value != null) {
                setState(() => _loanType = value);
              }
            },
            enabled: true,
          ),
          const SizedBox(height: 16),

          // Target Group (read‑only)
          _buildFormField(
            label: 'Target Group / Eligibility',
            controller: _targetGroupController,
            hint: 'e.g., SC/ST, Women Entrepreneurs, Micro Enterprises',
            maxLines: 2,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Purpose (read‑only)
          _buildFormField(
            label: 'Purpose of Loan',
            controller: _purposeController,
            hint: 'e.g., Business expansion, Working capital',
            maxLines: 2,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Checkboxes for features (editable)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scheme Features',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _hasSubsidy,
                    onChanged: (value) {
                      setState(() => _hasSubsidy = value ?? false);
                    },
                    activeColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text('Government Subsidy', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: _hasGuarantee,
                    onChanged: (value) {
                      setState(() => _hasGuarantee = value ?? false);
                    },
                    activeColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text('Credit Guarantee', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Benefits (read‑only)
          _buildTextAreaField(
            label: 'Special Benefits',
            controller: _benefitsController,
            hint: 'e.g., Interest subsidy, Digital incentives',
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Documents (read‑only)
          _buildTextAreaField(
            label: 'Documents Required',
            controller: _documentsController,
            hint: 'e.g., Aadhaar, PAN, Bank Statements',
            readOnly: true,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review all details before submission',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SCHEME SUMMARY',
                      style: TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummaryRow('Scheme Name', _schemeNameController.text),
                _buildSummaryRow('Category', _selectedCategory),
                _buildSummaryRow('Target Group', _targetGroupController.text),
                _buildSummaryRow('Loan Amount', _loanAmountController.text),
                _buildSummaryRow('Tenure', _tenureController.text),
                _buildSummaryRow('Margin', _marginController.text),
                _buildSummaryRow('Collateral', _collateralController.text),
                _buildSummaryRow('Loan Type', _loanType),
                _buildSummaryRow('Government Subsidy', _hasSubsidy ? 'Yes' : 'No'),
                _buildSummaryRow('Credit Guarantee', _hasGuarantee ? 'Yes' : 'No'),
                if (_purposeController.text.isNotEmpty)
                  _buildSummaryRow('Purpose', _purposeController.text),
                if (_benefitsController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Special Benefits:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _benefitsController.text,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                if (_documentsController.text.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Documents Required:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _documentsController.text,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confirmation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1E9FF)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: null,
                  activeColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'I confirm that all details provided are accurate and complete.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1A237E)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Enhanced _buildFormField with readOnly parameter
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
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
                color: Color(0xFF1A237E),
              ),
            ),
            if (validator != null)
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  // Enhanced _buildTextAreaField with readOnly
  Widget _buildTextAreaField({
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
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Enhanced _buildDropdownField with enabled parameter
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
    bool enabled = true,
    String? Function(String?)? validator,
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
                color: Color(0xFF1A237E),
              ),
            ),
            if (validator != null)
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value.isEmpty ? null : value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: 'Select $label',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            validator: validator,
            onChanged: enabled ? onChanged : null,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            disabledHint: Text(value.isEmpty ? 'Not selected' : value),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}