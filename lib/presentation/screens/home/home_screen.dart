import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/presentation/screens/home/ebook_screen.dart';
import 'package:loanready_app/presentation/screens/home/one_year_trading_screen.dart';
import '../auth/otp_login_screen.dart';
import '../chatbot/ai_service.dart';
import '../loan/loan_scheme.dart';
import '../register/profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static const Color navy          = Color(0xFF0B1628);
  static const Color navyLight     = Color(0xFF162035);
  static const Color gold          = Color(0xFFC9A227);
  static const Color goldLight     = Color(0xFFD4B44A);
  static const Color bg            = Color(0xFFF2F4F8);
  static const Color surface       = Colors.white;
  static const Color textPrimary   = Color(0xFF0B1628);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border        = Color(0xFFE5E7EB);

  static const Map<String, List<Color>> cats = {
    'navy':   [Color(0xFF0B1628), Color(0xFFEAECF2)],
    'violet': [Color(0xFF5B50E8), Color(0xFFEEEDFD)],
    'green':  [Color(0xFF0A9464), Color(0xFFE4F6EF)],
    'amber':  [Color(0xFFD97706), Color(0xFFFEF3E2)],
    'rose':   [Color(0xFFE84F6E), Color(0xFFFDECF1)],
  };

  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;

  static List<BoxShadow> shadowSm(Color c) => [
    BoxShadow(color: c.withOpacity(0.10), blurRadius: 8,  offset: const Offset(0, 3)),
  ];
  static List<BoxShadow> shadowLg(Color c) => [
    BoxShadow(color: c.withOpacity(0.20), blurRadius: 28, offset: const Offset(0, 10)),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _R {
  final double screenW;
  final double topPad;
  final double bottomPad;

  _R(BuildContext context)
      : screenW   = MediaQuery.sizeOf(context).width,
        topPad    = MediaQuery.paddingOf(context).top,
        bottomPad = MediaQuery.paddingOf(context).bottom;

  double s(double v) => v * (screenW / 390).clamp(0.80, 1.30);
  double f(double v) => v * (screenW / 390).clamp(0.85, 1.15);
  double get hPad => s(20);
}

// ─────────────────────────────────────────────────────────────────────────────
// TIPS DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _TipItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String cat;
  final String tag;
  const _TipItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cat,
    required this.tag,
  });
}

const _tips = [
  _TipItem(
    title: 'Improve Your CIBIL Score to 750+',
    subtitle: 'Pay your EMIs on time and keep credit utilisation below 30% for a strong credit profile.',
    icon: Icons.credit_score_rounded,
    cat: 'green',
    tag: 'Tip',
  ),
  _TipItem(
    title: 'Documents Required for a Loan',
    subtitle: 'Keep Aadhaar, PAN, 3-month salary slips, and 6-month bank statements ready before applying.',
    icon: Icons.folder_copy_rounded,
    cat: 'violet',
    tag: 'Checklist',
  ),
  _TipItem(
    title: 'How to Choose the Right Loan Amount',
    subtitle: 'Your EMI should not exceed 40% of your monthly income — this protects your financial health.',
    icon: Icons.balance_rounded,
    cat: 'amber',
    tag: 'Guide',
  ),
  _TipItem(
    title: 'Business Loan vs Personal Loan',
    subtitle: 'Business loans offer tax benefits while personal loans are more flexible with fewer restrictions.',
    icon: Icons.compare_arrows_rounded,
    cat: 'navy',
    tag: 'News',
  ),
  _TipItem(
    title: 'Understand the Risk of Being a Guarantor',
    subtitle: 'Before becoming a guarantor for someone, make sure you understand the legal and financial risks involved.',
    icon: Icons.warning_amber_rounded,
    cat: 'rose',
    tag: 'Alert',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN
// scrollController is injected from MainNavigationScreen
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final ScrollController scrollController;

  const HomeScreen({super.key, required this.scrollController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userName = "Suraj";

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤';
    if (h < 21) return 'Good Evening 🌙';
    return 'Good Night 🌛';
  }
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
                controller: widget.scrollController,
                padding: EdgeInsets.only(
                  left: r.hPad,
                  right: r.hPad,
                  top: r.s(20),
                  bottom: r.s(24),
                ),
                children: [
                  _SectionTitle(r: r, text: 'Services'),
                  SizedBox(height: r.s(16)),
                  _QuickActions(r: r, onTap: _handleQuickAction),
                  SizedBox(height: r.s(28)),
                  _SectionTitle(r: r, text: 'More Options'),
                  SizedBox(height: r.s(14)),
                  _MoreGrid(r: r, onTap: _handleGridTap),
                  SizedBox(height: r.s(28)),
                  _SectionTitle(r: r, text: 'Tips & News'),
                  SizedBox(height: r.s(14)),
                  _TipsNews(r: r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────
  void _push(Widget screen) => Navigator.push(context, _slide(screen));

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
      case 'Register':    _push(const OtpLoginScreen()); break;
      case 'About':       Navigator.pushNamed(context, '/about'); break;
      case 'Premium':     Navigator.pushNamed(context, '/choosePlan'); break;
      case 'Loan Scheme': _push(const LoanSchemeFormScreen()); break;
      case 'Financial':   _push(const OneYearTradingScreen()); break;
    }
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
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final _R r;
  final String greeting;
  final String userName;
  const _Header({
    required this.r,
    required this.greeting,
    required this.userName,
  });

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
            _HeaderIconBtn(
              icon: Icons.notifications_none_rounded,
              showDot: true,
              r: r,
            ),
            SizedBox(width: r.s(10)),
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
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: r.s(18),
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

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final _R r;
  const _HeaderIconBtn({
    required this.icon,
    required this.r,
    this.showDot = false,
  });

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
            right: r.s(6),
            top: r.s(6),
            child: Container(
              width: r.s(8),
              height: r.s(8),
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
// QUICK ACTIONS
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
    {'title': 'Register',    'icon': Icons.person_add_rounded,        'cat': 'violet'},
    {'title': 'About',       'icon': Icons.info_rounded,              'cat': 'navy'},
    {'title': 'Premium',     'icon': Icons.workspace_premium_rounded, 'cat': 'amber'},
    {'title': 'Loan Scheme', 'icon': Icons.account_balance_rounded,   'cat': 'navy'},
    {'title': 'Financial',   'icon': Icons.bar_chart_rounded,         'cat': 'green'},
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
        final card   = _cards[i];
        final colors = _T.cats[card['cat']]!;
        return _Tap(
          onTap: () => onTap(card['title'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(r.s(_T.radiusLg)),
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
                  child: Icon(
                    card['icon'] as IconData,
                    color: colors[0],
                    size: r.s(26),
                  ),
                ),
                SizedBox(height: r.s(12)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.s(8)),
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
// TIPS & NEWS
// ─────────────────────────────────────────────────────────────────────────────
class _TipsNews extends StatelessWidget {
  final _R r;
  const _TipsNews({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _tips.map((tip) {
        final colors = _T.cats[tip.cat]!;
        return Padding(
          padding: EdgeInsets.only(bottom: r.s(12)),
          child: _Tap(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(r.s(_T.radiusLg)),
                border: Border.all(color: _T.border, width: 0.8),
                boxShadow: _T.shadowSm(_T.navy),
              ),
              padding: EdgeInsets.all(r.s(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(r.s(11)),
                    decoration: BoxDecoration(
                      color: colors[1],
                      borderRadius: BorderRadius.circular(r.s(_T.radiusMd)),
                    ),
                    child: Icon(tip.icon, color: colors[0], size: r.s(22)),
                  ),
                  SizedBox(width: r.s(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.s(8),
                            vertical: r.s(3),
                          ),
                          decoration: BoxDecoration(
                            color: colors[1],
                            borderRadius: BorderRadius.circular(r.s(20)),
                          ),
                          child: Text(
                            tip.tag,
                            style: TextStyle(
                              color: colors[0],
                              fontSize: r.f(10),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        SizedBox(height: r.s(6)),
                        Text(
                          tip.title,
                          style: TextStyle(
                            color: _T.textPrimary,
                            fontSize: r.f(13.5),
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: r.s(4)),
                        Text(
                          tip.subtitle,
                          style: TextStyle(
                            color: _T.textSecondary,
                            fontSize: r.f(12),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: r.s(6)),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: r.s(13),
                    color: _T.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
// UTILITY — scale-on-tap wrapper
// ─────────────────────────────────────────────────────────────────────────────
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown:   (_) => _ctrl.reverse(),
      onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
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