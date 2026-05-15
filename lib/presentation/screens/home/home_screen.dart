import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/presentation/screens/home/ebook_screen.dart';
import 'package:loanready_app/presentation/screens/home/one_year_trading_screen.dart';
import '../auth/otp_login_screen.dart';
import '../chatbot/ai_service.dart';
import '../loan/loan_scheme.dart';
import '../register/profile_screen.dart';
// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS  — change once, reflects everywhere
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  // Colors
  static const Color navy      = Color(0xFF0B1628);
  static const Color navyLight = Color(0xFF162035);
  static const Color gold      = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFD4B44A);
  static const Color bg        = Color(0xFFF2F4F8);
  static const Color surface   = Colors.white;
  static const Color textPrimary   = Color(0xFF0B1628);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border    = Color(0xFFE5E7EB);

  // Category tints  (icon color, bg tint)
  static const Map<String, List<Color>> cats = {
    'navy':   [Color(0xFF0B1628), Color(0xFFEAECF2)],
    'violet': [Color(0xFF5B50E8), Color(0xFFEEEDFD)],
    'green':  [Color(0xFF0A9464), Color(0xFFE4F6EF)],
    'amber':  [Color(0xFFD97706), Color(0xFFFEF3E2)],
    'rose':   [Color(0xFFE84F6E), Color(0xFFFDECF1)],
  };

  // Radius
  static const double radiusSm  = 12;
  static const double radiusMd  = 18;
  static const double radiusLg  = 24;
  static const double radiusXl  = 32;

  // Shadows
  static List<BoxShadow> shadowSm(Color c) => [
    BoxShadow(color: c.withOpacity(0.10), blurRadius: 8,  offset: const Offset(0, 3)),
  ];
  static List<BoxShadow> shadowMd(Color c) => [
    BoxShadow(color: c.withOpacity(0.14), blurRadius: 18, offset: const Offset(0, 6)),
  ];
  static List<BoxShadow> shadowLg(Color c) => [
    BoxShadow(color: c.withOpacity(0.20), blurRadius: 28, offset: const Offset(0, 10)),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE HELPER
// Reads actual device pixel metrics; safe on every iPhone from SE to Pro Max.
// ─────────────────────────────────────────────────────────────────────────────
class _R {
  final double screenW;
  final double screenH;
  final double topPad;       // status bar + notch
  final double bottomPad;    // home indicator

  _R(BuildContext context)
      : screenW   = MediaQuery.sizeOf(context).width,
        screenH   = MediaQuery.sizeOf(context).height,
        topPad    = MediaQuery.paddingOf(context).top,
        bottomPad = MediaQuery.paddingOf(context).bottom;

  /// Scales a value relative to 390pt (iPhone 14 baseline).
  double s(double v) => v * (screenW / 390).clamp(0.80, 1.30);

  /// Scales font sizes — more conservative range.
  double f(double v) => v * (screenW / 390).clamp(0.85, 1.15);

  /// Horizontal content padding.
  double get hPad => s(20);
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  int _navIndex = 0;
  String userName = "Suraj"; // swap with auth provider

  // Tap-scale animation controllers per section
  late final AnimationController _cardCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 600),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    // iOS status bar: white icons on dark header
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤';
    if (h < 21) return 'Good Evening 🌙';
    return 'Good Night 🌛';
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _T.bg,
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            _Header(r: r, greeting: _greeting, userName: userName),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  left: r.hPad,
                  right: r.hPad,
                  top: r.s(20),
                  bottom: r.s(24),
                ),
                children: [
                  _LoanCard(r: r, onApply: () => _push(const LoanSchemeFormScreen())),
                  SizedBox(height: r.s(16)),
                  _PreApprovedBanner(r: r),
                  SizedBox(height: r.s(28)),
                  _SectionTitle(r: r, text: 'Services'),
                  SizedBox(height: r.s(16)),
                  _QuickActions(r: r, onTap: _handleQuickAction),
                  SizedBox(height: r.s(28)),
                  _SectionTitle(r: r, text: 'More Options'),
                  SizedBox(height: r.s(14)),
                  _MoreGrid(r: r, onTap: _handleGridTap),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          r: r,
          index: _navIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  // ── NAVIGATION HELPERS ───────────────────────────────────────────────────
  void _push(Widget screen) =>
      Navigator.push(context, _slide(screen));

  void _handleQuickAction(String label) {
    switch (label) {
      case 'Loan':       _push(const LoanSchemeFormScreen()); break;
      case 'Bot':        _push(const ChatbotScreen()); break;
      case 'Projection': _push(const OneYearTradingScreen()); break;
      case 'E-Book':     _push(const EbookScreen()); break;
    }
  }

  void _handleGridTap(String title) {
    switch (title) {
      case 'Register':     _push(const OtpLoginScreen()); break;
      case 'About':        Navigator.pushNamed(context, '/about'); break;
      case 'Premium':      Navigator.pushNamed(context, '/choosePlan'); break;
      case 'Loan Scheme':  _push(const LoanSchemeFormScreen()); break;
      case 'Financial':    _push(const OneYearTradingScreen()); break;
    }
  }

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
    if (i == 2) _showMoreSheet();
  }

  void _showMoreSheet() {
    final r = _R(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MoreSheet(r: r, onTap: _handleQuickAction),
    );
  }

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 320),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final _R r;
  final String greeting;
  final String userName;

  const _Header({required this.r, required this.greeting, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1D35), _T.navy],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(r.s(30)),
          bottomRight: Radius.circular(r.s(30)),
        ),
        boxShadow: _T.shadowLg(_T.navy),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top:    r.topPad + r.s(14),
          bottom: r.s(22),
          left:   r.hPad,
          right:  r.hPad,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: greeting + name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.60),
                      fontSize: r.f(13),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: r.s(4)),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: r.f(26),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            // Notification bell
            _HeaderIconBtn(
              icon: Icons.notifications_none_rounded,
              showDot: true,
              r: r,
            ),
            SizedBox(width: r.s(10)),

            // Avatar ring
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_T.goldLight, _T.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _T.navy,
                ),
                child: CircleAvatar(
                  radius: r.s(16),
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person_rounded,
                      color: Colors.white, size: r.s(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final _R r;
  const _HeaderIconBtn({required this.icon, required this.r, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(r.s(9)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: r.s(20)),
        ),
        if (showDot)
          Positioned(
            right: r.s(6), top: r.s(6),
            child: Container(
              width: r.s(8), height: r.s(8),
              decoration: BoxDecoration(
                color: _T.gold,
                shape: BoxShape.circle,
                border: Border.all(color: _T.navy, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOAN CARD
// ─────────────────────────────────────────────────────────────────────────────
class _LoanCard extends StatelessWidget {
  final _R r;
  final VoidCallback onApply;
  const _LoanCard({required this.r, required this.onApply});

  static double _emi(double amt, int mo, double rate) {
    final mr = rate / 12;
    final v = amt * mr * pow(1 + mr, mo) / (pow(1 + mr, mo) - 1);
    return v.isFinite ? v : 0;
  }

  @override
  Widget build(BuildContext context) {
    final emi = _emi(500000, 12, 0.12);
    return _Tap(
      onTap: onApply,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(1.2, 1.0),
            colors: [Color(0xFF162035), Color(0xFF0B1628)],
          ),
          borderRadius: BorderRadius.circular(r.s(_T.radiusLg)),
          boxShadow: _T.shadowLg(_T.navy),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative blobs
            Positioned(
              right: r.s(-28), top: r.s(-28),
              child: _Blob(r.s(140), _T.gold.withOpacity(0.07)),
            ),
            Positioned(
              right: r.s(28), top: r.s(18),
              child: _Blob(r.s(56), _T.gold.withOpacity(0.05)),
            ),
            Positioned(
              left: r.s(-20), bottom: r.s(-20),
              child: _Blob(r.s(90), Colors.white.withOpacity(0.03)),
            ),

            Padding(
              padding: EdgeInsets.all(r.s(22)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: badge + title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(r.s(9)),
                        decoration: BoxDecoration(
                          color: _T.gold.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(r.s(_T.radiusSm)),
                        ),
                        child: Icon(Icons.bolt_rounded,
                            color: _T.gold, size: r.s(20)),
                      ),
                      SizedBox(width: r.s(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Instant Loan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: r.f(18),
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              )),
                          Text('Up to ₹5,00,000',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: r.f(12),
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: r.s(20)),

                  // EMI row inside frosted tile
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.s(16), vertical: r.s(14)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(r.s(_T.radiusMd)),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.10), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estimated EMI',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.50),
                                    fontSize: r.f(11),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  )),
                              SizedBox(height: r.s(4)),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '₹${emi.toStringAsFixed(0)}/mo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r.f(24),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: r.s(12)),
                        // CTA button
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: r.s(20), vertical: r.s(13)),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4B03A), _T.gold],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                            BorderRadius.circular(r.s(40)),
                            boxShadow: [
                              BoxShadow(
                                color: _T.gold.withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            'Apply Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: r.f(13),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRE-APPROVED BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _PreApprovedBanner extends StatelessWidget {
  final _R r;
  const _PreApprovedBanner({required this.r});

  @override
  Widget build(BuildContext context) {
    return _Tap(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: r.s(16), vertical: r.s(14)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF9EC), Color(0xFFFDF5D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(r.s(_T.radiusMd)),
          border: Border.all(
              color: _T.gold.withOpacity(0.30), width: 1.2),
          boxShadow: _T.shadowSm(_T.gold),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.s(9)),
              decoration: BoxDecoration(
                color: _T.gold.withOpacity(0.15),
                borderRadius:
                BorderRadius.circular(r.s(_T.radiusSm)),
              ),
              child: Icon(Icons.verified_rounded,
                  color: _T.gold, size: r.s(22)),
            ),
            SizedBox(width: r.s(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pre-Approved Offer!',
                      style: TextStyle(
                        color: _T.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: r.f(13),
                      )),
                  SizedBox(height: r.s(2)),
                  Text(
                    'Eligible for ₹2,00,000 at 9.9% p.a.',
                    style: TextStyle(
                      color: _T.textSecondary,
                      fontSize: r.f(11.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: r.s(8)),
            Container(
              padding: EdgeInsets.all(r.s(7)),
              decoration: BoxDecoration(
                color: _T.gold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  color: _T.gold, size: r.s(15)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS ROW
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final _R r;
  final void Function(String) onTap;
  const _QuickActions({required this.r, required this.onTap});

  static const _items = [
    {'label': 'Loan',       'icon': Icons.currency_rupee_rounded, 'cat': 'navy'},
    {'label': 'Bot',        'icon': Icons.smart_toy_rounded,       'cat': 'violet'},
    {'label': 'Projection', 'icon': Icons.bar_chart_rounded,       'cat': 'green'},
    {'label': 'E-Book',     'icon': Icons.menu_book_rounded,       'cat': 'amber'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _items.map((item) {
        final colors = _T.cats[item['cat']]!;
        return _Tap(
          onTap: () => onTap(item['label'] as String),
          child: SizedBox(
            width: r.s(72),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: r.s(60),
                  height: r.s(60),
                  decoration: BoxDecoration(
                    color: colors[1],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: colors[0],
                    size: r.s(26),
                  ),
                ),
                SizedBox(height: r.s(10)),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _T.textPrimary,
                    fontSize: r.f(11.5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORE OPTIONS GRID
// ─────────────────────────────────────────────────────────────────────────────
class _MoreGrid extends StatelessWidget {
  final _R r;
  final void Function(String) onTap;
  const _MoreGrid({required this.r, required this.onTap});

  static const _cards = [
    {'title': 'Register',    'icon': Icons.person_add_rounded,       'cat': 'violet'},
    {'title': 'About',       'icon': Icons.info_rounded,             'cat': 'navy'},
    {'title': 'Premium',     'icon': Icons.workspace_premium_rounded,'cat': 'amber'},
    {'title': 'Loan Scheme', 'icon': Icons.account_balance_rounded,  'cat': 'navy'},
    {'title': 'Financial',   'icon': Icons.bar_chart_rounded,        'cat': 'green'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: r.s(14),
        mainAxisSpacing: r.s(14),
        childAspectRatio: 1.12,
      ),
      itemCount: _cards.length,
      itemBuilder: (_, i) {
        final card = _cards[i];
        final colors = _T.cats[card['cat']]!;
        return _Tap(
          onTap: () => onTap(card['title'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius:
              BorderRadius.circular(r.s(_T.radiusLg)),
              border: Border.all(color: _T.border, width: 0.8),
              boxShadow: _T.shadowSm(_T.navy),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(r.s(13)),
                  decoration: BoxDecoration(
                    color: colors[1],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(card['icon'] as IconData,
                      color: colors[0], size: r.s(26)),
                ),
                SizedBox(height: r.s(12)),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: r.s(8)),
                  child: Text(
                    card['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _T.textPrimary,
                      fontSize: r.f(13.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final _R r;
  final String text;
  const _SectionTitle({required this.r, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: r.s(4),
          height: r.s(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_T.goldLight, _T.gold],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(r.s(4)),
          ),
        ),
        SizedBox(width: r.s(10)),
        Text(
          text,
          style: TextStyle(
            color: _T.textPrimary,
            fontSize: r.f(17),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final _R r;
  final int index;
  final void Function(int) onTap;
  const _BottomNav(
      {required this.r, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        boxShadow: [
          BoxShadow(
            color: _T.navy.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: r.hPad,
            vertical: r.s(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                r: r,
                icon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => onTap(0),
              ),

              _NavItem(
                r: r,
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: index == 1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              _NavItem(
                r: r,
                icon: Icons.grid_view_rounded,
                label: 'More',
                selected: index == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _R r;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem(
      {required this.r,
        required this.icon,
        required this.label,
        required this.selected,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: r.s(selected ? 18 : 10), vertical: r.s(8)),
        decoration: BoxDecoration(
          color: selected ? _T.gold.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(r.s(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected ? _T.gold : _T.textSecondary,
                size: r.s(22)),
            if (selected) ...[
              SizedBox(width: r.s(6)),
              Text(
                label,
                style: TextStyle(
                  color: _T.gold,
                  fontSize: r.f(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORE BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _MoreSheet extends StatelessWidget {
  final _R r;
  final void Function(String) onTap;
  const _MoreSheet({required this.r, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(r.s(28))),
      ),
      padding: EdgeInsets.fromLTRB(
          r.hPad, r.s(12), r.hPad, r.bottomPad + r.s(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: r.s(40),
            height: r.s(4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(r.s(2)),
            ),
          ),
          SizedBox(height: r.s(20)),
          Text('More Services',
              style: TextStyle(
                fontSize: r.f(18),
                fontWeight: FontWeight.w800,
                color: _T.textPrimary,
              )),
          SizedBox(height: r.s(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SheetItem(r: r, icon: Icons.smart_toy_rounded, label: 'AI Bot',      onTap: () { Navigator.pop(context); onTap('Bot'); }),
              _SheetItem(r: r, icon: Icons.bar_chart_rounded,  label: 'Projection',  onTap: () { Navigator.pop(context); onTap('Projection'); }),
              _SheetItem(r: r, icon: Icons.menu_book_rounded,  label: 'E-Book',      onTap: () { Navigator.pop(context); onTap('E-Book'); }),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final _R r;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetItem(
      {required this.r,
        required this.icon,
        required this.label,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Tap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(r.s(14)),
            decoration: BoxDecoration(
              color: _T.gold.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _T.gold, size: r.s(26)),
          ),
          SizedBox(height: r.s(10)),
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: r.f(13),
                color: _T.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILITY WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Circular decorative blob
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob(this.size, this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Scale-on-tap wrapper — iOS-native feel, no ink splash
class _Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Tap({required this.child, required this.onTap});

  @override
  State<_Tap> createState() => _TapState();
}

class _TapState extends State<_Tap> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    reverseDuration: const Duration(milliseconds: 160),
    lowerBound: 0.94,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: _ctrl.value, child: child),
        child: widget.child,
      ),
    );
  }
}