import 'dart:typed_data';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FinancialReportPdfService {
  // ============================================================
  // HELPERS
  // ============================================================

  static double numValue(dynamic value) {
    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static String money(dynamic value) {
    return '₹${numValue(value).toStringAsFixed(0)}';
  }

  static Map<String, dynamic> mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  // ============================================================
  // GENERATE PDF
  // ============================================================

  static Future<Uint8List> generatePdf({
    required Map<String, dynamic> report,
  }) async {
    final pdf = pw.Document();

    final reportId = report['id'] ?? '-';

    final input = mapValue(
      report['input'],
    );

    final firstYear = mapValue(
      report['firstYear'],
    );

    final secondYear = mapValue(
      report['secondYear'],
    );

    final thirdYear = mapValue(
      report['thirdYear'],
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),

        header: (context) {
          return pw.Column(
            crossAxisAlignment:
            pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FINANCIAL REPORT',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'Report #$reportId',
                style: const pw.TextStyle(
                  fontSize: 11,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Divider(),
            ],
          );
        },

        footer: (context) {
          return pw.Row(
            mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Financial Report',
                style: const pw.TextStyle(
                  fontSize: 8,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber}',
                style: const pw.TextStyle(
                  fontSize: 8,
                ),
              ),
            ],
          );
        },

        build: (context) {
          return [
            _buildInputSection(input),

            pw.SizedBox(height: 20),

            _buildYearSection(
              title: 'YEAR 1',
              yearData: firstYear,
            ),

            pw.SizedBox(height: 20),

            _buildYearSection(
              title: 'YEAR 2',
              yearData: secondYear,
            ),

            pw.SizedBox(height: 20),

            _buildYearSection(
              title: 'YEAR 3',
              yearData: thirdYear,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // INPUT SECTION
  // ============================================================

  static pw.Widget _buildInputSection(
      Map<String, dynamic> input,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
        ),
        borderRadius:
        pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'REPORT INPUT',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),

          pw.SizedBox(height: 8),

          _pdfRow(
            'Sales',
            money(input['sales']),
          ),

          _pdfRow(
            'Commission Received',
            money(
              input['commissionReceived'],
            ),
          ),

          _pdfRow(
            'Cash in Hand',
            money(
              input['cashInHand'],
            ),
          ),

          _pdfRow(
            'Cash at Bank',
            money(
              input['cashInBank'],
            ),
          ),

          _pdfRow(
            'Land & Building',
            money(
              input['landAndBuilding'],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // YEAR SECTION
  // ============================================================

  static pw.Widget _buildYearSection({
    required String title,
    required Map<String, dynamic> yearData,
  }) {
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

    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(9),
          color: PdfColors.blue900,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.SizedBox(height: 10),

        _buildTradingTable(trading),

        pw.SizedBox(height: 14),

        _buildProfitLossTable(profitLoss),

        pw.SizedBox(height: 14),

        _buildBalanceSheetTable(
          assets,
          liabilities,
          balanceContainer,
        ),
      ],
    );
  }

  // ============================================================
  // TRADING ACCOUNT
  // ============================================================

  static pw.Widget _buildTradingTable(
      Map<String, dynamic> trading,
      ) {
    final rows = [
      [
        'Opening Stock',
        money(trading['openingStock']),
      ],
      [
        'Purchases',
        money(trading['purchases']),
      ],
      [
        'Less: Purchase Return',
        money(trading['lessReturn']),
      ],
      [
        'Carriage Inwards',
        money(trading['carriageInwards']),
      ],
      [
        'Cartage',
        money(trading['cartage']),
      ],
      [
        'Dock Charges',
        money(trading['dockCharges']),
      ],
      [
        'Wages',
        money(trading['wages']),
      ],
      [
        'Duty',
        money(trading['duty']),
      ],
      [
        'Freight',
        money(trading['freight']),
      ],
      [
        'Clearing Charges',
        money(trading['ClearingCharges']),
      ],
      [
        'Other Expenses',
        money(trading['otherExpenses']),
      ],
      [
        'Gross Profit / Loss',
        money(trading['grossProfitLoss']),
      ],
      [
        'Closing Stock',
        money(trading['closingStock']),
      ],
      [
        'Sales',
        money(trading['sales']),
      ],
      [
        'Total',
        money(trading['totalIncome']),
      ],
    ];

    return _table(
      title: 'TRADING ACCOUNT',
      rows: rows,
    );
  }

  // ============================================================
  // PROFIT LOSS
  // ============================================================

  static pw.Widget _buildProfitLossTable(
      Map<String, dynamic> pl,
      ) {
    final rows = [
      [
        'Salaries',
        money(pl['salaries']),
      ],
      [
        'Rent',
        money(pl['rent']),
      ],
      [
        'Discount Allowed',
        money(pl['discountAllowed']),
      ],
      [
        'Commission Paid',
        money(pl['commissionPaid']),
      ],
      [
        'Insurance',
        money(pl['insurance']),
      ],
      [
        'Bank Charges',
        money(pl['bankCharges']),
      ],
      [
        'Legal Charges',
        money(pl['legalCharges']),
      ],
      [
        'Repairs',
        money(pl['repairs']),
      ],
      [
        'Advertising',
        money(pl['advertising']),
      ],
      [
        'Trade Expenses',
        money(pl['tradeExpenses']),
      ],
      [
        'Office Expenses',
        money(pl['officeExpenses']),
      ],
      [
        'Bad Debts',
        money(pl['badDebts']),
      ],
      [
        'Travelling Expenses',
        money(pl['travellingExpenses']),
      ],
      [
        'Selling & Distribution',
        money(
          pl['sellingAndDistribution'],
        ),
      ],
      [
        'Gross Profit b/f',
        money(pl['grossProfitBf']),
      ],
      [
        'Interest Received',
        money(pl['interestReceived']),
      ],
      [
        'Discount Received',
        money(pl['discountReceived']),
      ],
      [
        'Commission Received',
        money(
          pl['commissionReceived'],
        ),
      ],
      [
        'Other Receipts',
        money(pl['otherReceipts']),
      ],
      [
        'Net Profit',
        money(pl['netProfit']),
      ],
      [
        'Total',
        money(pl['plTotalIncome']),
      ],
    ];

    return _table(
      title: 'PROFIT & LOSS ACCOUNT',
      rows: rows,
    );
  }

  // ============================================================
  // BALANCE SHEET
  // ============================================================

  static pw.Widget _buildBalanceSheetTable(
      Map<String, dynamic> assets,
      Map<String, dynamic> liabilities,
      Map<String, dynamic> balance,
      ) {
    final rows = [
      [
        'Cash in Hand',
        money(assets['cashInHand']),
      ],
      [
        'Cash at Bank',
        money(assets['cashAtBank']),
      ],
      [
        'Bills Receivable',
        money(assets['billsReceivable']),
      ],
      [
        'Stock',
        money(assets['stock']),
      ],
      [
        'Land & Building',
        money(assets['landAndBuilding']),
      ],
      [
        'Office Building',
        money(assets['officeBuilding']),
      ],
      [
        'Office Equipment',
        money(assets['officeEquipment']),
      ],
      [
        'Total Assets',
        money(balance['totalAssets']),
      ],
      [
        'Bills Payable',
        money(liabilities['billsPayable']),
      ],
      [
        'Capital',
        money(liabilities['capital']),
      ],
      [
        'Net Profit',
        money(liabilities['netProfit']),
      ],
      [
        'Total Liabilities',
        money(balance['totalLiabilities']),
      ],
    ];

    return _table(
      title: 'BALANCE SHEET',
      rows: rows,
    );
  }

  // ============================================================
  // COMMON TABLE
  // ============================================================

  static pw.Widget _table({
    required String title,
    required List<List<String>> rows,
  }) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey300,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration:
              const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              children: [
                _cell(
                  'Particular',
                  bold: true,
                ),
                _cell(
                  'Amount',
                  bold: true,
                  alignRight: true,
                ),
              ],
            ),

            ...rows.map(
                  (row) {
                final isTotal =
                    row[0] == 'Total' ||
                        row[0] == 'Net Profit' ||
                        row[0] == 'Total Assets' ||
                        row[0] ==
                            'Total Liabilities';

                return pw.TableRow(
                  children: [
                    _cell(
                      row[0],
                      bold: isTotal,
                    ),
                    _cell(
                      row[1],
                      bold: isTotal,
                      alignRight: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(
      String text, {
        bool bold = false,
        bool alignRight = false,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: alignRight
            ? pw.TextAlign.right
            : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _pdfRow(
      String title,
      String value,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: const pw.TextStyle(
                fontSize: 9,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOWNLOAD PDF
  // ============================================================

  static Future<String?> downloadPdf({
    required Map<String, dynamic> report,
    required int reportId,
  }) async {
    final Uint8List bytes = await generatePdf(
      report: report,
    );

    final params = SaveFileDialogParams(
      data: bytes,
      fileName: 'Financial_Report_$reportId.pdf',
    );

    return FlutterFileDialog.saveFile(
      params: params,
    );
  }

  // ============================================================
  // SHARE PDF
  // ============================================================

  static Future<void> sharePdf({
    required Map<String, dynamic> report,
    required int reportId,
  }) async {
    final Uint8List bytes = await generatePdf(
      report: report,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename:
      'Financial_Report_$reportId.pdf',
    );
  }
}