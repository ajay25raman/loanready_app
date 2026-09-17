import 'package:flutter/material.dart';

class OneYearResultScreen extends StatefulWidget {
  final Map<String, dynamic> resultData;

  const OneYearResultScreen({
    super.key,
    required this.resultData,
  });

  @override
  State<OneYearResultScreen> createState() => _OneYearResultScreenState();
}

class _OneYearResultScreenState extends State<OneYearResultScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    debugPrint('========== FINANCIAL RESULT ==========');
    debugPrint(widget.resultData.toString());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  double _number(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _money(dynamic value) {
    final n = _number(value);
    final abs = n.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
    return n < 0 ? '-₹$abs' : '₹$abs';
  }

  Map<String, dynamic> get _firstYear => _map(widget.resultData['firstYear']);
  Map<String, dynamic> get _secondYear => _map(widget.resultData['secondYear']);
  Map<String, dynamic> get _thirdYear => _map(widget.resultData['thirdYear']);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context, true)
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          '3-Year Financial Report',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Year 1'),
            Tab(text: 'Year 2'),
            Tab(text: 'Year 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _YearContent(
            yearData: _firstYear,
            yearTitle: 'First Year',
            yearType: 'Actual',
            money: _money,
            map: _map,
            number: _number,
          ),
          _YearContent(
            yearData: _secondYear,
            yearTitle: 'Second Year',
            yearType: 'Estimated',
            money: _money,
            map: _map,
            number: _number,
          ),
          _YearContent(
            yearData: _thirdYear,
            yearTitle: 'Third Year',
            yearType: 'Projected',
            money: _money,
            map: _map,
            number: _number,
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// YEAR CONTENT
// ═════════════════════════════════════════════════════════════════════════════

class _YearContent extends StatelessWidget {
  final Map<String, dynamic> yearData;
  final String yearTitle;
  final String yearType;
  final String Function(dynamic) money;
  final Map<String, dynamic> Function(dynamic) map;
  final double Function(dynamic) number;

  const _YearContent({
    required this.yearData,
    required this.yearTitle,
    required this.yearType,
    required this.money,
    required this.map,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    if (yearData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );
    }

    // API response mapping (safe)
    final plContainer = map(yearData['pl']);
    final profitLoss = map(plContainer['profitLoss']);
    final tradingContainer = map(yearData['oneYearTrading']);
    final trading = map(tradingContainer['yearOne']);
    final balanceContainer = map(yearData['balanceSheet']);
    final balance = map(balanceContainer['bs']);
    final assets = map(balance['assets']);
    final liabilities = map(balance['liabilities']);

    final totalAssets = number(balanceContainer['totalAssets']);
    final totalLiabilities = number(balanceContainer['totalLiabilities']);
    final plTotalIncome = number(plContainer['plTotalIncome']);
    final finalPlExpenses = number(plContainer['finalplTotalExpenses']);
    final isBalanced = (totalAssets - totalLiabilities).abs() < 0.01;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _HeaderCard(yearTitle: yearTitle, yearType: yearType),
          const SizedBox(height: 20),

          // Key Metrics
          _SectionTitle(title: 'Key Metrics', icon: Icons.analytics_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Sales',
                  value: money(trading['sales']),
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Gross Profit',
                  value: money(trading['grossProfitLoss']),
                  icon: Icons.show_chart,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Net Profit',
                  value: money(profitLoss['netProfit']),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Total Assets',
                  value: money(totalAssets),
                  icon: Icons.assessment_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Trading Account
          _SectionTitle(
            title: 'Trading Account',
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              children: [
                _ValueRow('Opening Stock', money(trading['openingStock'])),
                _ValueRow('Purchases', money(trading['purchases'])),
                _ValueRow('Purchase Return', money(trading['lessReturn'])),
                _ValueRow('Carriage Inwards', money(trading['carriageInwards'])),
                _ValueRow('Cartage', money(trading['cartage'])),
                _ValueRow('Dock Charges', money(trading['dockCharges'])),
                _ValueRow('Wages', money(trading['wages'])),
                _ValueRow('Duty', money(trading['duty'])),
                _ValueRow('Freight', money(trading['freight'])),
                _ValueRow('Clearing Charges', money(trading['ClearingCharges'])),
                _ValueRow('Other Expenses', money(trading['otherExpenses'])),
                _ValueRow('Closing Stock', money(trading['closingStock'])),
                _ValueRow('Sales', money(trading['sales'])),
                _TotalRow('Gross Profit / Loss', money(trading['grossProfitLoss'])),
              ],
            ),
          ),

          // Profit & Loss
          _SectionTitle(
            title: 'Profit & Loss Account',
            icon: Icons.bar_chart_outlined,
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              children: [
                _ValueRow('Salaries', money(profitLoss['salaries'])),
                _ValueRow('Rent', money(profitLoss['rent'])),
                _ValueRow('Discount Allowed', money(profitLoss['discountAllowed'])),
                _ValueRow('Commission Paid', money(profitLoss['commissionPaid'])),
                _ValueRow('Insurance', money(profitLoss['insurance'])),
                _ValueRow('Bank Charges', money(profitLoss['bankCharges'])),
                _ValueRow('Legal Charges', money(profitLoss['legalCharges'])),
                _ValueRow('Repairs', money(profitLoss['repairs'])),
                _ValueRow('Advertising', money(profitLoss['advertising'])),
                _ValueRow('Trade Expenses', money(profitLoss['tradeExpenses'])),
                _ValueRow('Office Expenses', money(profitLoss['officeExpenses'])),
                _ValueRow('Bad Debts', money(profitLoss['badDebts'])),
                _ValueRow('Travelling Expenses', money(profitLoss['travellingExpenses'])),
                _ValueRow('Selling & Distribution', money(profitLoss['sellingAndDistribution'])),
                const Divider(height: 24),
                _ValueRow('Gross Profit B/F', money(profitLoss['grossProfitBf']), bold: true),
                _ValueRow('Interest Received', money(profitLoss['interestReceived'])),
                _ValueRow('Discount Received', money(profitLoss['discountReceived'])),
                _ValueRow('Commission Received', money(profitLoss['commissionReceived'])),
                _ValueRow('Other Receipts', money(profitLoss['otherReceipts'])),
                _TotalRow('P&L Total Income', money(plTotalIncome)),
                _TotalRow('Net Profit', money(profitLoss['netProfit'])),
                _TotalRow('Final P&L Expenses', money(finalPlExpenses)),
              ],
            ),
          ),

          // Balance Sheet
          _SectionTitle(
            title: 'Balance Sheet',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                _ValueRow('Cash in Hand', money(assets['cashInHand'])),
                _ValueRow('Cash at Bank', money(assets['cashAtBank'])),
                _ValueRow('Bills Receivable', money(assets['billsReceivable'])),
                _ValueRow('Land & Building', money(assets['landAndBuilding'])),
                _ValueRow('Stock', money(assets['stock'])),
                _ValueRow('Office Building', money(assets['officeBuilding'])),
                _ValueRow('Office Equipment', money(assets['officeEquipment'])),
                _TotalRow('Total Assets', money(totalAssets)),
                const SizedBox(height: 22),
                const Text(
                  'Liabilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                _ValueRow('Bills Payable', money(liabilities['billsPayable'])),
                _ValueRow('Capital', money(liabilities['capital'])),
                _ValueRow('Net Profit', money(liabilities['netProfit'])),
                _TotalRow('Total Liabilities', money(totalLiabilities)),
                const SizedBox(height: 16),
                _BalanceStatus(isBalanced: isBalanced),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SMALL UI COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  final String yearTitle;
  final String yearType;

  const _HeaderCard({required this.yearTitle, required this.yearType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yearTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  yearType,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Financial Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _ValueRow(this.title, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String title;
  final String value;

  const _TotalRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: const Color(0xFF2563EB)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceStatus extends StatelessWidget {
  final bool isBalanced;

  const _BalanceStatus({required this.isBalanced});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBalanced ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isBalanced ? Icons.check_circle : Icons.warning,
            color: isBalanced
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isBalanced
                  ? 'Balance Sheet is balanced'
                  : 'Balance Sheet is not balanced',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isBalanced
                    ? const Color(0xFF047857)
                    : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}