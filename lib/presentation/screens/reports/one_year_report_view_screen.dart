import 'package:flutter/material.dart';
import 'package:loanready_app/presentation/screens/reports/financial_report_pdf_service.dart';
import 'package:loanready_app/providers/one_year_report_provider.dart';
import 'package:provider/provider.dart';

class OneYearReportViewScreen extends StatefulWidget {
  final int reportId;

  const OneYearReportViewScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<OneYearReportViewScreen> createState() =>
      _OneYearReportViewScreenState();
}

class _OneYearReportViewScreenState
    extends State<OneYearReportViewScreen> {
  int selectedYear = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OneYearReportProvider>()
          .fetchReportById(widget.reportId);
    });
  }

  double numValue(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
  Future<void> _downloadPdf(
      Map<String, dynamic> report,
      ) async {
    try {
      final path =
      await FinancialReportPdfService.downloadPdf(
        report: report,
        reportId: widget.reportId,
      );

      if (!mounted) return;

      if (path != null && path.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF downloaded successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF download failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _sharePdf(
      Map<String, dynamic> report,
      ) async {
    try {
      await FinancialReportPdfService.sharePdf(
        report: report,
        reportId: widget.reportId,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF share failed: $e',
          ),
        ),
      );
    }
  }

  String money(dynamic value) {
    final amount = numValue(value);

    return '₹${amount.toStringAsFixed(0)}';
  }

  String formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return '-';

    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][date.month - 1];

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} $month ${date.year}, '
        '$hour:$minute $period';
  }

  Map<String, dynamic> mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 24,
            color: Color(0xFF0B1628),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Financial Report',
          style: TextStyle(
            color: Color(0xFF0B1628),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Download PDF',
            onPressed: () {
              final report = context
                  .read<OneYearReportProvider>()
                  .selectedReport;

              if (report != null) {
                _downloadPdf(report);
              }
            },
            icon: const Icon(
              Icons.download_outlined,
              color: Color(0xFF0B1628),
            ),
          ),

          IconButton(
            tooltip: 'Share',
            onPressed: () {
              final report = context
                  .read<OneYearReportProvider>()
                  .selectedReport;

              if (report != null) {
                _sharePdf(report);
              }
            },
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xFF0B1628),
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
      body: Consumer<OneYearReportProvider>(
        builder: (context, provider, child) {
          if (provider.isViewLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return _ErrorView(
              message: provider.errorMessage!,
              onRetry: () {
                provider.fetchReportById(
                  widget.reportId,
                );
              },
            );
          }

          final response = provider.selectedReport;

          if (response == null || response.isEmpty) {
            return const Center(
              child: Text(
                'No report available',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          }

          final firstYear = mapValue(
            response['firstYear'],
          );

          final secondYear = mapValue(
            response['secondYear'],
          );

          final thirdYear = mapValue(
            response['thirdYear'],
          );

          final years = [
            firstYear,
            secondYear,
            thirdYear,
          ];

          final selectedData = years[selectedYear];

          final createdAt = response['createdAt'];

          return Column(
            children: [
              _ReportHeader(
                reportId: widget.reportId,
                createdAt: createdAt,
              ),

              _YearTabs(
                selectedYear: selectedYear,
                onChanged: (index) {
                  setState(() {
                    selectedYear = index;
                  });
                },
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    30,
                  ),
                  children: [
                    if (selectedData.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 100,
                        ),
                        child: Center(
                          child: Text(
                            'No data available for this year',
                          ),
                        ),
                      )
                    else
                      _YearSection(
                        title:
                        'Year ${selectedYear + 1}',
                        yearData: selectedData,
                        money: money,
                      ),

                    const SizedBox(height: 18),

                    _PdfButtons(
                      onDownload: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'PDF download will be available here',
                            ),
                          ),
                        );
                      },
                      onShare: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'PDF share will be available here',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// REPORT HEADER
// ============================================================

class _ReportHeader extends StatelessWidget {
  final int reportId;
  final dynamic createdAt;

  const _ReportHeader({
    required this.reportId,
    required this.createdAt,
  });

  String formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(
      value.toString(),
    );

    if (date == null) return '-';

    final month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][date.month - 1];

    return '${date.day} $month ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E9EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF1649E8),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Report #$reportId',
                //   style: const TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w700,
                //     color: Color(0xFF0B1628),
                //   ),
                // ),

                Text(
                  'Report',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B1628),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Created ${formatDate(createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: Color(0xFF218739),
                ),
                SizedBox(width: 4),
                Text(
                  'Ready',
                  style: TextStyle(
                    color: Color(0xFF218739),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// YEAR TABS
// ============================================================

class _YearTabs extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onChanged;

  const _YearTabs({
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final selected = selectedYear == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.calendar_month_outlined,
                      size: 17,
                      color: selected
                          ? const Color(0xFF1649E8)
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Year ${index + 1}',
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF1649E8)
                            : Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================
// YEAR SECTION
// ============================================================

class _YearSection extends StatelessWidget {
  final String title;
  final Map<String, dynamic> yearData;
  final String Function(dynamic) money;

  const _YearSection({
    required this.title,
    required this.yearData,
    required this.money,
  });

  Map<String, dynamic> mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    final pl = mapValue(
      yearData['pl'],
    );

    final profitLoss = mapValue(
      pl['profitLoss'],
    );

    final tradingContainer = mapValue(
      yearData['oneYearTrading'],
    );

    final trading = mapValue(
      tradingContainer['yearOne'],
    );

    final balanceContainer = mapValue(
      yearData['balanceSheet'],
    );

    final balance = mapValue(
      balanceContainer['bs'],
    );

    final assets = mapValue(
      balance['assets'],
    );

    final liabilities = mapValue(
      balance['liabilities'],
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _TradingAccountCard(
          trading: trading,
          money: money,
        ),

        const SizedBox(height: 12),

        _ProfitLossCard(
          profitLoss: profitLoss,
          money: money,
        ),

        const SizedBox(height: 12),

        _BalanceSheetCard(
          assets: assets,
          liabilities: liabilities,
          balanceSheet: balanceContainer,
          money: money,
        ),
      ],
    );
  }
}

// ============================================================
// TRADING ACCOUNT
// ============================================================

class _TradingAccountCard extends StatelessWidget {
  final Map<String, dynamic> trading;
  final String Function(dynamic) money;

  const _TradingAccountCard({
    required this.trading,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return _ExpandableCard(
      icon: Icons.balance_outlined,
      title: 'Trading Account',
      initiallyExpanded: true,
      children: [
        _SummaryRow(
          title: 'Opening Stock',
          value: money(
            trading['openingStock'],
          ),
        ),

        _SummaryRow(
          title: 'Purchases',
          value: money(
            trading['purchases'],
          ),
        ),

        _SummaryRow(
          title: 'Less: Purchase Return',
          value: money(
            trading['lessReturn'],
          ),
        ),

        _SummaryRow(
          title: 'Carriage Inwards',
          value: money(
            trading['carriageInwards'],
          ),
        ),

        _SummaryRow(
          title: 'Cartage',
          value: money(
            trading['cartage'],
          ),
        ),

        _SummaryRow(
          title: 'Dock Charges',
          value: money(
            trading['dockCharges'],
          ),
        ),

        _SummaryRow(
          title: 'Wages',
          value: money(
            trading['wages'],
          ),
        ),

        _SummaryRow(
          title: 'Duty',
          value: money(
            trading['duty'],
          ),
        ),

        _SummaryRow(
          title: 'Freight',
          value: money(
            trading['freight'],
          ),
        ),

        _SummaryRow(
          title: 'Clearing Charges',
          value: money(
            trading['ClearingCharges'],
          ),
        ),

        _SummaryRow(
          title: 'Other Expenses',
          value: money(
            trading['otherExpenses'],
          ),
        ),

        _SummaryRow(
          title: 'Gross Profit',
          value: money(
            trading['grossProfitLoss'],
          ),
          valueColor: Colors.green,
          bold: true,
        ),

        _SummaryRow(
          title: 'Closing Stock',
          value: money(
            trading['closingStock'],
          ),
        ),

        const Divider(height: 20),

        _SummaryRow(
          title: 'Sales',
          value: money(
            trading['sales'],
          ),
        ),

        _SummaryRow(
          title: 'Total',
          value: money(
            trading['totalIncome'],
          ),
          valueColor: const Color(
            0xFF1649E8,
          ),
          bold: true,
        ),
      ],
    );
  }
}

// ============================================================
// PROFIT LOSS
// ============================================================

class _ProfitLossCard extends StatelessWidget {
  final Map<String, dynamic> profitLoss;
  final String Function(dynamic) money;

  const _ProfitLossCard({
    required this.profitLoss,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return _ExpandableCard(
      icon: Icons.bar_chart_outlined,
      title: 'Profit & Loss Account',
      initiallyExpanded: false,
      children: [
        _SummaryRow(
          title: 'Salaries',
          value: money(
            profitLoss['salaries'],
          ),
        ),

        _SummaryRow(
          title: 'Rent',
          value: money(
            profitLoss['rent'],
          ),
        ),

        _SummaryRow(
          title: 'Discount Allowed',
          value: money(
            profitLoss['discountAllowed'],
          ),
        ),

        _SummaryRow(
          title: 'Commission Paid',
          value: money(
            profitLoss['commissionPaid'],
          ),
        ),

        _SummaryRow(
          title: 'Insurance',
          value: money(
            profitLoss['insurance'],
          ),
        ),

        _SummaryRow(
          title: 'Bank Charges',
          value: money(
            profitLoss['bankCharges'],
          ),
        ),

        _SummaryRow(
          title: 'Legal Charges',
          value: money(
            profitLoss['legalCharges'],
          ),
        ),

        _SummaryRow(
          title: 'Repairs',
          value: money(
            profitLoss['repairs'],
          ),
        ),

        _SummaryRow(
          title: 'Advertising',
          value: money(
            profitLoss['advertising'],
          ),
        ),

        _SummaryRow(
          title: 'Trade Expenses',
          value: money(
            profitLoss['tradeExpenses'],
          ),
        ),

        _SummaryRow(
          title: 'Office Expenses',
          value: money(
            profitLoss['officeExpenses'],
          ),
        ),

        _SummaryRow(
          title: 'Bad Debts',
          value: money(
            profitLoss['badDebts'],
          ),
        ),

        _SummaryRow(
          title: 'Travelling Expenses',
          value: money(
            profitLoss['travellingExpenses'],
          ),
        ),

        _SummaryRow(
          title: 'Selling & Distribution',
          value: money(
            profitLoss['sellingAndDistribution'],
          ),
        ),

        const Divider(height: 20),

        _SummaryRow(
          title: 'Gross Profit b/f',
          value: money(
            profitLoss['grossProfitBf'],
          ),
        ),

        _SummaryRow(
          title: 'Interest Received',
          value: money(
            profitLoss['interestReceived'],
          ),
        ),

        _SummaryRow(
          title: 'Discount Received',
          value: money(
            profitLoss['discountReceived'],
          ),
        ),

        _SummaryRow(
          title: 'Commission Received',
          value: money(
            profitLoss['commissionReceived'],
          ),
          valueColor: Colors.green,
        ),

        _SummaryRow(
          title: 'Other Receipts',
          value: money(
            profitLoss['otherReceipts'],
          ),
        ),

        const Divider(height: 20),

        _SummaryRow(
          title: 'Net Profit',
          value: money(
            profitLoss['netProfit'],
          ),
          valueColor: const Color(
            0xFF1649E8,
          ),
          bold: true,
        ),

        _SummaryRow(
          title: 'Total',
          value: money(
            profitLoss['plTotalIncome'],
          ),
          valueColor: const Color(
            0xFF1649E8,
          ),
          bold: true,
        ),
      ],
    );
  }
}

// ============================================================
// BALANCE SHEET
// ============================================================

class _BalanceSheetCard extends StatelessWidget {
  final Map<String, dynamic> assets;
  final Map<String, dynamic> liabilities;
  final Map<String, dynamic> balanceSheet;
  final String Function(dynamic) money;

  const _BalanceSheetCard({
    required this.assets,
    required this.liabilities,
    required this.balanceSheet,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return _ExpandableCard(
      icon: Icons.account_balance_outlined,
      title: 'Balance Sheet',
      initiallyExpanded: false,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 8,
          ),
          child: Text(
            'Assets',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),

        _SummaryRow(
          title: 'Cash in Hand',
          value: money(
            assets['cashInHand'],
          ),
        ),

        _SummaryRow(
          title: 'Cash at Bank',
          value: money(
            assets['cashAtBank'],
          ),
        ),

        _SummaryRow(
          title: 'Bills Receivable',
          value: money(
            assets['billsReceivable'],
          ),
        ),

        _SummaryRow(
          title: 'Stock',
          value: money(
            assets['stock'],
          ),
        ),

        _SummaryRow(
          title: 'Land & Building',
          value: money(
            assets['landAndBuilding'],
          ),
        ),

        _SummaryRow(
          title: 'Office Building',
          value: money(
            assets['officeBuilding'],
          ),
        ),

        _SummaryRow(
          title: 'Office Equipment',
          value: money(
            assets['officeEquipment'],
          ),
        ),

        const Divider(height: 20),

        _SummaryRow(
          title: 'Total Assets',
          value: money(
            balanceSheet['totalAssets'],
          ),
          valueColor: const Color(
            0xFF1649E8,
          ),
          bold: true,
        ),

        const SizedBox(height: 12),

        const Padding(
          padding: EdgeInsets.only(
            bottom: 8,
          ),
          child: Text(
            'Liabilities',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),

        _SummaryRow(
          title: 'Bills Payable',
          value: money(
            liabilities['billsPayable'],
          ),
        ),

        _SummaryRow(
          title: 'Capital',
          value: money(
            liabilities['capital'],
          ),
        ),

        _SummaryRow(
          title: 'Net Profit',
          value: money(
            liabilities['netProfit'],
          ),
        ),

        const Divider(height: 20),

        _SummaryRow(
          title: 'Total Liabilities',
          value: money(
            balanceSheet['totalLiabilities'],
          ),
          valueColor: const Color(
            0xFF1649E8,
          ),
          bold: true,
        ),
      ],
    );
  }
}

// ============================================================
// EXPANDABLE CARD
// ============================================================

class _ExpandableCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _ExpandableCard({
    required this.icon,
    required this.title,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  State<_ExpandableCard> createState() =>
      _ExpandableCardState();
}

class _ExpandableCardState
    extends State<_ExpandableCard> {
  late bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE3E6ED),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            borderRadius:
            BorderRadius.circular(14),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 22,
                    color: const Color(
                      0xFF172E90,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(
                          0xFF1236B7,
                        ),
                        fontWeight:
                        FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          if (expanded)
            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                14,
              ),
              child: Column(
                children: widget.children,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY ROW
// ============================================================

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: bold
                    ? const Color(0xFF0B1628)
                    : Colors.grey.shade700,
                fontSize: 13,
                fontWeight: bold
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ??
                  const Color(0xFF0B1628),
              fontSize: 13,
              fontWeight: bold
                  ? FontWeight.w700
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PDF BUTTONS
// ============================================================

class _PdfButtons extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const _PdfButtons({
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onDownload,
            icon: const Icon(
              Icons.download_outlined,
            ),
            label: const Text(
              'Download PDF',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(
              Icons.share_outlined,
            ),
            label: const Text(
              'Share PDF',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}