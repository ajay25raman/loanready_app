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

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _fmt(dynamic value) {
    if (value is num) {
      final String str = value.abs().toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      );
      return value < 0 ? '-₹ $str' : '₹ $str';
    }
    return '₹ 0';
  }

  String _fmtLabel(String key) {
    if (key.isEmpty) return key;
    String r = key.replaceAllMapped(
        RegExp(r'(?<=[a-z])[A-Z]'), (m) => ' ${m.group(0)}');
    r = r[0].toUpperCase() + r.substring(1);
    return r.replaceAll('_', ' ');
  }

  num _n(dynamic v) =>
      v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);

  // ═══════════════════════════════════════════════════════════════════════════
  // PDF — PREMIUM DESIGN
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const PdfColor _navy      = PdfColor.fromInt(0xFF1A2C3E);
  static const PdfColor _navyLight = PdfColor.fromInt(0xFF243447);
  static const PdfColor _gold      = PdfColor.fromInt(0xFFC9A227);
  static const PdfColor _blue      = PdfColor.fromInt(0xFF1565C0);
  static const PdfColor _blueSoft  = PdfColor.fromInt(0xFFE3EEF9);
  static const PdfColor _green     = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor _greenSoft = PdfColor.fromInt(0xFFE8F5E9);
  static const PdfColor _red       = PdfColor.fromInt(0xFFC62828);
  static const PdfColor _redSoft   = PdfColor.fromInt(0xFFFFEBEE);
  static const PdfColor _grey50    = PdfColor.fromInt(0xFFF8FAFD);
  static const PdfColor _grey100   = PdfColor.fromInt(0xFFF0F4F8);
  static const PdfColor _grey200   = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor _grey400   = PdfColor.fromInt(0xFF94A3B8);
  static const PdfColor _grey600   = PdfColor.fromInt(0xFF475569);
  static const PdfColor _grey800   = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor _white     = PdfColors.white;

  Future<void> _downloadPdf(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating premium PDF report...'),
          backgroundColor: Color(0xFF1A2C3E),
        ),
      );
    }
    try {
      final pdf = pw.Document(
        title: '3-Year Financial Projection Report',
        author: 'Financial Projection System',
      );

      final years = [
        {'key': 'firstYear',  'label': 'ACTUAL',    'yearEnd': '31ST MARCH 2025', 'num': '01'},
        {'key': 'secondYear', 'label': 'ESTIMATED', 'yearEnd': '31ST MARCH 2026', 'num': '02'},
        {'key': 'thirdYear',  'label': 'PROJECTED', 'yearEnd': '31ST MARCH 2027', 'num': '03'},
      ];

      // ── Page 1: Cover + Summary ──────────────────────────────────────────
      pdf.addPage(_buildCoverPage(years));

      // ── Per-year pages ───────────────────────────────────────────────────
      for (var info in years) {
        final yearData = resultData[info['key']!];
        if (yearData == null) continue;
        // KPI + Trading on one page
        pdf.addPage(_buildYearPage(yearData, info['label']!, info['yearEnd']!, info['num']!));
        // P&L on its own page
        pdf.addPage(_buildPLPage(yearData, info['label']!, info['yearEnd']!, info['num']!));
        // Balance Sheet on its own page
        pdf.addPage(_buildBSPage(yearData, info['label']!, info['yearEnd']!, info['num']!));
      }

      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/financial_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(path, mimeType: 'application/pdf')],
        subject: '3-Year Financial Projection Report',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Shared page header ───────────────────────────────────────────────────
  pw.Widget _pageHeader(String section, String label, String yearEnd, String pageNum) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const pw.BoxDecoration(color: _navy),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    section,
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 15,
                      color: _white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'For the year ending $yearEnd',
                    style: const pw.TextStyle(fontSize: 9, color: _grey400),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _gold,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 10,
                    color: _navy,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Container(height: 3, color: _gold),
      ],
    );
  }

  // ── Shared page footer ───────────────────────────────────────────────────
  pw.Widget _pageFooter(String pageNum) {
    return pw.Column(
      children: [
        pw.Container(height: 1, color: _grey200),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generated: ${_todayStr()}  •  Confidential — For Internal Use Only',
              style: const pw.TextStyle(fontSize: 7.5, color: _grey400),
            ),
            pw.Text(
              'Page $pageNum',
              style: const pw.TextStyle(fontSize: 7.5, color: _grey400),
            ),
          ],
        ),
      ],
    );
  }

  String _todayStr() {
    final d = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2,'0')} ${months[d.month-1]} ${d.year}';
  }

  // ── Cover page ───────────────────────────────────────────────────────────
  pw.Page _buildCoverPage(List<Map<String, String>> years) {
    // Collect summary data for all 3 years
    final summaryRows = years.map((info) {
      final y = resultData[info['key']!] ?? {};
      final t = y['trading'] ?? {};
      final p = y['pl'] ?? {};
      final bs = y['bs'] ?? {};
      return {
        'label': info['label']!,
        'yearEnd': info['yearEnd']!,
        'sales': _n(t['sales']),
        'grossProfit': _n(t['grossProfit']),
        'netProfit': _n(p['netProfit']),
        'totalAssets': _n(bs['totalAssets']),
      };
    }).toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Top decorative band
          pw.Container(
            height: 8,
            color: _gold,
          ),
          // Hero header
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(40, 36, 40, 32),
            color: _navy,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '3-YEAR FINANCIAL',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 28,
                            color: _white,
                            letterSpacing: 1,
                          ),
                        ),
                        pw.Text(
                          'PROJECTION REPORT',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 28,
                            color: _gold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _gold, width: 1.5),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'PREPARED ON',
                            style: const pw.TextStyle(fontSize: 7, color: _grey400, letterSpacing: 1),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            _todayStr(),
                            style: pw.TextStyle(
                              font: pw.Font.helveticaBold(),
                              fontSize: 11,
                              color: _white,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'PERIOD COVERED',
                            style: const pw.TextStyle(fontSize: 7, color: _grey400, letterSpacing: 1),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'FY 2025 – FY 2027',
                            style: pw.TextStyle(
                              font: pw.Font.helveticaBold(),
                              fontSize: 11,
                              color: _gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  'Comprehensive analysis covering Trading Account, Profit & Loss, and Balance Sheet',
                  style: const pw.TextStyle(fontSize: 10, color: _grey400),
                ),
              ],
            ),
          ),
          pw.Container(height: 2, color: _gold),

          pw.SizedBox(height: 28),

          // KPI Summary across 3 years
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 36),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('EXECUTIVE SUMMARY', Icons.bar_chart),
                pw.SizedBox(height: 14),

                // Summary table
                pw.Table(
                  border: pw.TableBorder(
                    top: const pw.BorderSide(color: _navy, width: 2),
                    bottom: const pw.BorderSide(color: _navy, width: 2),
                    horizontalInside: const pw.BorderSide(color: _grey200, width: 0.5),
                    left: pw.BorderSide.none,
                    right: pw.BorderSide.none,
                    verticalInside: pw.BorderSide.none,
                  ),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2.2),
                    1: pw.FlexColumnWidth(1.8),
                    2: pw.FlexColumnWidth(1.8),
                    3: pw.FlexColumnWidth(1.8),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: _navyLight),
                      children: [
                        _summaryCell('METRIC', isHeader: true, align: pw.TextAlign.left),
                        _summaryCell('ACTUAL\n31 Mar 2025', isHeader: true),
                        _summaryCell('ESTIMATED\n31 Mar 2026', isHeader: true),
                        _summaryCell('PROJECTED\n31 Mar 2027', isHeader: true),
                      ],
                    ),
                    // Rows
                    _summaryDataRow('Total Sales', summaryRows.map((r) => r['sales'] as num).toList(), highlight: false),
                    _summaryDataRow('Gross Profit', summaryRows.map((r) => r['grossProfit'] as num).toList(), highlight: false),
                    _summaryDataRow('Net Profit', summaryRows.map((r) => r['netProfit'] as num).toList(), highlight: true, isProfit: true),
                    _summaryDataRow('Total Assets', summaryRows.map((r) => r['totalAssets'] as num).toList(), highlight: false),
                  ],
                ),

                pw.SizedBox(height: 28),

                // Growth indicators
                _sectionTitle('YEAR-ON-YEAR GROWTH', Icons.trending_up),
                pw.SizedBox(height: 14),
                pw.Row(
                  children: [
                    _growthKpiCard(
                      'Sales Growth\n(Y1 → Y2)',
                      '+20.0%',
                      _green,
                      _greenSoft,
                    ),
                    pw.SizedBox(width: 12),
                    _growthKpiCard(
                      'Sales Growth\n(Y2 → Y3)',
                      '+25.0%',
                      _green,
                      _greenSoft,
                    ),
                    pw.SizedBox(width: 12),
                    _growthKpiCard(
                      'Net Profit\nY1 → Y3 Growth',
                      '+50.0%',
                      _blue,
                      _blueSoft,
                    ),
                    pw.SizedBox(width: 12),
                    _growthKpiCard(
                      'Profit Margin\n(All Years)',
                      '33.6%',
                      _navy,
                      _grey100,
                    ),
                  ],
                ),

                pw.SizedBox(height: 28),

                // Table of contents
                _sectionTitle('REPORT CONTENTS', Icons.list_alt),
                pw.SizedBox(height: 10),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _grey200),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    children: [
                      _tocRow('Pages 2–4',  'Year 1 — Actual    |  Trading Account, P&L, Balance Sheet'),
                      _tocRow('Pages 5–7',  'Year 2 — Estimated |  Trading Account, P&L, Balance Sheet'),
                      _tocRow('Pages 8–10', 'Year 3 — Projected |  Trading Account, P&L, Balance Sheet'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.Spacer(),

          // Bottom footer
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(36, 0, 36, 16),
            child: _pageFooter('1'),
          ),
        ],
      ),
    );
  }

  pw.Widget _tocRow(String pages, String content) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _grey200, width: 0.5)),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 70,
            child: pw.Text(pages,
                style: pw.TextStyle(
                    font: pw.Font.helveticaBold(), fontSize: 8.5, color: _navy)),
          ),
          pw.Container(width: 1, height: 12, color: _gold),
          pw.SizedBox(width: 12),
          pw.Text(content,
              style: const pw.TextStyle(fontSize: 8.5, color: _grey600)),
        ],
      ),
    );
  }

  pw.TableRow _summaryDataRow(String label, List<num> values,
      {bool highlight = false, bool isProfit = false}) {
    final bg = highlight ? _blueSoft : _white;
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: highlight ? pw.Font.helveticaBold() : pw.Font.helvetica(),
              fontSize: 9,
              color: _grey800,
            ),
          ),
        ),
        ...values.map((v) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: pw.Text(
            _fmt(v),
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: highlight ? pw.Font.helveticaBold() : pw.Font.helvetica(),
              fontSize: 9,
              color: highlight
                  ? (isProfit ? _green : _red)
                  : _grey800,
            ),
          ),
        )),
      ],
    );
  }

  pw.Widget _summaryCell(String text,
      {bool isHeader = false, pw.TextAlign align = pw.TextAlign.right}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: pw.Font.helveticaBold(),
          fontSize: 8.5,
          color: isHeader ? _white : _grey800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  pw.Widget _growthKpiCard(String label, String value, PdfColor textColor, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: _grey200),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              value,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: pw.Font.helveticaBold(),
                fontSize: 16,
                color: textColor,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              label,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: _grey600),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _sectionTitle(String title, IconData _) {
    return pw.Row(
      children: [
        pw.Container(width: 4, height: 16, color: _gold),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: pw.Font.helveticaBold(),
            fontSize: 11,
            color: _navy,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ── Year page: KPI cards + Trading Account ───────────────────────────────
  pw.Page _buildYearPage(Map<String, dynamic> y, String label, String yearEnd, String num) {
    final t = y['trading'] ?? {};
    final p = y['pl']     ?? {};
    final bs= y['bs']     ?? {};

    final sales       = _n(t['sales']);
    final grossProfit = _n(t['grossProfit']);
    final netProfit   = _n(p['netProfit']);
    final totalAssets = _n(bs['totalAssets']);
    final isProfit    = netProfit >= 0;

    final debitRows = [
      ['To Opening Stock',    _fmt(_n(t['openingStock']))],
      ['To Purchases',        _fmt(_n(t['purchases']))],
      ['Less: Returns',       '(${_fmt(_n(t['lessReturn']))})', true],
      ['To Carriage Inwards', _fmt(_n(t['carriageInwards']))],
      ['To Cartage',          _fmt(_n(t['cartage']))],
      ['To Dock Charges',     _fmt(_n(t['dockCharges']))],
      ['To Wages',            _fmt(_n(t['wages']))],
      ['To Duty',             _fmt(_n(t['duty']))],
      ['To Freight',          _fmt(_n(t['freight']))],
      ['To Clearing Charges', _fmt(_n(t['clearingCharges']))],
      ['To Other Expenses',   _fmt(_n(t['otherExpenses']))],
    ];
    final grossProfitRow = ['To Gross Profit c/d', _fmt(grossProfit)];
    final creditRows = [
      ['By Sales',         _fmt(sales)],
      ['By Closing Stock', _fmt(_n(t['closingStock']))],
    ];
    final tradingTotal = sales + _n(t['closingStock']);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(0, 0, 0, 0),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _pageHeader('TRADING ACCOUNT', label, yearEnd, num),
          pw.SizedBox(height: 18),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // KPI cards row
                pw.Row(
                  children: [
                    _kpiCard('Total Sales', _fmt(sales), _navy, _grey100, isBig: true),
                    pw.SizedBox(width: 10),
                    _kpiCard('Gross Profit', _fmt(grossProfit), _blue, _blueSoft),
                    pw.SizedBox(width: 10),
                    _kpiCard(
                      isProfit ? 'Net Profit' : 'Net Loss',
                      _fmt(netProfit),
                      isProfit ? _green : _red,
                      isProfit ? _greenSoft : _redSoft,
                    ),
                    pw.SizedBox(width: 10),
                    _kpiCard('Total Assets', _fmt(totalAssets), _navy, _grey100),
                  ],
                ),

                pw.SizedBox(height: 20),
                _sectionTitle('TRADING ACCOUNT', Icons.bar_chart),
                pw.SizedBox(height: 10),

                // Trading table — Dr | Cr side by side
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _premiumTable(
                        title: 'Dr (Debit Side)',
                        titleColor: _navy,
                        rows: debitRows
                            .map((row) => row.map((e) => e.toString()).toList())
                            .toList(),
                        highlightRow: grossProfitRow,
                        highlightColor: _blueSoft,
                        highlightTextColor: _blue,
                        footerLabel: 'Total',
                        footerValue: _fmt(_n(t['tradingTotal'])),
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: _premiumTable(
                        title: 'Cr (Credit Side)',
                        titleColor: _navy,
                        rows: creditRows,
                        footerLabel: 'Total',
                        footerValue: _fmt(tradingTotal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 14),
            child: _pageFooter(num == '01' ? '2' : num == '02' ? '5' : '8'),
          ),
        ],
      ),
    );
  }

  // ── P&L page ─────────────────────────────────────────────────────────────
  pw.Page _buildPLPage(Map<String, dynamic> y, String label, String yearEnd, String num) {
    final p = y['pl'] ?? {};
    final netProfit  = _n(p['netProfit']);
    final isProfit   = netProfit >= 0;

    final debitRows = [
      ['To Salaries',              _fmt(_n(p['salaries']))],
      ['To Rent',                  _fmt(_n(p['rent']))],
      ['To Discount Allowed',      _fmt(_n(p['discountAllowed']))],
      ['To Commission Paid',       _fmt(_n(p['commissionPaid']))],
      ['To Insurance',             _fmt(_n(p['insurance']))],
      ['To Bank Charges',          _fmt(_n(p['bankCharges']))],
      ['To Legal Charges',         _fmt(_n(p['legalCharges']))],
      ['To Repairs',               _fmt(_n(p['repairs']))],
      ['To Advertising',           _fmt(_n(p['advertising']))],
      ['To Trade Expenses',        _fmt(_n(p['tradeExpenses']))],
      ['To Office Expenses',       _fmt(_n(p['officeExpenses']))],
      ['To Bad Debts',             _fmt(_n(p['badDebts']))],
      ['To Travelling Expenses',   _fmt(_n(p['travellingExpenses']))],
      ['To Selling & Distribution',_fmt(_n(p['sellingAndDistribution']))],
    ];
    final netProfitRow = [
      'To Net Profit (to Capital)',
      _fmt(netProfit),
    ];
    final creditRows = [
      ['By Gross Profit b/f',    _fmt(_n(p['grossProfitBf']))],
      ['By Interest Received',   _fmt(_n(p['interestReceived']))],
      ['By Discount Received',   _fmt(_n(p['discountReceived']))],
      ['By Commission Received', _fmt(_n(p['commissionReceived']))],
      ['By Other Receipts',      _fmt(_n(p['otherReceipts']))],
    ];

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _pageHeader('PROFIT & LOSS ACCOUNT', label, yearEnd, num),
          pw.SizedBox(height: 18),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Mini KPIs
                pw.Row(
                  children: [
                    _kpiCard('Gross Profit b/f', _fmt(_n(p['grossProfitBf'])), _blue, _blueSoft, isBig: true),
                    pw.SizedBox(width: 10),
                    _kpiCard('Total Income', _fmt(_n(p['plTotal'])), _navy, _grey100),
                    pw.SizedBox(width: 10),
                    _kpiCard(
                      isProfit ? 'Net Profit' : 'Net Loss',
                      _fmt(netProfit),
                      isProfit ? _green : _red,
                      isProfit ? _greenSoft : _redSoft,
                      isBig: true,
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                _sectionTitle('PROFIT & LOSS ACCOUNT', Icons.account_balance_wallet),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _premiumTable(
                        title: 'Dr (Expenditure)',
                        titleColor: _navy,
                        rows: debitRows,
                        highlightRow: netProfitRow,
                        highlightColor: isProfit ? _greenSoft : _redSoft,
                        highlightTextColor: isProfit ? _green : _red,
                        footerLabel: 'Total',
                        footerValue: _fmt(_n(p['plTotal'])),
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: _premiumTable(
                        title: 'Cr (Income)',
                        titleColor: _navy,
                        rows: creditRows,
                        footerLabel: 'Total',
                        footerValue: _fmt(_n(p['plTotal'])),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 14),
            child: _pageFooter(num == '01' ? '3' : num == '02' ? '6' : '9'),
          ),
        ],
      ),
    );
  }

  // ── Balance Sheet page ───────────────────────────────────────────────────
  pw.Page _buildBSPage(Map<String, dynamic> y, String label, String yearEnd, String num) {
    final bs   = y['bs']               ?? {};
    final assets = (bs['assets']       ?? {}) as Map;
    final liab   = (bs['liabilities']  ?? {}) as Map;
    final totalAssets      = _n(bs['totalAssets']);
    final totalLiabilities = _n(bs['totalLiabilities']);

    final liabRows = [
      ['Capital',         _fmt(_n(liab['capital']))],
      ['Add: Net Profit', _fmt(_n(liab['netProfit']))],
      ['Bills Payable',   _fmt(_n(liab['billsPayable']))],
    ];
    final assetRows = [
      ['Cash In Hand',     _fmt(_n(assets['cashInHand']))],
      ['Cash at Bank',     _fmt(_n(assets['cashAtBank']))],
      ['Bills Receivable', _fmt(_n(assets['billsReceivable']))],
      ['Stock',            _fmt(_n(assets['stock']))],
      ['Land & Building',  _fmt(_n(assets['landAndBuilding']))],
      ['Office Building',  _fmt(_n(assets['officeBuilding']))],
      ['Office Equipment', _fmt(_n(assets['officeEquipment']))],
    ];

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _pageHeader('BALANCE SHEET', label, yearEnd, num),
          pw.SizedBox(height: 18),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // KPI bar
                pw.Row(
                  children: [
                    _kpiCard('Total Liabilities', _fmt(totalLiabilities), _navy, _grey100, isBig: true),
                    pw.SizedBox(width: 10),
                    _kpiCard('Total Assets', _fmt(totalAssets), _blue, _blueSoft, isBig: true),
                    pw.SizedBox(width: 10),
                    _kpiCard(
                      'Balance Check',
                      totalAssets == totalLiabilities ? 'BALANCED ✓' : 'CHECK',
                      totalAssets == totalLiabilities ? _green : _red,
                      totalAssets == totalLiabilities ? _greenSoft : _redSoft,
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                _sectionTitle('BALANCE SHEET', Icons.business_center),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _premiumTable(
                        title: 'Liabilities',
                        titleColor: _navy,
                        rows: liabRows,
                        footerLabel: 'Total Liabilities',
                        footerValue: _fmt(totalLiabilities),
                        footerHighlight: true,
                      ),
                    ),
                    pw.SizedBox(width: 14),
                    pw.Expanded(
                      child: _premiumTable(
                        title: 'Assets',
                        titleColor: _navy,
                        rows: assetRows,
                        footerLabel: 'Total Assets',
                        footerValue: _fmt(totalAssets),
                        footerHighlight: true,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Balance confirmation box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: _navy,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Liabilities = Total Assets',
                        style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 10,
                            color: _white),
                      ),
                      pw.Row(
                        children: [
                          pw.Text(
                            '${_fmt(totalLiabilities)}  =  ${_fmt(totalAssets)}',
                            style: pw.TextStyle(
                                font: pw.Font.helveticaBold(),
                                fontSize: 10,
                                color: _gold),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: _green,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Text(
                              'BALANCED',
                              style: pw.TextStyle(
                                  font: pw.Font.helveticaBold(),
                                  fontSize: 8,
                                  color: _white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(28, 0, 28, 14),
            child: _pageFooter(num == '01' ? '4' : num == '02' ? '7' : '10'),
          ),
        ],
      ),
    );
  }

  // ── Premium table widget ─────────────────────────────────────────────────
  pw.Widget _premiumTable({
    required String title,
    required PdfColor titleColor,
    required List<List<String>> rows,
    List<String>? highlightRow,
    PdfColor? highlightColor,
    PdfColor? highlightTextColor,
    required String footerLabel,
    required String footerValue,
    bool footerHighlight = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Column header
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: pw.BoxDecoration(
            color: titleColor,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(5),
              topRight: pw.Radius.circular(5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 9,
                  color: _white,
                  letterSpacing: 0.4,
                ),
              ),
              pw.Text(
                'Amount (₹)',
                style: const pw.TextStyle(fontSize: 8, color: _grey400),
              ),
            ],
          ),
        ),

        // Data rows
        pw.Container(
          decoration: pw.BoxDecoration(
            border: const pw.Border(
              left: pw.BorderSide(color: _grey200),
              right: pw.BorderSide(color: _grey200),
            ),
          ),
          child: pw.Column(
            children: rows.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              final isIndent = row.length > 2 && row[2] == 'true';
              final bg = i.isEven ? _white : _grey50;
              return pw.Container(
                color: bg,
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        isIndent ? '  ${row[0]}' : row[0],
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: isIndent ? _grey400 : _grey800,
                          font: isIndent ? pw.Font.helveticaOblique() : pw.Font.helvetica(),
                        ),
                      ),
                    ),
                    pw.Text(
                      row[1],
                      style: pw.TextStyle(
                        font: pw.Font.helveticaBold(),
                        fontSize: 8.5,
                        color: isIndent ? _grey400 : _grey800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Highlight row (Gross Profit / Net Profit)
        if (highlightRow != null)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            color: highlightColor ?? _blueSoft,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  highlightRow[0],
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 9,
                    color: highlightTextColor ?? _blue,
                  ),
                ),
                pw.Text(
                  highlightRow[1],
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 9,
                    color: highlightTextColor ?? _blue,
                  ),
                ),
              ],
            ),
          ),

        // Footer total
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: pw.BoxDecoration(
            color: footerHighlight ? _navy : _navyLight,
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(5),
              bottomRight: pw.Radius.circular(5),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                footerLabel,
                style: pw.TextStyle(
                    font: pw.Font.helveticaBold(), fontSize: 9, color: _white),
              ),
              pw.Text(
                footerValue,
                style: pw.TextStyle(
                    font: pw.Font.helveticaBold(), fontSize: 9, color: _gold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── KPI card widget ───────────────────────────────────────────────────────
  pw.Widget _kpiCard(
      String label,
      String value,
      PdfColor valueColor,
      PdfColor bg, {
        bool isBig = false,
      }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          border: pw.Border.all(color: _grey200),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: const pw.TextStyle(
                  fontSize: 7, color: _grey600, letterSpacing: 0.5),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: pw.Font.helveticaBold(),
                fontSize: isBig ? 12 : 10,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Legacy stub (kept to avoid any residual calls; not used in new design)
  pw.Widget _pdfTable(List<List<String>> data) => pw.SizedBox();

  // ─── Excel ──────────────────────────────────────────────────────────────────

  Future<void> _downloadExcel(BuildContext context) async {
    try {
      final ex = excel_package.Excel.createExcel();
      if (ex.tables.containsKey('Sheet1')) ex.delete('Sheet1');

      final years = [
        {'key': 'firstYear', 'label': 'ACTUAL', 'yearEnd': '31ST MARCH 2025'},
        {
          'key': 'secondYear',
          'label': 'ESTIMATED',
          'yearEnd': '31ST MARCH 2026'
        },
        {
          'key': 'thirdYear',
          'label': 'PROJECTED',
          'yearEnd': '31ST MARCH 2027'
        },
      ];

      for (int i = 0; i < years.length; i++) {
        final info = years[i];
        final y = resultData[info['key']!] ?? {};
        final t = y['trading'] ?? {};
        final p = y['pl'] ?? {};
        final bs = y['bs'] ?? {};
        final assets = bs['assets'] ?? {};
        final liab = bs['liabilities'] ?? {};
        final label = info['label']!;
        final yearEnd = info['yearEnd']!;
        final n = i + 1;

        _excelTrading(ex, 'TRADING YEAR $n OR $label', t, label, yearEnd);
        _excelPL(ex, 'PL YEAR $n OR $label', p, label, yearEnd);
        _excelBS(ex, 'BS YEAR $n OR $label', assets, liab,
            _n(bs['totalAssets']), _n(bs['totalLiabilities']), label, yearEnd);
      }

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/financial_projection_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final bytes = ex.save();
      if (bytes != null) {
        await File(path).writeAsBytes(bytes);
        await OpenFile.open(path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Excel Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _excelTrading(excel_package.Excel ex, String sheetName,
      Map<String, dynamic> t, String label, String yearEnd) {
    final sh = ex[sheetName];
    void cell(String addr, dynamic val) {
      sh.cell(excel_package.CellIndex.indexByString(addr)).value = val
      is String
          ? excel_package.TextCellValue(val)
          : excel_package.DoubleCellValue((val as num).toDouble());
    }

    cell('A1',
        'TRADING ACCOUNT FOR THE YEAR ENDING $yearEnd ($label)');
    cell('A3', 'Dr');
    cell('B3', 'Amount(Rs)');
    cell('C3', 'Cr');
    cell('D3', 'Amount(Rs)');

    final debitItems = [
      ['To Opening Stock', 'openingStock'],
      ['To Purchases', 'purchases'],
      ['Less: Returns', 'lessReturn'],
      ['To Carriage Inwards', 'carriageInwards'],
      ['To Cartage', 'cartage'],
      ['To Dock Charges', 'dockCharges'],
      ['To Wages', 'wages'],
      ['To Duty', 'duty'],
      ['To Freight', 'freight'],
      ['To Clearing Charges', 'clearingCharges'],
      ['To Other Expenses', 'otherExpenses'],
    ];
    for (int r = 0; r < debitItems.length; r++) {
      cell('A${r + 4}', debitItems[r][0]);
      cell('B${r + 4}', _n(t[debitItems[r][1]]));
    }
    cell('A15',
        'To Gross Profit transferred to profit and loss account');
    cell('B15', _n(t['grossProfit']));

    cell('C4', 'By Sales');
    cell('D4', _n(t['sales']));
    cell('C5', 'By Closing Stock');
    cell('D5', _n(t['closingStock']));
    cell('A16', 'Total');
    cell('B16', _n(t['tradingTotal']));
    cell('C16', 'Total');
    cell('D16', _n(t['sales']) + _n(t['closingStock']));
  }

  void _excelPL(excel_package.Excel ex, String sheetName,
      Map<String, dynamic> p, String label, String yearEnd) {
    final sh = ex[sheetName];
    void cell(String addr, dynamic val) {
      sh.cell(excel_package.CellIndex.indexByString(addr)).value = val
      is String
          ? excel_package.TextCellValue(val)
          : excel_package.DoubleCellValue((val as num).toDouble());
    }

    cell('A1',
        'PROFIT AND LOSS ACCOUNT FOR THE YEAR ENDING $yearEnd ($label)');
    cell('A3', 'Dr');
    cell('B3', 'Amount(Rs)');
    cell('C3', 'Cr');
    cell('D3', 'Amount(Rs)');

    final debit = [
      ['To Salaries', 'salaries'],
      ['To Rent', 'rent'],
      ['To Discount Allowed', 'discountAllowed'],
      ['To Commission Paid', 'commissionPaid'],
      ['To Insurance', 'insurance'],
      ['To Bank Charges', 'bankCharges'],
      ['To Legal Charges', 'legalCharges'],
      ['To Repairs', 'repairs'],
      ['To Advertising', 'advertising'],
      ['To Trade Expenses', 'tradeExpenses'],
      ['To Office Expenses', 'officeExpenses'],
      ['To Bad Debts', 'badDebts'],
      ['To Travelling Expenses', 'travellingExpenses'],
      ['To Selling & Distribution', 'sellingAndDistribution'],
    ];
    for (int r = 0; r < debit.length; r++) {
      cell('A${r + 4}', debit[r][0]);
      cell('B${r + 4}', _n(p[debit[r][1]]));
    }
    cell('A18', 'To Net Profit (Transferred to Capital Account)');
    cell('B18', _n(p['netProfit']));

    final credit = [
      ['By Gross Profit b/f', 'grossProfitBf'],
      ['By Interest Received', 'interestReceived'],
      ['By Discount Received', 'discountReceived'],
      ['By Commission Received', 'commissionReceived'],
      ['By Other Receipts', 'otherReceipts'],
    ];
    for (int r = 0; r < credit.length; r++) {
      cell('C${r + 4}', credit[r][0]);
      cell('D${r + 4}', _n(p[credit[r][1]]));
    }
    cell('A19', 'Total');
    cell('B19', _n(p['plTotal']));
    cell('C19', 'Total');
    cell('D19', _n(p['plTotal']));
  }

  void _excelBS(
      excel_package.Excel ex,
      String sheetName,
      Map<String, dynamic> assets,
      Map<String, dynamic> liab,
      num totalAssets,
      num totalLiabilities,
      String label,
      String yearEnd,
      ) {
    final sh = ex[sheetName];
    void cell(String addr, dynamic val) {
      sh.cell(excel_package.CellIndex.indexByString(addr)).value = val
      is String
          ? excel_package.TextCellValue(val)
          : excel_package.DoubleCellValue((val as num).toDouble());
    }

    cell('A1', 'Balance Sheet as on $yearEnd ($label)');
    cell('A3', 'Liabilities');
    cell('B3', 'Amount(Rs)');
    cell('C3', 'Assets');
    cell('D3', 'Amount(Rs)');

    final liabItems = [
      ['Capital', 'capital'],
      ['Add: Net Profit', 'netProfit'],
      ['Bills Payable', 'billsPayable'],
    ];
    for (int r = 0; r < liabItems.length; r++) {
      cell('A${r + 4}', liabItems[r][0]);
      cell('B${r + 4}', _n(liab[liabItems[r][1]]));
    }

    final assetItems = [
      ['Cash In Hand', 'cashInHand'],
      ['Cash at Bank', 'cashAtBank'],
      ['Bills Receivable', 'billsReceivable'],
      ['Stock', 'stock'],
      ['Land & Building', 'landAndBuilding'],
      ['Office Building', 'officeBuilding'],
      ['Office Equipment', 'officeEquipment'],
    ];
    for (int r = 0; r < assetItems.length; r++) {
      cell('C${r + 4}', assetItems[r][0]);
      cell('D${r + 4}', _n(assets[assetItems[r][1]]));
    }

    final totalRow = max(liabItems.length, assetItems.length) + 4;
    cell('A$totalRow', 'Total Liabilities');
    cell('B$totalRow', totalLiabilities);
    cell('C$totalRow', 'Total Assets');
    cell('D$totalRow', totalAssets);
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────

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
          backgroundColor: const Color(0xFF1A2C3E),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.table_chart, color: Colors.white),
              tooltip: "Download Excel",
              onPressed: () => _downloadExcel(context),
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              tooltip: "Download PDF",
              onPressed: () => _downloadPdf(context),
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFFC9A227),
            unselectedLabelColor: Colors.white70,
            indicatorColor: Color(0xFFC9A227),
            tabs: [
              Tab(text: "Year 1\nActual"),
              Tab(text: "Year 2\nEstimated"),
              Tab(text: "Year 3\nProjected"),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFF0F4F8)],
            ),
          ),
          child: TabBarView(
            children: [
              _YearView(yearData: resultData['firstYear'] ?? {}),
              _YearView(yearData: resultData['secondYear'] ?? {}),
              _YearView(yearData: resultData['thirdYear'] ?? {}),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Year View (single tab content)
// ─────────────────────────────────────────────────────────────────────────────
class _YearView extends StatelessWidget {
  final Map<String, dynamic> yearData;
  const _YearView({required this.yearData});

  num _n(dynamic v) =>
      v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);

  String _fmt(dynamic v) {
    if (v is num) {
      final s = v.abs().toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      );
      return v < 0 ? '-₹ $s' : '₹ $s';
    }
    return '₹ 0';
  }

  @override
  Widget build(BuildContext context) {
    if (yearData.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final t = yearData['trading'] ?? {};
    final p = yearData['pl'] ?? {};
    final bs = yearData['bs'] ?? {};
    final bsAssets = bs['assets'] ?? {};
    final bsLiab = bs['liabilities'] ?? {};

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _ProfitSummaryCard(yearData: yearData),
          const SizedBox(height: 24),
          _KeyMetricsGrid(yearData: yearData),
          const SizedBox(height: 24),

          // Trading Account
          _ExpandableSection(
            title: "Trading Account",
            subtitle: "Revenue & Cost of Goods Sold",
            icon: Icons.trending_up,
            children: [
              _AccountTable(
                leftTitle: "Dr",
                rightTitle: "Cr",
                leftRows: [
                  ['To Opening Stock', _fmt(_n(t['openingStock']))],
                  ['To Purchases', _fmt(_n(t['purchases']))],
                  ['Less: Returns', _fmt(_n(t['lessReturn']))],
                  ['To Carriage Inwards', _fmt(_n(t['carriageInwards']))],
                  ['To Cartage', _fmt(_n(t['cartage']))],
                  ['To Dock Charges', _fmt(_n(t['dockCharges']))],
                  ['To Wages', _fmt(_n(t['wages']))],
                  ['To Duty', _fmt(_n(t['duty']))],
                  ['To Freight', _fmt(_n(t['freight']))],
                  ['To Clearing Charges', _fmt(_n(t['clearingCharges']))],
                  ['To Other Expenses', _fmt(_n(t['otherExpenses']))],
                  ['To Gross Profit c/d', _fmt(_n(t['grossProfit']))],
                ],
                rightRows: [
                  ['By Sales', _fmt(_n(t['sales']))],
                  ['By Closing Stock', _fmt(_n(t['closingStock']))],
                ],
                totalLeft: _fmt(_n(t['tradingTotal'])),
                totalRight:
                _fmt(_n(t['sales']) + _n(t['closingStock'])),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profit & Loss
          _ExpandableSection(
            title: "Profit & Loss Account",
            subtitle: "Operational Performance",
            icon: Icons.account_balance_wallet,
            children: [
              _AccountTable(
                leftTitle: "Dr",
                rightTitle: "Cr",
                leftRows: [
                  ['To Salaries', _fmt(_n(p['salaries']))],
                  ['To Rent', _fmt(_n(p['rent']))],
                  ['To Discount Allowed', _fmt(_n(p['discountAllowed']))],
                  ['To Commission Paid', _fmt(_n(p['commissionPaid']))],
                  ['To Insurance', _fmt(_n(p['insurance']))],
                  ['To Bank Charges', _fmt(_n(p['bankCharges']))],
                  ['To Legal Charges', _fmt(_n(p['legalCharges']))],
                  ['To Repairs', _fmt(_n(p['repairs']))],
                  ['To Advertising', _fmt(_n(p['advertising']))],
                  ['To Trade Expenses', _fmt(_n(p['tradeExpenses']))],
                  ['To Office Expenses', _fmt(_n(p['officeExpenses']))],
                  ['To Bad Debts', _fmt(_n(p['badDebts']))],
                  ['To Travelling Expenses', _fmt(_n(p['travellingExpenses']))],
                  ['To Selling & Distribution',
                    _fmt(_n(p['sellingAndDistribution']))],
                  ['To Net Profit (to Capital)', _fmt(_n(p['netProfit']))],
                ],
                rightRows: [
                  ['By Gross Profit b/f', _fmt(_n(p['grossProfitBf']))],
                  ['By Interest Received', _fmt(_n(p['interestReceived']))],
                  ['By Discount Received', _fmt(_n(p['discountReceived']))],
                  ['By Commission Received', _fmt(_n(p['commissionReceived']))],
                  ['By Other Receipts', _fmt(_n(p['otherReceipts']))],
                ],
                totalLeft: _fmt(_n(p['plTotal'])),
                totalRight: _fmt(_n(p['plTotal'])),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Balance Sheet
          _ExpandableSection(
            title: "Balance Sheet",
            subtitle: "Financial Position",
            icon: Icons.business_center,
            children: [
              _AccountTable(
                leftTitle: "Liabilities",
                rightTitle: "Assets",
                leftRows: [
                  ['Capital', _fmt(_n(bsLiab['capital']))],
                  ['Add: Net Profit', _fmt(_n(bsLiab['netProfit']))],
                  ['Bills Payable', _fmt(_n(bsLiab['billsPayable']))],
                ],
                rightRows: [
                  ['Cash In Hand', _fmt(_n(bsAssets['cashInHand']))],
                  ['Cash at Bank', _fmt(_n(bsAssets['cashAtBank']))],
                  ['Bills Receivable', _fmt(_n(bsAssets['billsReceivable']))],
                  ['Stock', _fmt(_n(bsAssets['stock']))],
                  ['Land & Building', _fmt(_n(bsAssets['landAndBuilding']))],
                  ['Office Building', _fmt(_n(bsAssets['officeBuilding']))],
                  ['Office Equipment', _fmt(_n(bsAssets['officeEquipment']))],
                ],
                totalLeft: _fmt(_n(bs['totalLiabilities'])),
                totalRight: _fmt(_n(bs['totalAssets'])),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Profit Summary Card (pie chart + key numbers)
// ─────────────────────────────────────────────────────────────────────────────
class _ProfitSummaryCard extends StatelessWidget {
  final Map<String, dynamic> yearData;
  const _ProfitSummaryCard({required this.yearData});

  num _n(dynamic v) =>
      v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);

  String _fmt(dynamic v) {
    if (v is num) {
      final s = v.abs().toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      );
      return v < 0 ? '-₹ $s' : '₹ $s';
    }
    return '₹ 0';
  }

  @override
  Widget build(BuildContext context) {
    final p = yearData['pl'] ?? {};
    final t = yearData['trading'] ?? {};
    final netProfit = _n(p['netProfit']);
    final sales = _n(t['sales']);
    final isProfit = netProfit >= 0;

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
                  PieChartSectionData(
                    value: sales.abs().toDouble(),
                    color: const Color(0xFFC9A227),
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (sales - netProfit).abs().toDouble(),
                    color: const Color(0xFF1A2C3E),
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
                      letterSpacing: -0.2),
                ),
                const SizedBox(height: 6),
                Text(
                  _fmt(netProfit),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isProfit
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isProfit
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade700)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isProfit
                        ? "Business is Profitable"
                        : "Business is in Loss",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isProfit
                          ? const Color(0xFF2E7D32)
                          : Colors.red.shade700,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Key Metrics 2×2 Grid
// ─────────────────────────────────────────────────────────────────────────────
class _KeyMetricsGrid extends StatelessWidget {
  final Map<String, dynamic> yearData;
  const _KeyMetricsGrid({required this.yearData});

  num _n(dynamic v) =>
      v is num ? v : (v is String ? num.tryParse(v) ?? 0 : 0);

  @override
  Widget build(BuildContext context) {
    final t = yearData['trading'] ?? {};
    final p = yearData['pl'] ?? {};
    final bs = yearData['bs'] ?? {};
    final netProfit = _n(p['netProfit']);

    final metrics = [
      {
        'title': 'Sales',
        'value': _n(t['sales']),
        'icon': Icons.trending_up,
        'color': const Color(0xFF1A2C3E),
      },
      {
        'title': 'Gross Profit',
        'value': _n(t['grossProfit']),
        'icon': Icons.attach_money,
        'color': const Color(0xFFC9A227),
      },
      {
        'title': 'Net Profit',
        'value': netProfit,
        'icon': Icons.account_balance_wallet,
        'color': netProfit >= 0
            ? const Color(0xFF2E7D32)
            : Colors.red.shade700,
      },
      {
        'title': 'Total Assets',
        'value': _n(bs['totalAssets']),
        'icon': Icons.business,
        'color': const Color(0xFF1A2C3E),
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(m: metrics[0])),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(m: metrics[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricCard(m: metrics[2])),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(m: metrics[3])),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Map<String, dynamic> m;
  const _MetricCard({required this.m});

  String _fmt(num v) {
    final s = v.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
    return v < 0 ? '-₹ $s' : '₹ $s';
  }

  @override
  Widget build(BuildContext context) {
    final color = m['color'] as Color;
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
          Icon(m['icon'] as IconData, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            m['title'] as String,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _fmt(m['value'] as num),
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Expandable Section
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandableSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const _ExpandableSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _open = !_open),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2C3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon,
                  color: const Color(0xFF1A2C3E), size: 22),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: Color(0xFF1A2C3E)),
            ),
            subtitle: Text(
              widget.subtitle,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: Icon(
              _open ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFFC9A227),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
            _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),
                  ...widget.children,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Account Table (Dr/Cr layout)
// ─────────────────────────────────────────────────────────────────────────────
class _AccountTable extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final List<List<String>> leftRows;
  final List<List<String>> rightRows;
  final String totalLeft;
  final String totalRight;

  const _AccountTable({
    required this.leftTitle,
    required this.rightTitle,
    required this.leftRows,
    required this.rightRows,
    required this.totalLeft,
    required this.totalRight,
  });

  @override
  Widget build(BuildContext context) {
    final maxRows = max(leftRows.length, rightRows.length);

    return Table(
      border: TableBorder.all(
        color: const Color(0xFFE2E8F0),
        width: 0.8,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(1.2),
      },
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFF1A2C3E)),
          children: [leftTitle, 'Amount', rightTitle, 'Amount']
              .map((h) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 8),
            child: Text(
              h,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ))
              .toList(),
        ),

        // Data rows
        for (int i = 0; i < maxRows; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven
                  ? Colors.white
                  : const Color(0xFFF8FAFD),
            ),
            children: [
              // Left label
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 7),
                child: Text(
                  i < leftRows.length ? leftRows[i][0] : '',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF334155)),
                ),
              ),
              // Left amount
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 7),
                child: Text(
                  i < leftRows.length ? leftRows[i][1] : '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2C3E)),
                ),
              ),
              // Right label
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 7),
                child: Text(
                  i < rightRows.length ? rightRows[i][0] : '',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF334155)),
                ),
              ),
              // Right amount
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 7),
                child: Text(
                  i < rightRows.length ? rightRows[i][1] : '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2C3E)),
                ),
              ),
            ],
          ),

        // Total row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF0F4F8)),
          children: [
            const Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Total',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              child: Text(
                totalLeft,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E)),
              ),
            ),
            const Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Total',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              child: Text(
                totalRight,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2C3E)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}