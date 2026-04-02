import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:math';

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

  // ✅ Profile sheet create karta hai (pehla page)
  void _createProfileSheet(excel_package.Excel excel, Map<String, dynamic> data) {
    final sheet = excel['Profile'];

    // User data extract karo (fallback "Not Provided" agar nahi hai)
    final fullName = data['ownerName']?.toString() ?? data['fullName']?.toString() ?? 'Not Provided';
    final email = data['email']?.toString() ?? 'Not Provided';
    final phone = data['phone']?.toString() ?? data['mobile']?.toString() ?? 'Not Provided';
    final address = data['address']?.toString() ?? 'Not Provided';
    final dobRaw = data['dob']?.toString() ?? 'Not Provided';

    // DOB format (if already DD/MM/YYYY then same else try to convert)
    String formattedDob = dobRaw;
    if (dobRaw != 'Not Provided' && dobRaw.contains('-')) {
      try {
        final parts = dobRaw.split('-');
        if (parts.length == 3) {
          formattedDob = '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      } catch (e) {}
    }

    // Heading
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
        excel_package.TextCellValue('USER PROFILE');
    sheet.cell(excel_package.CellIndex.indexByString('A2')).value =
        excel_package.TextCellValue('----------------------------------------');

    // Data rows
    sheet.cell(excel_package.CellIndex.indexByString('A4')).value = excel_package.TextCellValue('Full Name:');
    sheet.cell(excel_package.CellIndex.indexByString('B4')).value = excel_package.TextCellValue(fullName);

    sheet.cell(excel_package.CellIndex.indexByString('A5')).value = excel_package.TextCellValue('Date of Birth:');
    sheet.cell(excel_package.CellIndex.indexByString('B5')).value = excel_package.TextCellValue(formattedDob);

    sheet.cell(excel_package.CellIndex.indexByString('A6')).value = excel_package.TextCellValue('Mobile Number:');
    sheet.cell(excel_package.CellIndex.indexByString('B6')).value = excel_package.TextCellValue(phone);

    sheet.cell(excel_package.CellIndex.indexByString('A7')).value = excel_package.TextCellValue('Email Address:');
    sheet.cell(excel_package.CellIndex.indexByString('B7')).value = excel_package.TextCellValue(email);

    sheet.cell(excel_package.CellIndex.indexByString('A8')).value = excel_package.TextCellValue('Address:');
    sheet.cell(excel_package.CellIndex.indexByString('B8')).value = excel_package.TextCellValue(address);

    sheet.cell(excel_package.CellIndex.indexByString('A10')).value =
        excel_package.TextCellValue('Report Generated:');
    sheet.cell(excel_package.CellIndex.indexByString('B10')).value =
        excel_package.TextCellValue(DateTime.now().toString().split(' ')[0]);

    // Auto-fit ke liye column width set karo (optional)
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 40);
  }

  Future<void> _downloadExcelReport() async {
    try {
      final excel = excel_package.Excel.createExcel();

      // Delete default Sheet1 agar ho
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // ✅ Step 1: Profile sheet pehle page pe
      _createProfileSheet(excel, resultData);

      // Step 2: Baaki sheets (financial data)
      final ownerName = resultData["ownerName"]?.toString() ?? "Business Owner";

      num _safeNum(dynamic value) {
        if (value == null) return 0;
        if (value is num) return value;
        if (value is String) {
          final parsed = num.tryParse(value);
          return parsed ?? 0;
        }
        return 0;
      }

      final years = [
        {"key": "firstYear", "label": "ACTUAL", "yearEnd": "31ST MARCH 2025"},
        {"key": "secondYear", "label": "ESTIMATED", "yearEnd": "31ST MARCH 2026"},
        {"key": "thirdYear", "label": "PROJECTED", "yearEnd": "31ST MARCH 2027"},
      ];

      for (var yearInfo in years) {
        final yearKey = yearInfo["key"] as String;
        final yearLabel = yearInfo["label"] as String;
        final yearEnd = yearInfo["yearEnd"] as String;

        final yearData = resultData[yearKey] ?? {};
        final tradingData = yearData["oneYearTrading"]?["yearOne"] ?? {};
        final plData = yearData["pl"]?["profitLoss"] ?? {};
        final bsData = yearData["balanceSheet"]?["bs"] ?? {};
        final assets = bsData["assets"] ?? {};
        final liabilities = bsData["liabilities"] ?? {};

        final tradingDebitItems = <String, num>{
          "openingStock": _safeNum(tradingData["openingStock"]),
          "purchases": _safeNum(tradingData["purchases"]),
          "lessReturn": _safeNum(tradingData["lessReturn"]),
          "carriageInwards": _safeNum(tradingData["carriageInwards"]),
          "cartage": _safeNum(tradingData["cartage"]),
          "dockCharges": _safeNum(tradingData["dockCharges"]),
          "wages": _safeNum(tradingData["wages"]),
          "duty": _safeNum(tradingData["duty"]),
          "freight": _safeNum(tradingData["freight"]),
          "ClearingCharges": _safeNum(tradingData["ClearingCharges"]),
          "otherExpenses": _safeNum(tradingData["otherExpenses"]),
          "grossProfitLoss": _safeNum(tradingData["grossProfitLoss"]),
        };

        final tradingCreditItems = <String, num>{
          "sales": _safeNum(tradingData["sales"]),
          "closingStock": _safeNum(tradingData["closingStock"]),
        };

        final plDebitItems = <String, num>{
          "salaries": _safeNum(plData["salaries"]),
          "rent": _safeNum(plData["rent"]),
          "discountAllowed": _safeNum(plData["discountAllowed"]),
          "commissionPaid": _safeNum(plData["commissionPaid"]),
          "insurance": _safeNum(plData["insurance"]),
          "bankCharges": _safeNum(plData["bankCharges"]),
          "legalCharges": _safeNum(plData["legalCharges"]),
          "repairs": _safeNum(plData["repairs"]),
          "advertising": _safeNum(plData["advertising"]),
          "tradeExpenses": _safeNum(plData["tradeExpenses"]),
          "officeExpenses": _safeNum(plData["officeExpenses"]),
          "badDebts": _safeNum(plData["badDebts"]),
          "travellingExpenses": _safeNum(plData["travellingExpenses"]),
          "sellingAndDistribution": _safeNum(plData["sellingAndDistribution"]),
          "netProfit": _safeNum(plData["netProfit"]),
        };

        final plCreditItems = <String, num>{
          "grossProfitBf": _safeNum(plData["grossProfitBf"]),
          "interestReceived": _safeNum(plData["interestReceived"]),
          "discountReceived": _safeNum(plData["discountReceived"]),
          "commissionReceived": _safeNum(plData["commissionReceived"]),
          "otherReceipts": _safeNum(plData["otherReceipts"]),
        };

        final assetsCalculations = <String, num>{
          "cashInHand": _safeNum(assets["cashInHand"]),
          "cashAtBank": _safeNum(assets["cashAtBank"]),
          "billsReceivable": _safeNum(assets["billsReceivable"]),
          "landAndBuilding": _safeNum(assets["landAndBuilding"]),
          "stock": _safeNum(assets["stock"]),
          "officeBuilding": _safeNum(assets["officeBuilding"]),
          "officeEquipment": _safeNum(assets["officeEquipment"]),
        };

        final liabilitiesCalculations = <String, num>{
          "billsPayable": _safeNum(liabilities["billsPayable"]),
          "capital": _safeNum(liabilities["capital"]),
          "netProfit": _safeNum(liabilities["netProfit"]),
        };

        final totalAssets = _safeNum(yearData["balanceSheet"]?["totalAssets"]);
        final totalLiabilities = _safeNum(yearData["balanceSheet"]?["totalLiabilities"]);

        _createTradingSheet(
            excel,
            'TRADING YEAR ${years.indexOf(yearInfo) + 1} OR $yearLabel',
            ownerName,
            tradingDebitItems,
            tradingCreditItems,
            yearEnd,
            yearLabel
        );

        _createPLSheet(
            excel,
            'PL YEAR ${years.indexOf(yearInfo) + 1} OR $yearLabel',
            ownerName,
            plDebitItems,
            plCreditItems,
            yearEnd,
            yearLabel
        );

        _createBalanceSheet(
            excel,
            'BS YEAR ${years.indexOf(yearInfo) + 1} OR $yearLabel',
            ownerName,
            assetsCalculations,
            liabilitiesCalculations,
            totalAssets,
            totalLiabilities,
            yearEnd,
            yearLabel
        );
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

  void _createTradingSheet(
      excel_package.Excel excel,
      String sheetName,
      String ownerName,
      Map<String, num> debitItems,
      Map<String, num> creditItems,
      String yearEnd,
      String yearLabel
      ) {
    final sheet = excel[sheetName];
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
        excel_package.TextCellValue('TRADING ACCOUNT OF $ownerName FOR THE YEAR ENDING $yearEnd ($yearLabel)');
    sheet.cell(excel_package.CellIndex.indexByString('A3')).value = excel_package.TextCellValue('Dr');
    sheet.cell(excel_package.CellIndex.indexByString('B3')).value = excel_package.TextCellValue('Amount(Rs)');
    sheet.cell(excel_package.CellIndex.indexByString('C3')).value = excel_package.TextCellValue('Cr');
    sheet.cell(excel_package.CellIndex.indexByString('D3')).value = excel_package.TextCellValue('Amount(Rs)');

    final debitItemList = [
      {"key": "openingStock", "label": "To Opening Stock"},
      {"key": "purchases", "label": "To Purchases"},
      {"key": "lessReturn", "label": "Less: Returns"},
      {"key": "carriageInwards", "label": "To Carriage Inwards"},
      {"key": "cartage", "label": "To Cartage"},
      {"key": "dockCharges", "label": "To Dock Charges"},
      {"key": "wages", "label": "To Wages"},
      {"key": "duty", "label": "To Duty"},
      {"key": "freight", "label": "To Freight"},
      {"key": "ClearingCharges", "label": "To Clearing Charges"},
      {"key": "otherExpenses", "label": "To Other Expenses"},
    ];

    int row = 4;
    for (var item in debitItemList) {
      final value = debitItems[item["key"]] ?? 0;
      sheet.cell(excel_package.CellIndex.indexByString('A$row')).value = excel_package.TextCellValue(item["label"]!);
      sheet.cell(excel_package.CellIndex.indexByString('B$row')).value = excel_package.DoubleCellValue(value.toDouble());
      row++;
    }

    sheet.cell(excel_package.CellIndex.indexByString('A15')).value =
        excel_package.TextCellValue('To Gross Profit transferred to profit and loss account');
    sheet.cell(excel_package.CellIndex.indexByString('B15')).value =
        excel_package.DoubleCellValue((debitItems["grossProfitLoss"] ?? 0).toDouble());

    final creditItemList = [
      {"key": "sales", "label": "By Sales"},
      {"key": "closingStock", "label": "By Closing Stock"},
    ];

    row = 4;
    for (var item in creditItemList) {
      final value = creditItems[item["key"]] ?? 0;
      sheet.cell(excel_package.CellIndex.indexByString('C$row')).value = excel_package.TextCellValue(item["label"]!);
      sheet.cell(excel_package.CellIndex.indexByString('D$row')).value = excel_package.DoubleCellValue(value.toDouble());
      row++;
    }

    num totalDebit = 0;
    for (var item in debitItemList) {
      totalDebit += debitItems[item["key"]] ?? 0;
    }
    totalDebit += debitItems["grossProfitLoss"] ?? 0;

    num totalCredit = 0;
    for (var item in creditItemList) {
      totalCredit += creditItems[item["key"]] ?? 0;
    }

    final totalRow = 16;
    sheet.cell(excel_package.CellIndex.indexByString('A$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('B$totalRow')).value = excel_package.DoubleCellValue(totalDebit.toDouble());
    sheet.cell(excel_package.CellIndex.indexByString('C$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('D$totalRow')).value = excel_package.DoubleCellValue(totalCredit.toDouble());
  }

  void _createPLSheet(
      excel_package.Excel excel,
      String sheetName,
      String ownerName,
      Map<String, num> debitItems,
      Map<String, num> creditItems,
      String yearEnd,
      String yearLabel
      ) {
    final sheet = excel[sheetName];
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
        excel_package.TextCellValue('PROFIT AND LOSS ACCOUNT OF $ownerName FOR THE YEAR ENDING $yearEnd ($yearLabel)');
    sheet.cell(excel_package.CellIndex.indexByString('A3')).value = excel_package.TextCellValue('Dr');
    sheet.cell(excel_package.CellIndex.indexByString('B3')).value = excel_package.TextCellValue('Amount(Rs)');
    sheet.cell(excel_package.CellIndex.indexByString('C3')).value = excel_package.TextCellValue('Cr');
    sheet.cell(excel_package.CellIndex.indexByString('D3')).value = excel_package.TextCellValue('Amount(Rs)');

    final debitItemList = [
      {"key": "salaries", "label": "To Salaries"},
      {"key": "rent", "label": "To Rent"},
      {"key": "discountAllowed", "label": "To Discount Allowed"},
      {"key": "commissionPaid", "label": "To Commission Paid"},
      {"key": "insurance", "label": "To Insurance"},
      {"key": "bankCharges", "label": "To Bank Charges"},
      {"key": "legalCharges", "label": "To Legal Charges"},
      {"key": "repairs", "label": "To Repairs"},
      {"key": "advertising", "label": "To Advertising"},
      {"key": "tradeExpenses", "label": "To Trade Expenses"},
      {"key": "officeExpenses", "label": "To Office Expenses"},
      {"key": "badDebts", "label": "To Bad Debts"},
      {"key": "travellingExpenses", "label": "To Travelling Expenses"},
      {"key": "sellingAndDistribution", "label": "To Selling & Distribution"},
    ];

    int row = 4;
    for (var item in debitItemList) {
      final value = debitItems[item["key"]] ?? 0;
      sheet.cell(excel_package.CellIndex.indexByString('A$row')).value = excel_package.TextCellValue(item["label"]!);
      sheet.cell(excel_package.CellIndex.indexByString('B$row')).value = excel_package.DoubleCellValue(value.toDouble());
      row++;
    }

    sheet.cell(excel_package.CellIndex.indexByString('A18')).value =
        excel_package.TextCellValue('To Net Profit (Transferred to Capital Account)');
    sheet.cell(excel_package.CellIndex.indexByString('B18')).value =
        excel_package.DoubleCellValue((debitItems["netProfit"] ?? 0).toDouble());

    final creditItemList = [
      {"key": "grossProfitBf", "label": "By Gross Profit b/f"},
      {"key": "interestReceived", "label": "By Interest Received"},
      {"key": "discountReceived", "label": "By Discount Received"},
      {"key": "commissionReceived", "label": "By Commission Received"},
      {"key": "otherReceipts", "label": "By Other Receipts"},
    ];

    row = 4;
    for (var item in creditItemList) {
      final value = creditItems[item["key"]] ?? 0;
      sheet.cell(excel_package.CellIndex.indexByString('C$row')).value = excel_package.TextCellValue(item["label"]!);
      sheet.cell(excel_package.CellIndex.indexByString('D$row')).value = excel_package.DoubleCellValue(value.toDouble());
      row++;
    }

    num totalDebit = 0;
    for (var item in debitItemList) {
      totalDebit += debitItems[item["key"]] ?? 0;
    }
    totalDebit += debitItems["netProfit"] ?? 0;

    num totalCredit = 0;
    for (var item in creditItemList) {
      totalCredit += creditItems[item["key"]] ?? 0;
    }

    final totalRow = 19;
    sheet.cell(excel_package.CellIndex.indexByString('A$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('B$totalRow')).value = excel_package.DoubleCellValue(totalDebit.toDouble());
    sheet.cell(excel_package.CellIndex.indexByString('C$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('D$totalRow')).value = excel_package.DoubleCellValue(totalCredit.toDouble());
  }

  void _createBalanceSheet(
      excel_package.Excel excel,
      String sheetName,
      String ownerName,
      Map<String, num> assets,
      Map<String, num> liabilities,
      num totalAssets,
      num totalLiabilities,
      String yearEnd,
      String yearLabel
      ) {
    final sheet = excel[sheetName];
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value =
        excel_package.TextCellValue('Balance Sheet of $ownerName as on $yearEnd ($yearLabel)');
    sheet.cell(excel_package.CellIndex.indexByString('A3')).value = excel_package.TextCellValue('Liabilities');
    sheet.cell(excel_package.CellIndex.indexByString('B3')).value = excel_package.TextCellValue('Amount(Rs)');
    sheet.cell(excel_package.CellIndex.indexByString('C3')).value = excel_package.TextCellValue('Assets');
    sheet.cell(excel_package.CellIndex.indexByString('D3')).value = excel_package.TextCellValue('Amount(Rs)');

    final liabilityItems = [
      {"key": "capital", "label": "Capital"},
      {"key": "netProfit", "label": "Add: Net Profit"},
      {"key": "billsPayable", "label": "Bills Payable"},
    ];

    int row = 4;
    for (var item in liabilityItems) {
      final value = liabilities[item["key"]] ?? 0;
      sheet.cell(excel_package.CellIndex.indexByString('A$row')).value = excel_package.TextCellValue(item["label"]!);
      sheet.cell(excel_package.CellIndex.indexByString('B$row')).value = excel_package.DoubleCellValue(value.toDouble());
      row++;
    }

    final assetItems = [
      {"key": "cashInHand", "label": "Cash In Hand"},
      {"key": "cashAtBank", "label": "Cash at Bank"},
      {"key": "billsReceivable", "label": "Bills Receivable"},
      {"key": "stock", "label": "Stock"},
      {"key": "landAndBuilding", "label": "Land & Building"},
      {"key": "officeBuilding", "label": "Office Building"},
      {"key": "officeEquipment", "label": "Office Equipment"},
    ];

    row = 4;
    for (var item in assetItems) {
      final value = assets[item["key"]] ?? 0;
      sheet.cell(excel_package.CellIndex.indexByString('C$row')).value = excel_package.TextCellValue(item["label"]!);
      sheet.cell(excel_package.CellIndex.indexByString('D$row')).value = excel_package.DoubleCellValue(value.toDouble());
      row++;
    }

    final totalRow = max(liabilityItems.length, assetItems.length) + 4;
    sheet.cell(excel_package.CellIndex.indexByString('A$totalRow')).value = excel_package.TextCellValue('Total Liabilities');
    sheet.cell(excel_package.CellIndex.indexByString('B$totalRow')).value = excel_package.DoubleCellValue(totalLiabilities.toDouble());
    sheet.cell(excel_package.CellIndex.indexByString('C$totalRow')).value = excel_package.TextCellValue('Total Assets');
    sheet.cell(excel_package.CellIndex.indexByString('D$totalRow')).value = excel_package.DoubleCellValue(totalAssets.toDouble());
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

    final tradingData = year["oneYearTrading"]?["yearOne"] ?? {};
    final plData = year["pl"]?["profitLoss"] ?? {};
    final bsData = year["balanceSheet"]?["bs"] ?? {};

    num _safeNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        return parsed ?? 0;
      }
      return 0;
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
            data: {
              "openingStock": _safeNum(tradingData["openingStock"]),
              "purchases": _safeNum(tradingData["purchases"]),
              "lessReturn": _safeNum(tradingData["lessReturn"]),
              "carriageInwards": _safeNum(tradingData["carriageInwards"]),
              "cartage": _safeNum(tradingData["cartage"]),
              "dockCharges": _safeNum(tradingData["dockCharges"]),
              "wages": _safeNum(tradingData["wages"]),
              "duty": _safeNum(tradingData["duty"]),
              "freight": _safeNum(tradingData["freight"]),
              "ClearingCharges": _safeNum(tradingData["ClearingCharges"]),
              "otherExpenses": _safeNum(tradingData["otherExpenses"]),
              "sales": _safeNum(tradingData["sales"]),
              "closingStock": _safeNum(tradingData["closingStock"]),
              "grossProfitLoss": _safeNum(tradingData["grossProfitLoss"]),
            },
          ),
          const SizedBox(height: 12),
          ExpandableAccountSection(
            title: "Profit & Loss",
            subtitle: "Operational Performance",
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF1A237E),
            data: {
              "salaries": _safeNum(plData["salaries"]),
              "rent": _safeNum(plData["rent"]),
              "discountAllowed": _safeNum(plData["discountAllowed"]),
              "commissionPaid": _safeNum(plData["commissionPaid"]),
              "insurance": _safeNum(plData["insurance"]),
              "bankCharges": _safeNum(plData["bankCharges"]),
              "legalCharges": _safeNum(plData["legalCharges"]),
              "repairs": _safeNum(plData["repairs"]),
              "advertising": _safeNum(plData["advertising"]),
              "tradeExpenses": _safeNum(plData["tradeExpenses"]),
              "officeExpenses": _safeNum(plData["officeExpenses"]),
              "badDebts": _safeNum(plData["badDebts"]),
              "travellingExpenses": _safeNum(plData["travellingExpenses"]),
              "sellingAndDistribution": _safeNum(plData["sellingAndDistribution"]),
              "grossProfitBf": _safeNum(plData["grossProfitBf"]),
              "interestReceived": _safeNum(plData["interestReceived"]),
              "discountReceived": _safeNum(plData["discountReceived"]),
              "commissionReceived": _safeNum(plData["commissionReceived"]),
              "otherReceipts": _safeNum(plData["otherReceipts"]),
              "netProfit": _safeNum(plData["netProfit"]),
              "capital": _safeNum(plData["capital"]),
            },
          ),
          const SizedBox(height: 12),
          ExpandableAccountSection(
            title: "Balance Sheet - Assets",
            subtitle: "Financial Position",
            icon: Icons.business_center,
            color: Colors.purple.shade700,
            data: bsData["assets"] ?? {},
          ),
          const SizedBox(height: 12),
          ExpandableAccountSection(
            title: "Balance Sheet - Liabilities",
            subtitle: "Financial Obligations",
            icon: Icons.assignment,
            color: Colors.orange.shade700,
            data: bsData["liabilities"] ?? {},
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfitSummaryCard(Map<String, dynamic> year) {
    final plData = year["pl"]?["profitLoss"] ?? {};
    final tradingData = year["oneYearTrading"]?["yearOne"] ?? {};

    num _safeNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        return parsed ?? 0;
      }
      return 0;
    }

    final netProfit = _safeNum(plData["netProfit"]);
    final isProfit = netProfit >= 0;
    final sales = _safeNum(tradingData["sales"]);

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
                    color: isProfit ? const Color(0xFF2E7D32) : Colors.red.shade700,
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
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(netProfit),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? const Color(0xFF2E7D32) : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isProfit ? "Business is Profitable" : "Business is in Loss",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsCards(Map<String, dynamic> year) {
    final tradingData = year["oneYearTrading"]?["yearOne"] ?? {};
    final plData = year["pl"]?["profitLoss"] ?? {};
    final bsData = year["balanceSheet"] ?? {};

    num _safeNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value);
        return parsed ?? 0;
      }
      return 0;
    }

    final netProfit = _safeNum(plData["netProfit"]);
    final isProfit = netProfit >= 0;
    final sales = _safeNum(tradingData["sales"]);
    final grossProfit = _safeNum(tradingData["grossProfitLoss"]);
    final totalAssets = _safeNum(bsData["totalAssets"]);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("Sales", sales, Icons.trending_up, Colors.blue.shade600)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard("Gross Profit", grossProfit, Icons.attach_money, Colors.orange.shade600)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildMetricCard("Net Profit", netProfit, Icons.account_balance_wallet, isProfit ? Colors.green.shade600 : Colors.red.shade600)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard("Total Assets", totalAssets, Icons.business, Colors.purple.shade600)),
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
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(_formatCurrency(value), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
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
      str = str.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      return value < 0 ? '-₹ $str' : '₹ $str';
    }
    return '₹ ${value ?? 0}';
  }

  String _formatCamelCase(String text) {
    if (text.isEmpty) return text;
    String result = text.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}');
    result = result[0].toUpperCase() + result.substring(1);
    result = result.replaceAll('_', ' ');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            leading: Icon(widget.icon, color: widget.color),
            title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text(widget.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: widget.color),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title.contains("Trading") && (e.key == "sales" || e.key == "closingStock")
                                  ? 'By ${_formatCamelCase(e.key)}'
                                  : widget.title.contains("Profit & Loss") &&
                                  (e.key == "grossProfitBf" ||
                                      e.key == "interestReceived" ||
                                      e.key == "discountReceived" ||
                                      e.key == "commissionReceived" ||
                                      e.key == "otherReceipts")
                                  ? 'By ${_formatCamelCase(e.key)}'
                                  : 'To ${_formatCamelCase(e.key)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ),
                          Text(
                            _formatCurrency(val),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: val >= 0 ? const Color(0xFF002D72) : Colors.red.shade700),
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