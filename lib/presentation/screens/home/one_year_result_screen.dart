import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:excel/excel.dart' as excel_package;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class OneYearResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const OneYearResultScreen({super.key, required this.resultData});

  String _formatCurrency(dynamic value) {
    if (value is num) {
      String str = value.abs().toStringAsFixed(0);
      str = str.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
      return value < 0 ? '-₹ $str' : '₹ $str';
    }
    return '₹ ${value ?? 0}';
  }

  String _formatCamelCase(String text) {
    if (text.isEmpty) return text;

    String result = text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => ' ${m.group(0)}',
    );

    result = result[0].toUpperCase() + result.substring(1);
    result = result.replaceAll('_', ' ');

    return result;
  }


  Future<void> _downloadExcelReport() async {
    try {
      final excel = excel_package.Excel.createExcel();

      final ownerName = resultData["ownerName"]?.toString() ?? "Business Owner";
      final businessName = resultData["businessName"]?.toString() ?? "X & CO";
      final sales = (resultData["sales"] ?? 1200000) as num;


      final year1Data = resultData["firstYear"];
      final year1Trading = year1Data?["oneYearTrading"]?["yearOne"] ?? {};
      final year1PL = year1Data?["pl"]?["profitLoss"] ?? {};
      final year1BS = year1Data?["balanceSheet"]?["bs"] ?? {};
      final year1Assets = year1BS["assets"] ?? {};
      final year1Liabilities = year1BS["liabilities"] ?? {};


      final year2Data = resultData["secondYear"];
      final year2Trading = year2Data?["oneYearTrading"]?["yearOne"] ?? {};
      final year2PL = year2Data?["pl"]?["profitLoss"] ?? {};
      final year2BS = year2Data?["balanceSheet"]?["bs"] ?? {};
      final year2Assets = year2BS["assets"] ?? {};
      final year2Liabilities = year2BS["liabilities"] ?? {};


      final year3Data = resultData["thirdYear"];
      final year3Trading = year3Data?["oneYearTrading"]?["yearOne"] ?? {};
      final year3PL = year3Data?["pl"]?["profitLoss"] ?? {};
      final year3BS = year3Data?["balanceSheet"]?["bs"] ?? {};
      final year3Assets = year3BS["assets"] ?? {};
      final year3Liabilities = year3BS["liabilities"] ?? {};


      final trading1Sheet = excel['TRADING YEAR 1 OR ACTUAL'];


      trading1Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('TRADING ACCOUNT OF $ownerName FOR THE YEAR ENDING 31ST MARCH 2025 (ACTUAL)');


      trading1Sheet.cell(excel_package.CellIndex.indexByString('A3')).value = excel_package.TextCellValue('Dr');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('B3')).value = excel_package.TextCellValue('Amount(Rs)');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('C3')).value = excel_package.TextCellValue('Cr');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('D3')).value = excel_package.TextCellValue('Amount(Rs)');


      int row = 4;
      year1Trading.forEach((key, value) {
        trading1Sheet.cell(excel_package.CellIndex.indexByString('A$row')).value =
            excel_package.TextCellValue('To $key');
        trading1Sheet.cell(excel_package.CellIndex.indexByString('B$row')).value =
            excel_package.DoubleCellValue(value is num ? value.toDouble() : 0);
        row++;
      });


      final grossProfit1 = year1Trading["grossProfitLoss"] ?? 0;
      trading1Sheet.cell(excel_package.CellIndex.indexByString('A14')).value =
          excel_package.TextCellValue('To Gross Profit transferred to profit and loss account');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('B14')).value =
          excel_package.DoubleCellValue(grossProfit1 is num ? grossProfit1.toDouble() : 0);


      trading1Sheet.cell(excel_package.CellIndex.indexByString('C4')).value =
          excel_package.TextCellValue('By Sales');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('D4')).value =
          excel_package.DoubleCellValue(year1Trading["sales"] is num ? year1Trading["sales"].toDouble() : 0);


      trading1Sheet.cell(excel_package.CellIndex.indexByString('A15')).value = excel_package.TextCellValue('');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('B15')).value = excel_package.FormulaCellValue('SUM(B4:B14)');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('C15')).value = excel_package.TextCellValue('');
      trading1Sheet.cell(excel_package.CellIndex.indexByString('D15')).value = excel_package.FormulaCellValue('SUM(D4:D14)');


      final pl1Sheet      = excel['PL YEAR 1 OR ACTUAL'];

      pl1Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('PROFIT AND LOSS ACCOUNT OF $ownerName FOR THE YEAR ENDING 31ST MARCH 2025 (ACTUAL)');

      pl1Sheet.cell(excel_package.CellIndex.indexByString('A3')).value = excel_package.TextCellValue('Dr');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('B3')).value = excel_package.TextCellValue('Amount(Rs)');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('C3')).value = excel_package.TextCellValue('Cr');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('D3')).value = excel_package.TextCellValue('Amount(Rs)');


      row = 4;
      year1PL.forEach((key, value) {
        pl1Sheet.cell(excel_package.CellIndex.indexByString('A$row')).value =
            excel_package.TextCellValue('To $key');
        pl1Sheet.cell(excel_package.CellIndex.indexByString('B$row')).value =
            excel_package.DoubleCellValue(value is num ? value.toDouble() : 0);
        row++;
      });


      pl1Sheet.cell(excel_package.CellIndex.indexByString('C4')).value =
          excel_package.TextCellValue('By Gross Profit');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('D4')).value =
          excel_package.DoubleCellValue(grossProfit1 is num ? grossProfit1.toDouble() : 0);


      final netProfit1 = year1PL["netProfit"] ?? 0;
      pl1Sheet.cell(excel_package.CellIndex.indexByString('A17')).value =
          excel_package.TextCellValue('To Net Profit\n(Transferred to Capital Account)');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('B17')).value =
          excel_package.DoubleCellValue(netProfit1 is num ? netProfit1.toDouble() : 0);


      pl1Sheet.cell(excel_package.CellIndex.indexByString('A18')).value = excel_package.TextCellValue('');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('B18')).value = excel_package.FormulaCellValue('SUM(B4:B17)');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('C18')).value = excel_package.TextCellValue('');
      pl1Sheet.cell(excel_package.CellIndex.indexByString('D18')).value = excel_package.FormulaCellValue('SUM(D4:D17)');


      final bs1Sheet      = excel['BS YEAR 1 OR ACTUAL'];

      bs1Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('Balance Sheet of $ownerName as on 31st March 2025');

      bs1Sheet.cell(excel_package.CellIndex.indexByString('A3')).value = excel_package.TextCellValue('Liabilities');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('B3')).value = excel_package.TextCellValue('Amount(Rs)');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('C3')).value = excel_package.TextCellValue('Assets');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('D3')).value = excel_package.TextCellValue('Amount(Rs)');


      row = 4;
      year1Liabilities.forEach((key, value) {
        bs1Sheet.cell(excel_package.CellIndex.indexByString('A$row')).value =
            excel_package.TextCellValue(key.toString());
        bs1Sheet.cell(excel_package.CellIndex.indexByString('B$row')).value =
            excel_package.DoubleCellValue(value is num ? value.toDouble() : 0);
        row++;
      });


      final totalAssets1 = year1BS["totalAssets"] ?? 0;
      final totalLiabilities1 = year1BS["totalLiabilities"] ?? 0;

      bs1Sheet.cell(excel_package.CellIndex.indexByString('A5')).value =
          excel_package.TextCellValue('Capital');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('B5')).value =
          excel_package.FormulaCellValue('=D8-B4-B6');

      bs1Sheet.cell(excel_package.CellIndex.indexByString('A6')).value =
          excel_package.TextCellValue('ADD: Net Profit');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('B6')).value =
          excel_package.DoubleCellValue(netProfit1 is num ? netProfit1.toDouble() : 0);


      row = 4;
      year1Assets.forEach((key, value) {
        bs1Sheet.cell(excel_package.CellIndex.indexByString('C$row')).value =
            excel_package.TextCellValue(key.toString());
        bs1Sheet.cell(excel_package.CellIndex.indexByString('D$row')).value =
            excel_package.DoubleCellValue(value is num ? value.toDouble() : 0);
        row++;
      });


      bs1Sheet.cell(excel_package.CellIndex.indexByString('A8')).value = excel_package.TextCellValue('');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('B8')).value = excel_package.FormulaCellValue('SUM(B4:B7)');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('C8')).value = excel_package.TextCellValue('');
      bs1Sheet.cell(excel_package.CellIndex.indexByString('D8')).value = excel_package.FormulaCellValue('SUM(D4:D7)');


      final trading2Sheet = excel['TRADING YEAR 2 OR ESTIMATED'];
      trading2Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('TRADING ACCOUNT OF $ownerName FOR THE YEAR ENDING 31ST MARCH 2026 (ESTIMATED)');


      row = 4;
      year2Trading.forEach((key, value) {
        trading2Sheet.cell(excel_package.CellIndex.indexByString('A$row')).value =
            excel_package.TextCellValue('To $key');
        trading2Sheet.cell(excel_package.CellIndex.indexByString('B$row')).value =
            excel_package.DoubleCellValue(value is num ? value.toDouble() : 0);
        row++;
      });


      final pl2Sheet      = excel['PL YEAR 2 OR ESTIMATED'];
      pl2Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('PROFIT AND LOSS ACCOUNT OF $ownerName FOR THE YEAR ENDING 31ST MARCH 2026 (ESTIMATED)');


      final bs2Sheet      = excel['BS YEAR 2 OR ESTIMATED'];
      bs2Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('Balance Sheet of $ownerName as on 31st March 2026 (ESTIMATED)');


      final trading3Sheet = excel['TRADING YEAR 3 OR PROJECTED'];
      trading3Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('TRADING ACCOUNT OF $ownerName FOR THE YEAR ENDING 31ST MARCH 2027 (PROJECTED)');


      final pl3Sheet      = excel['PL YEAR 3 OR PROJECTED'];
      pl3Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('PROFIT AND LOSS ACCOUNT OF $ownerName FOR THE YEAR ENDING 31ST MARCH 2027 (PROJECTED)');


      final bs3Sheet      = excel['BS YEAR 3 OR PROJECTED'];
      bs3Sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
          excel_package.TextCellValue('Balance Sheet of $ownerName as on 31st March 2027 (PROJECTED)');


      final sales2 = year2Trading["sales"] ?? 0;
      if (sales2 is num && sales2 > 0) {
        trading2Sheet.cell(excel_package.CellIndex.indexByString('D4')).value =
            excel_package.DoubleCellValue(sales2.toDouble());


        trading2Sheet.cell(excel_package.CellIndex.indexByString('B4')).value =
            excel_package.FormulaCellValue('=0.018*D4'); // Opening Stock
        trading2Sheet.cell(excel_package.CellIndex.indexByString('B5')).value =
            excel_package.FormulaCellValue('=0.3*D4'); // Purchases
        trading2Sheet.cell(excel_package.CellIndex.indexByString('B14')).value =
            excel_package.FormulaCellValue('=0.48*D4'); // Gross Profit

        trading2Sheet.cell(excel_package.CellIndex.indexByString('D5')).value =
            excel_package.FormulaCellValue('=0.08*D4'); // Closing Stock
      }


      final sales3 = year3Trading["sales"] ?? 0;
      if (sales3 is num && sales3 > 0) {
        trading3Sheet.cell(excel_package.CellIndex.indexByString('D4')).value =
            excel_package.DoubleCellValue(sales3.toDouble());

        trading3Sheet.cell(excel_package.CellIndex.indexByString('B4')).value =
            excel_package.FormulaCellValue('=0.018*D4');
        trading3Sheet.cell(excel_package.CellIndex.indexByString('B5')).value =
            excel_package.FormulaCellValue('=0.3*D4');
        trading3Sheet.cell(excel_package.CellIndex.indexByString('B14')).value =
            excel_package.FormulaCellValue('=0.48*D4');

        trading3Sheet.cell(excel_package.CellIndex.indexByString('D5')).value =
            excel_package.FormulaCellValue('=0.08*D4');
      }


      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/financial_projection_$timestamp.xlsx';

      final file = File(filePath);
      final bytes = excel.save();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await OpenFile.open(filePath);
      } else {
        debugPrint('Failed to generate Excel file');
      }
    } catch (e) {
      debugPrint('Excel error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("3-Year Financial Projection"),
          centerTitle: true,
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 4,

          actions: [

            IconButton(
              icon: const Icon(Icons.download),
              tooltip: "Download Excel Report",
              onPressed: _downloadExcelReport,
            ),
          ],

          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Year 1"),
              Tab(text: "Year 2"),
              Tab(text: "Year 3"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _buildYearView("firstYear"),
            _buildYearView("secondYear"),
            _buildYearView("thirdYear"),
          ],
        ),
      ),
    );
  }

  Widget _buildYearView(String yearKey) {
    final year = resultData[yearKey];
    if (year == null) {
      return const Center(child: Text("No data available"));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          _buildProfitSummaryCard(year),
          const SizedBox(height: 20),


          _buildKeyMetricsCards(year),
          const SizedBox(height: 24),


          ExpandableAccountSection(
            title: "Trading Account",
            subtitle: "Revenue & Cost of Goods Sold",
            icon: Icons.trending_up,
            color: Colors.blue.shade700,
            data: year["oneYearTrading"]?["yearOne"] ?? {},
          ),
          const SizedBox(height: 12),

          ExpandableAccountSection(
            title: "Profit & Loss",
            subtitle: "Operational Performance",
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF1A237E),
            data: year["pl"]?["profitLoss"] ?? {},
          ),
          const SizedBox(height: 12),

          ExpandableAccountSection(
            title: "Balance Sheet - Assets",
            subtitle: "Financial Position",
            icon: Icons.business_center,
            color: Colors.purple.shade700,
            data: year["balanceSheet"]?["bs"]?["assets"] ?? {},
          ),
          const SizedBox(height: 12),

          ExpandableAccountSection(
            title: "Balance Sheet - Liabilities",
            subtitle: "Financial Obligations",
            icon: Icons.assignment,
            color: Colors.orange.shade700,
            data: year["balanceSheet"]?["bs"]?["liabilities"] ?? {},
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfitSummaryCard(Map<String, dynamic> year) {
    final trading = year["oneYearTrading"]?["yearOne"] ?? {};
    final pl = year["pl"]?["profitLoss"] ?? {};
    final netProfit = (pl["netProfit"] ?? 0) as num;
    final isProfit = netProfit >= 0;
    final sales = trading["sales"] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 110,
            width: 110,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 4,
                centerSpaceRadius: 38,
                sections: [
                  PieChartSectionData(
                    value: sales.abs().toDouble(),
                    color: const Color(0xFFFFA000),
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (sales - netProfit).abs().toDouble(),
                    color: const Color(0xFF1A237E),
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: netProfit.abs().toDouble(),
                    color: isProfit
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700,
                    radius: 18,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProfit ? "Net Profit" : "Net Loss",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(netProfit),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isProfit
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isProfit
                      ? "Business is Profitable"
                      : "Business is in Loss",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCards(Map<String, dynamic> year) {
    final trading = year["oneYearTrading"]?["yearOne"] ?? {};
    final pl = year["pl"]?["profitLoss"] ?? {};
    final netProfit = (pl["netProfit"] ?? 0) as num;
    final isProfit = netProfit >= 0;
    final sales = trading["sales"] ?? 0;
    final grossProfit = trading["grossProfitLoss"] ?? 0;
    final totalAssets = year["balanceSheet"]?["totalAssets"] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Sales",
                sales,
                Icons.trending_up,
                Colors.blue.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                "Gross Profit",
                grossProfit,
                Icons.attach_money,
                Colors.orange.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Net Profit",
                netProfit,
                Icons.account_balance_wallet,
                isProfit ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                "Total Assets",
                totalAssets,
                Icons.business,
                Colors.purple.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, dynamic value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ExpandableAccountSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> data;

  const ExpandableAccountSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.data,
  });

  @override
  State<ExpandableAccountSection> createState() => _ExpandableAccountSectionState();
}

class _ExpandableAccountSectionState extends State<ExpandableAccountSection> {
  bool _isExpanded = false;

  String _formatCurrency(dynamic value) {
    if (value is num) {
      String str = value.abs().toStringAsFixed(0);
      str = str.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
      return value < 0 ? '-₹ $str' : '₹ $str';
    }
    return '₹ ${value ?? 0}';
  }

  String _formatCamelCase(String text) {
    if (text.isEmpty) return text;

    String result = text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => ' ${m.group(0)}',
    );

    result = result[0].toUpperCase() + result.substring(1);
    result = result.replaceAll('_', ' ');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [

          ListTile(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            leading: Icon(widget.icon, color: widget.color),
            title: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.color,
            ),
          ),


          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  ...widget.data.entries.map((e) {
                    final num val = e.value is num ? e.value : 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'To ${_formatCamelCase(e.key)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            _formatCurrency(val),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: val >= 0
                                  ? const Color(0xFF002D72)
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}