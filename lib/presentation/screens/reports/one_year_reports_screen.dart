import 'package:flutter/material.dart';
import 'package:loanready_app/presentation/screens/home/one_year_trading_screen.dart';
import 'package:loanready_app/presentation/screens/reports/one_year_report_view_screen.dart';
import 'package:loanready_app/providers/one_year_report_provider.dart';
import 'package:provider/provider.dart';

class OneYearReportsScreen extends StatefulWidget {
  const OneYearReportsScreen({super.key});

  @override
  State<OneYearReportsScreen> createState() =>
      _OneYearReportsScreenState();
}

class _OneYearReportsScreenState extends State<OneYearReportsScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  String _statusFilter = 'All';
  String _yearFilter = 'All';
  String _sortBy = 'Newest';

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OneYearReportProvider>().fetchAllReports();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String money(dynamic value) {
    final amount = double.tryParse(value.toString()) ?? 0;

    return '₹${amount.toStringAsFixed(0)}';
  }

  String date(dynamic value) {
    if (value == null) return '-';

    final d = DateTime.tryParse(value.toString());

    if (d == null) return '-';

    return '${d.day.toString().padLeft(2, '0')} '
        '${_monthName(d.month)} ${d.year}, '
        '${_formatTime(d)}';
  }

  String shortDate(dynamic value) {
    if (value == null) return '-';

    final d = DateTime.tryParse(value.toString());

    if (d == null) return '-';

    return '${d.day.toString().padLeft(2, '0')} '
        '${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int month) {
    const months = [
      '',
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
    ];

    return months[month];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute =
    dateTime.minute.toString().padLeft(2, '0');

    final period =
    dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  bool _isWithinDateRange(dynamic value) {
    if (_fromDate == null && _toDate == null) {
      return true;
    }

    final createdAt =
    DateTime.tryParse(value.toString());

    if (createdAt == null) {
      return false;
    }

    final dateOnly = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );

    if (_fromDate != null &&
        dateOnly.isBefore(_fromDate!)) {
      return false;
    }

    if (_toDate != null &&
        dateOnly.isAfter(_toDate!)) {
      return false;
    }

    return true;
  }

  List<dynamic> _filteredReports(
      OneYearReportProvider provider,
      ) {
    final reports =
    List<dynamic>.from(provider.reports);

    var result = reports.where((report) {
      final idText =
      report.id.toString().toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty ||
              idText.contains(_searchQuery);

      final matchesDate =
      _isWithinDateRange(report.createdAt);

      return matchesSearch && matchesDate;
    }).toList();

    // Latest / Old status.
    if (_statusFilter == 'Latest' &&
        result.isNotEmpty) {
      final latestId = result
          .map((e) => e.id as int)
          .reduce((a, b) => a > b ? a : b);

      result = result
          .where((e) => e.id == latestId)
          .toList();
    }

    if (_statusFilter == 'Old' &&
        result.isNotEmpty) {
      final latestId = result
          .map((e) => e.id as int)
          .reduce((a, b) => a > b ? a : b);

      result = result
          .where((e) => e.id != latestId)
          .toList();
    }

    // NOTE:
    // Year 1 / Year 2 / Year 3 filtering cannot
    // be applied to the current /all response because
    // the API does not return a year field.
    //
    // Once API returns:
    // "year": 1
    //
    // this can be implemented here.

    if (_sortBy == 'Newest') {
      result.sort((a, b) {
        final aDate =
            DateTime.tryParse(
              a.createdAt.toString(),
            ) ??
                DateTime(2000);

        final bDate =
            DateTime.tryParse(
              b.createdAt.toString(),
            ) ??
                DateTime(2000);

        return bDate.compareTo(aDate);
      });
    } else {
      result.sort((a, b) {
        final aDate =
            DateTime.tryParse(
              a.createdAt.toString(),
            ) ??
                DateTime(2000);

        final bDate =
            DateTime.tryParse(
              b.createdAt.toString(),
            ) ??
                DateTime(2000);

        return aDate.compareTo(bDate);
      });
    }

    return result;
  }

  Future<void> _selectDate({
    required bool isFrom,
  }) async {
    final initialDate = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = DateTime(
          selected.year,
          selected.month,
          selected.day,
        );
      } else {
        _toDate = DateTime(
          selected.year,
          selected.month,
          selected.day,
        );
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _statusFilter = 'All';
      _yearFilter = 'All';
      _sortBy = 'Newest';
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(context).viewInsets.bottom +
                    24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Filter Reports',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            setSheetState(() {});
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _FilterDateBox(
                            title: 'From Date',
                            value: _fromDate == null
                                ? 'Select date'
                                : shortDate(_fromDate),
                            onTap: () async {
                              await _selectDate(
                                isFrom: true,
                              );
                              setSheetState(() {});
                            },
                          ),
                        ),
                        const Padding(
                          padding:
                          EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Text('—'),
                        ),
                        Expanded(
                          child: _FilterDateBox(
                            title: 'To Date',
                            value: _toDate == null
                                ? 'Select date'
                                : shortDate(_toDate),
                            onTap: () async {
                              await _selectDate(
                                isFrom: false,
                              );
                              setSheetState(() {});
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Year',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _FilterChoice(
                          title: 'Year 1',
                          selected:
                          _yearFilter == 'Year 1',
                          onTap: () {
                            setSheetState(() {
                              _yearFilter = 'Year 1';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChoice(
                          title: 'Year 2',
                          selected:
                          _yearFilter == 'Year 2',
                          onTap: () {
                            setSheetState(() {
                              _yearFilter = 'Year 2';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChoice(
                          title: 'Year 3',
                          selected:
                          _yearFilter == 'Year 3',
                          onTap: () {
                            setSheetState(() {
                              _yearFilter = 'Year 3';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChoice(
                          title: 'All',
                          selected:
                          _yearFilter == 'All',
                          onTap: () {
                            setSheetState(() {
                              _yearFilter = 'All';
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Report Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _FilterChoice(
                          title: 'All',
                          selected:
                          _statusFilter == 'All',
                          onTap: () {
                            setSheetState(() {
                              _statusFilter = 'All';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChoice(
                          title: 'Latest',
                          selected:
                          _statusFilter == 'Latest',
                          onTap: () {
                            setSheetState(() {
                              _statusFilter = 'Latest';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _FilterChoice(
                          title: 'Old',
                          selected:
                          _statusFilter == 'Old',
                          onTap: () {
                            setSheetState(() {
                              _statusFilter = 'Old';
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration:
                      const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Newest',
                          child: Text(
                            'Created Date (Newest First)',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Oldest',
                          child: Text(
                            'Created Date (Oldest First)',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setSheetState(() {
                          _sortBy = value;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.filter_alt_outlined,
                        ),
                        label: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getFriendlyErrorMessage(String? error) {
    if (error == null || error.trim().isEmpty) {
      return 'Unable to load reports. Please try again.';
    }

    final message = error.toLowerCase();

    // ----------------------------------------------------------
    // NO INTERNET / NETWORK ERROR
    // ----------------------------------------------------------

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('no address associated with hostname') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('connection timed out') ||
        message.contains('clientexception')) {
      return 'No Internet Connection.\n'
          'Please check your internet connection and try again.';
    }

    // ----------------------------------------------------------
    // TIMEOUT
    // ----------------------------------------------------------

    if (message.contains('timeout') ||
        message.contains('timed out')) {
      return 'Request timed out.\n'
          'Please check your internet connection and try again.';
    }

    // ----------------------------------------------------------
    // SERVER ERROR
    // ----------------------------------------------------------

    if (message.contains('500') ||
        message.contains('502') ||
        message.contains('503') ||
        message.contains('504')) {
      return 'Server is temporarily unavailable.\n'
          'Please try again later.';
    }

    // ----------------------------------------------------------
    // AUTH ERROR
    // ----------------------------------------------------------

    if (message.contains('401') ||
        message.contains('unauthorized') ||
        message.contains('session expired')) {
      return 'Your session has expired.\n'
          'Please login again.';
    }

    // ----------------------------------------------------------
    // DEFAULT
    // ----------------------------------------------------------

    return 'Unable to load financial reports.\n'
        'Please try again.';
  }
  void _openReport(dynamic report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OneYearReportViewScreen(
          reportId: report.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            tooltip: 'Back',
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: Color(0xFF0B1628),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          'Financial Reports',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Filter Reports',
            onPressed: _showFilterSheet,
            icon: const Icon(
              Icons.filter_alt_outlined,
            ),
          ),

          const SizedBox(width: 6),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OneYearTradingScreen(),
                  ),
                ).then((_) {
                  if (mounted) {
                    context
                        .read<OneYearReportProvider>()
                        .fetchAllReports();
                  }
                });
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 20,
              ),
              label: const Text(
                'Add Report',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1628),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Consumer<OneYearReportProvider>(
        builder: (context, provider, child) {
          // Pehle se data hai to full loader mat dikhao
          final bool showFullLoader =
              provider.isLoading && provider.reports.isEmpty;

          if (showFullLoader) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && provider.reports.isEmpty) {
            return _ErrorView(
              message: _getFriendlyErrorMessage(provider.errorMessage),
              isNoInternet: provider.errorMessage == 'NO_INTERNET',
              onRetry: provider.fetchAllReports,
            );
          }

          if (provider.reports.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.fetchAllReports,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: Text('No reports available')),
                ],
              ),
            );
          }

          final reports = _filteredReports(provider);
          final latestReport =
          provider.reports.isNotEmpty ? provider.reports.first : null;

          return RefreshIndicator(
            onRefresh: provider.fetchAllReports,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                // Optional: small loading indicator on top when refreshing
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Color(0xFFE8EAF0),
                      color: Color(0xFF0B1628),
                    ),
                  ),

                _SearchBar(
                  controller: _searchController,
                  onFilter: _showFilterSheet,
                ),

                const SizedBox(height: 16),

                if (latestReport != null)
                  _LatestReportCard(
                    report: latestReport,
                    money: money,
                    date: date,
                    onView: () => _openReport(latestReport),
                  ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'All Reports',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${reports.length} Reports',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (reports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text('No reports match your filters'),
                    ),
                  ),

                ...reports.map(
                      (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReportCard(
                      report: report,
                      money: money,
                      date: date,
                      isLatest: report.id == latestReport?.id,
                      onTap: () => _openReport(report),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// SEARCH BAR
// ---------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilter;

  const _SearchBar({
    required this.controller,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E5EC),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search reports...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onFilter,
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF1649E8),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// LATEST REPORT
// ---------------------------------------------------------

class _LatestReportCard extends StatelessWidget {
  final dynamic report;
  final String Function(dynamic) money;
  final String Function(dynamic) date;
  final VoidCallback onView;

  const _LatestReportCard({
    required this.report,
    required this.money,
    required this.date,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Latest Report',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F8EE),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: const Text(
                  'Latest',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Report #${report.id}',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            date(report.createdAt),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding:
            const EdgeInsets.symmetric(
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.trending_up,
                    title: 'Sales',
                    value: money(report.sales),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Commission',
                    value: money(
                      report.commissionReceived,
                    ),
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.account_balance,
                    title: 'Bank',
                    value: money(
                      report.cashInBank,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onView,
              child: const Text(
                'View Latest Report',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// REPORT CARD
// ---------------------------------------------------------

class _ReportCard extends StatelessWidget {
  final dynamic report;
  final String Function(dynamic) money;
  final String Function(dynamic) date;
  final bool isLatest;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.money,
    required this.date,
    required this.isLatest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isLatest
                  ? const Color(0xFF4D6FFF)
                  : const Color(0xFFE5E7EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF1649E8),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Report #${report.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (isLatest) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFE9F8EE,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(10),
                            ),
                            child: const Text(
                              'Latest',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 9,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      date(report.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      money(report.sales),
                      style: const TextStyle(
                        color: Color(0xFF1649E8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// SUMMARY ITEM
// ---------------------------------------------------------

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF1649E8),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// FILTER DATE BOX
// ---------------------------------------------------------

class _FilterDateBox extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _FilterDateBox({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE0E3EA),
          ),
          borderRadius:
          BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// FILTER CHOICE
// ---------------------------------------------------------

class _FilterChoice extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChoice({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1649E8)
                : Colors.white,
            borderRadius:
            BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1649E8)
                  : const Color(0xFFE0E3EA),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ERROR VIEW
// ---------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isNoInternet;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.isNoInternet,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: isNoInternet
                    ? const Color(0xFFFFF4E5)
                    : const Color(0xFFFFEEEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNoInternet
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 42,
                color: isNoInternet
                    ? const Color(0xFFE09A00)
                    : const Color(0xFFE53935),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isNoInternet
                  ? 'No Internet Connection'
                  : 'Unable to Load Reports',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B1628),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                ),
                label: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF0B1628),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}