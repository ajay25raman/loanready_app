import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';


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

  // ======================== PDF GENERATION (unchanged) ========================
  Future<void> _downloadExcelReport(BuildContext context) async {
    // Show loading to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );
    }

    try {
      final pdf = pw.Document();
      pdf.addPage(_buildProfilePage());

      final years = [
        {"key": "firstYear",  "label": "ACTUAL",    "yearEnd": "31ST MARCH 2025"},
        {"key": "secondYear", "label": "ESTIMATED", "yearEnd": "31ST MARCH 2026"},
        {"key": "thirdYear",  "label": "PROJECTED", "yearEnd": "31ST MARCH 2027"},
      ];

      for (var yearInfo in years) {
        final yearKey   = yearInfo["key"] as String;
        final yearLabel = yearInfo["label"] as String;
        final yearEnd   = yearInfo["yearEnd"] as String;
        final yearData  = resultData[yearKey];
        if (yearData == null) continue;
        pdf.addPage(_buildTradingPage(yearData, yearLabel, yearEnd));
        pdf.addPage(_buildPLPage(yearData, yearLabel, yearEnd));
        pdf.addPage(_buildBalanceSheetPage(yearData, yearLabel, yearEnd));
      }

      // ✅ Use temp directory — works on both Android & iOS
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${dir.path}/financial_report_$timestamp.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // ✅ Use share_plus — works on Android + iOS without any file provider setup
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/pdf')],
        subject: 'Financial Report',
      );

    } catch (e) {
      // ✅ Show error to user instead of silent fail
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('PDF Error: $e');
    }
  }

  pw.Page _buildProfilePage() {
    final user = resultData;
    final fullName = user['ownerName']?.toString() ?? user['fullName']?.toString() ?? 'Not Provided';
    final email = user['email']?.toString() ?? 'Not Provided';
    final phone = user['phone']?.toString() ?? user['mobile']?.toString() ?? 'Not Provided';
    final address = user['address']?.toString() ?? 'Not Provided';
    String dob = user['dob']?.toString() ?? 'Not Provided';
    if (dob != 'Not Provided' && dob.contains('-')) {
      try {
        final parts = dob.split('-');
        if (parts.length == 3) dob = '${parts[2]}/${parts[1]}/${parts[0]}';
      } catch (e) {}
    }
    return pw.Page(
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('USER PROFILE',
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 40),
            _pdfInfoRow('Full Name', fullName),
            _pdfInfoRow('Date of Birth', dob),
            _pdfInfoRow('Mobile Number', phone),
            _pdfInfoRow('Email Address', email),
            _pdfInfoRow('Address', address),
            pw.SizedBox(height: 40),
            pw.Text('Report Generated: ${DateTime.now().toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 130,
            child: pw.Text(label,
                style: pw.TextStyle(fontSize: 11, font: pw.Font.helveticaBold())), // ✅ 28 se 11
          ),
          pw.Expanded(
            child: pw.Text(':  $value',
                style: const pw.TextStyle(fontSize: 11)), // ✅ font size add karo
          ),
        ],
      ),
    );
  }

  num _toNum(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);

  pw.Page _buildTradingPage(Map<String, dynamic> yearData, String yearLabel, String yearEnd) {
    final trading = yearData['oneYearTrading']?['yearOne'] ?? {};
    final debitRows = [
      ['Opening Stock', _pdfFormatCurrency(_toNum(trading['openingStock']))],
      ['Purchases', _pdfFormatCurrency(_toNum(trading['purchases']))],
      ['Less: Returns', _pdfFormatCurrency(_toNum(trading['lessReturn']))],
      ['Carriage Inwards', _pdfFormatCurrency(_toNum(trading['carriageInwards']))],
      ['Cartage', _pdfFormatCurrency(_toNum(trading['cartage']))],
      ['Dock Charges', _pdfFormatCurrency(_toNum(trading['dockCharges']))],
      ['Wages', _pdfFormatCurrency(_toNum(trading['wages']))],
      ['Duty', _pdfFormatCurrency(_toNum(trading['duty']))],
      ['Freight', _pdfFormatCurrency(_toNum(trading['freight']))],
      ['Clearing Charges', _pdfFormatCurrency(_toNum(trading['ClearingCharges']))],
      ['Other Expenses', _pdfFormatCurrency(_toNum(trading['otherExpenses']))],
      ['Gross Profit c/d', _pdfFormatCurrency(_toNum(trading['grossProfitLoss']))],
    ];
    final creditRows = [
      ['Sales', _pdfFormatCurrency(_toNum(trading['sales']))],
      ['Closing Stock', _pdfFormatCurrency(_toNum(trading['closingStock']))],
    ];
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('TRADING ACCOUNT - $yearLabel ($yearEnd)',
              style: pw.TextStyle(fontSize: 14, font: pw.Font.helveticaBold())),
          pw.SizedBox(height: 10),
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: _pdfTable([['Dr', 'Amount (₹)'], ...debitRows])),
                pw.SizedBox(width: 10),
                pw.Expanded(child: _pdfTable([['Cr', 'Amount (₹)'], ...creditRows])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Page _buildPLPage(Map<String, dynamic> yearData, String yearLabel, String yearEnd) {
    final pl = yearData['pl']?['profitLoss'] ?? {};
    final debitRows = [
      ['Salaries', _toNum(pl['salaries'])],
      ['Rent', _toNum(pl['rent'])],
      ['Discount Allowed', _toNum(pl['discountAllowed'])],
      ['Commission Paid', _toNum(pl['commissionPaid'])],
      ['Insurance', _toNum(pl['insurance'])],
      ['Bank Charges', _toNum(pl['bankCharges'])],
      ['Legal Charges', _toNum(pl['legalCharges'])],
      ['Repairs', _toNum(pl['repairs'])],
      ['Advertising', _toNum(pl['advertising'])],
      ['Trade Expenses', _toNum(pl['tradeExpenses'])],
      ['Office Expenses', _toNum(pl['officeExpenses'])],
      ['Bad Debts', _toNum(pl['badDebts'])],
      ['Travelling Expenses', _toNum(pl['travellingExpenses'])],
      ['Selling & Distribution', _toNum(pl['sellingAndDistribution'])],
      ['Net Profit (to Capital)', _toNum(pl['netProfit'])],
    ];
    final creditRows = [
      ['Gross Profit b/f', _toNum(pl['grossProfitBf'])],
      ['Interest Received', _toNum(pl['interestReceived'])],
      ['Discount Received', _toNum(pl['discountReceived'])],
      ['Commission Received', _toNum(pl['commissionReceived'])],
      ['Other Receipts', _toNum(pl['otherReceipts'])],
    ];
    return pw.Page(
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('PROFIT & LOSS - $yearLabel ($yearEnd)',
              style: pw.TextStyle(fontSize: 28, font: pw.Font.helveticaBold())),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _pdfTable([
                  ['Dr', 'Amount (₹)'],
                  ...debitRows.map((r) => [r[0] as String, _pdfFormatCurrency(r[1] as num)]),
                ]),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _pdfTable([
                  ['Cr', 'Amount (₹)'],
                  ...creditRows.map((r) => [r[0] as String, _pdfFormatCurrency(r[1] as num)]),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Page _buildBalanceSheetPage(Map<String, dynamic> yearData, String yearLabel, String yearEnd) {
    final bs = yearData['balanceSheet']?['bs'] ?? {};
    final assets = bs['assets'] ?? {};
    final liabilities = bs['liabilities'] ?? {};
    final liabilityRows = [
      ['Capital', _toNum(liabilities['capital'])],
      ['Add: Net Profit', _toNum(liabilities['netProfit'])],
      ['Bills Payable', _toNum(liabilities['billsPayable'])],
    ];
    final assetRows = [
      ['Cash In Hand', _toNum(assets['cashInHand'])],
      ['Cash at Bank', _toNum(assets['cashAtBank'])],
      ['Bills Receivable', _toNum(assets['billsReceivable'])],
      ['Stock', _toNum(assets['stock'])],
      ['Land & Building', _toNum(assets['landAndBuilding'])],
      ['Office Building', _toNum(assets['officeBuilding'])],
      ['Office Equipment', _toNum(assets['officeEquipment'])],
    ];
    final totalAssets = _toNum(yearData['balanceSheet']?['totalAssets']);
    final totalLiabilities = _toNum(yearData['balanceSheet']?['totalLiabilities']);
    return pw.Page(
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BALANCE SHEET - $yearLabel (as on $yearEnd)',
              style: pw.TextStyle(fontSize: 28, font: pw.Font.helveticaBold())),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _pdfTable([
                  ['Liabilities', 'Amount (₹)'],
                  ...liabilityRows.map((r) => [r[0] as String, _pdfFormatCurrency(r[1] as num)]),
                  ['Total Liabilities', _pdfFormatCurrency(totalLiabilities)],
                ]),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _pdfTable([
                  ['Assets', 'Amount (₹)'],
                  ...assetRows.map((r) => [r[0] as String, _pdfFormatCurrency(r[1] as num)]),
                  ['Total Assets', _pdfFormatCurrency(totalAssets)],
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTable(List<List<String>> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: data.map((row) {
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: data.indexOf(row) == 0 ? PdfColors.grey300 : PdfColors.white,
          ),
          children: row.map((cell) => pw.Padding(
            padding: const pw.EdgeInsets.all(4), // ✅ 6 se 4
            child: pw.Text(
              cell,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 9), // ✅ font size add karo — default bahut bada tha
            ),
          )).toList(),
        );
      }).toList(),
    );
  }

  String _pdfFormatCurrency(num value) {
    return '₹ ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  // ======================== EXCEL GENERATION (unchanged) ========================
  void _createProfileSheet(excel_package.Excel excel, Map<String, dynamic> data) {
    final sheet = excel['Profile'];
    final fullName = data['ownerName']?.toString() ?? data['fullName']?.toString() ?? 'Not Provided';
    final email = data['email']?.toString() ?? 'Not Provided';
    final phone = data['phone']?.toString() ?? data['mobile']?.toString() ?? 'Not Provided';
    final address = data['address']?.toString() ?? 'Not Provided';
    var dobRaw = data['dob']?.toString() ?? 'Not Provided';
    String formattedDob = dobRaw;
    if (dobRaw != 'Not Provided' && dobRaw.contains('-')) {
      try {
        final parts = dobRaw.split('-');
        if (parts.length == 3) formattedDob = '${parts[2]}/${parts[1]}/${parts[0]}';
      } catch (e) {}
    }
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value = excel_package.TextCellValue('USER PROFILE');
    sheet.cell(excel_package.CellIndex.indexByString('A2')).value = excel_package.TextCellValue('----------------------------------------');
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
    sheet.cell(excel_package.CellIndex.indexByString('A10')).value = excel_package.TextCellValue('Report Generated:');
    sheet.cell(excel_package.CellIndex.indexByString('B10')).value = excel_package.TextCellValue(DateTime.now().toString().split(' ')[0]);
    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 40);
  }

  Future<void> _downloadPdfReport(BuildContext context) async {
    try {
      final excel = excel_package.Excel.createExcel();
      if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
      _createProfileSheet(excel, resultData);
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

        _createTradingSheet(excel, 'TRADING YEAR ${years.indexOf(yearInfo) + 1} OR $yearLabel', ownerName, tradingDebitItems, tradingCreditItems, yearEnd, yearLabel);
        _createPLSheet(excel, 'PL YEAR ${years.indexOf(yearInfo) + 1} OR $yearLabel', ownerName, plDebitItems, plCreditItems, yearEnd, yearLabel);
        _createBalanceSheet(excel, 'BS YEAR ${years.indexOf(yearInfo) + 1} OR $yearLabel', ownerName, assetsCalculations, liabilitiesCalculations, totalAssets, totalLiabilities, yearEnd, yearLabel);
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

  void _createTradingSheet(excel_package.Excel excel, String sheetName, String ownerName, Map<String, num> debitItems, Map<String, num> creditItems, String yearEnd, String yearLabel) {
    final sheet = excel[sheetName];
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value = excel_package.TextCellValue('TRADING ACCOUNT OF $ownerName FOR THE YEAR ENDING $yearEnd ($yearLabel)');
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
    sheet.cell(excel_package.CellIndex.indexByString('A15')).value = excel_package.TextCellValue('To Gross Profit transferred to profit and loss account');
    sheet.cell(excel_package.CellIndex.indexByString('B15')).value = excel_package.DoubleCellValue((debitItems["grossProfitLoss"] ?? 0).toDouble());

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
    for (var item in debitItemList) totalDebit += debitItems[item["key"]] ?? 0;
    totalDebit += debitItems["grossProfitLoss"] ?? 0;
    num totalCredit = 0;
    for (var item in creditItemList) totalCredit += creditItems[item["key"]] ?? 0;
    final totalRow = 16;
    sheet.cell(excel_package.CellIndex.indexByString('A$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('B$totalRow')).value = excel_package.DoubleCellValue(totalDebit.toDouble());
    sheet.cell(excel_package.CellIndex.indexByString('C$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('D$totalRow')).value = excel_package.DoubleCellValue(totalCredit.toDouble());
  }

  void _createPLSheet(excel_package.Excel excel, String sheetName, String ownerName, Map<String, num> debitItems, Map<String, num> creditItems, String yearEnd, String yearLabel) {
    final sheet = excel[sheetName];
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value = excel_package.TextCellValue('PROFIT AND LOSS ACCOUNT OF $ownerName FOR THE YEAR ENDING $yearEnd ($yearLabel)');
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
    sheet.cell(excel_package.CellIndex.indexByString('A18')).value = excel_package.TextCellValue('To Net Profit (Transferred to Capital Account)');
    sheet.cell(excel_package.CellIndex.indexByString('B18')).value = excel_package.DoubleCellValue((debitItems["netProfit"] ?? 0).toDouble());

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
    for (var item in debitItemList) totalDebit += debitItems[item["key"]] ?? 0;
    totalDebit += debitItems["netProfit"] ?? 0;
    num totalCredit = 0;
    for (var item in creditItemList) totalCredit += creditItems[item["key"]] ?? 0;
    final totalRow = 19;
    sheet.cell(excel_package.CellIndex.indexByString('A$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('B$totalRow')).value = excel_package.DoubleCellValue(totalDebit.toDouble());
    sheet.cell(excel_package.CellIndex.indexByString('C$totalRow')).value = excel_package.TextCellValue('Total');
    sheet.cell(excel_package.CellIndex.indexByString('D$totalRow')).value = excel_package.DoubleCellValue(totalCredit.toDouble());
  }

  void _createBalanceSheet(excel_package.Excel excel, String sheetName, String ownerName, Map<String, num> assets, Map<String, num> liabilities, num totalAssets, num totalLiabilities, String yearEnd, String yearLabel) {
    final sheet = excel[sheetName];
    sheet.cell(excel_package.CellIndex.indexByString('A1')).value = excel_package.TextCellValue('Balance Sheet of $ownerName as on $yearEnd ($yearLabel)');
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

  // ======================== IMPROVED UI ========================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "3-Year Financial Projection",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.3,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1A2C3E), // matching slate
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: "Download Excel Report",
              onPressed: () => _downloadExcelReport(context), // arrow function mein wrap karo
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              tooltip: "Download PDF Report",
              onPressed: () => _downloadPdfReport(context), // arrow function mein wrap karo
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFFC9A227), // gold accent
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xFFC9A227),
            tabs: [
              Tab(text: "Year 1"),
              Tab(text: "Year 2"),
              Tab(text: "Year 3"),
            ],
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
          child: TabBarView(
            children: [
              _buildYearView("firstYear"),
              _buildYearView("secondYear"),
              _buildYearView("thirdYear"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearView(String yearKey) {
    final year = resultData[yearKey];
    if (year == null) return const Center(child: Text("No data available"));
    final tradingData = year["oneYearTrading"]?["yearOne"] ?? {};
    final plData = year["pl"]?["profitLoss"] ?? {};
    final bsData = year["balanceSheet"]?["bs"] ?? {};

    num _safeNum(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfitSummaryCard(year),
          const SizedBox(height: 24),
          _buildKeyMetricsCards(year),
          const SizedBox(height: 24),
          ExpandableAccountSection(
            title: "Trading Account",
            subtitle: "Revenue & Cost of Goods Sold",
            icon: Icons.trending_up,
            color: const Color(0xFF1A2C3E),
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
          const SizedBox(height: 16),
          ExpandableAccountSection(
            title: "Profit & Loss",
            subtitle: "Operational Performance",
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF1A2C3E),
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
          const SizedBox(height: 16),
          ExpandableAccountSection(
            title: "Balance Sheet - Assets",
            subtitle: "Financial Position",
            icon: Icons.business_center,
            color: const Color(0xFF1A2C3E),
            data: bsData["assets"] ?? {},
          ),
          const SizedBox(height: 16),
          ExpandableAccountSection(
            title: "Balance Sheet - Liabilities",
            subtitle: "Financial Obligations",
            icon: Icons.assignment,
            color: const Color(0xFF1A2C3E),
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
    num _safeNum(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);
    final netProfit = _safeNum(plData["netProfit"]);
    final isProfit = netProfit >= 0;
    final sales = _safeNum(tradingData["sales"]);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2C3E).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
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
                  PieChartSectionData(value: sales.abs().toDouble(), color: const Color(0xFFC9A227), radius: 18, showTitle: false),
                  PieChartSectionData(value: (sales - netProfit).abs().toDouble(), color: const Color(0xFF1A2C3E), radius: 18, showTitle: false),
                  PieChartSectionData(value: netProfit.abs().toDouble(), color: isProfit ? const Color(0xFF2E7D32) : Colors.red.shade700, radius: 18, showTitle: false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isProfit ? "Net Profit" : "Net Loss", style: TextStyle(fontSize: 14, color: Colors.grey.shade600, letterSpacing: -0.2)),
                const SizedBox(height: 6),
                Text(_formatCurrency(netProfit), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: isProfit ? const Color(0xFF2E7D32) : Colors.red.shade700, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text(isProfit ? "Business is Profitable" : "Business is in Loss", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A2C3E))),
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
    num _safeNum(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);
    final netProfit = _safeNum(plData["netProfit"]);
    final isProfit = netProfit >= 0;
    final sales = _safeNum(tradingData["sales"]);
    final grossProfit = _safeNum(tradingData["grossProfitLoss"]);
    final totalAssets = _safeNum(bsData["totalAssets"]);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("Sales", sales, Icons.trending_up, const Color(0xFF1A2C3E))),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard("Gross Profit", grossProfit, Icons.attach_money, const Color(0xFFC9A227))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard("Net Profit", netProfit, Icons.account_balance_wallet, isProfit ? const Color(0xFF2E7D32) : Colors.red.shade700)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard("Total Assets", totalAssets, Icons.business, const Color(0xFF1A2C3E))),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2C3E).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(value),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, letterSpacing: -0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== IMPROVED EXPANDABLE SECTION ========================
class ExpandableAccountSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> data;
  const ExpandableAccountSection({super.key, required this.title, required this.subtitle, required this.icon, required this.color, required this.data});

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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      shadowColor: const Color(0xFF1A2C3E).withOpacity(0.06),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: Color(0xFF1A2C3E)),
            ),
            subtitle: Text(
              widget.subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, letterSpacing: -0.2),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFFC9A227),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Container(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  ...widget.data.entries.map((e) {
                    final num val = e.value is num ? e.value : 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title.contains("Trading") && (e.key == "sales" || e.key == "closingStock")
                                  ? 'By ${_formatCamelCase(e.key)}'
                                  : widget.title.contains("Profit & Loss") &&
                                  (e.key == "grossProfitBf" || e.key == "interestReceived" || e.key == "discountReceived" || e.key == "commissionReceived" || e.key == "otherReceipts")
                                  ? 'By ${_formatCamelCase(e.key)}'
                                  : 'To ${_formatCamelCase(e.key)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                            ),
                          ),
                          Text(
                            _formatCurrency(val),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: val >= 0 ? const Color(0xFF1A2C3E) : Colors.red.shade700),
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