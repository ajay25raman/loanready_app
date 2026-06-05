import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/presentation/screens/home/home_screen.dart';
import 'package:loanready_app/presentation/screens/register/profile_screen.dart';

import 'AlertsScreen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAIN NAVIGATION SCREEN
// Single Scaffold shell — owns the BottomNav + scroll-hide logic
// All tabs live inside IndexedStack → state & scroll preserved on tab switch
// ─────────────────────────────────────────────────────────────────────────────
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {

  // ── State ──────────────────────────────────────────────────────────────
  int _currentIndex = 0;

  // AnimationController drives nav bar slide (value 0 = visible, 1 = hidden)
  late final AnimationController _navCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: 0,
  );

  late final Animation<Offset> _navSlide = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 1),
  ).animate(CurvedAnimation(parent: _navCtrl, curve: Curves.easeInOut));

  // Each tab gets its own ScrollController — state preserved on tab switch
  final List<ScrollController> _scrollControllers = List.generate(
    3,
        (_) => ScrollController(),
  );

  // Track last scroll offset per tab to detect direction
  final List<double> _lastScrollOffset = [0.0, 0.0, 0.0];

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    for (int i = 0; i < _scrollControllers.length; i++) {
      final index = i;
      _scrollControllers[index].addListener(() => _onScroll(index));
    }
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Scroll Detection ───────────────────────────────────────────────────
  void _onScroll(int tabIndex) {
    // Only react to the currently active tab
    if (tabIndex != _currentIndex) return;

    final sc = _scrollControllers[tabIndex];
    if (!sc.hasClients) return;

    final current = sc.offset;
    final last    = _lastScrollOffset[tabIndex];
    final delta   = current - last;

    if (delta > 6 && _navCtrl.value == 0) {
      _navCtrl.forward(); // scrolling down → hide
    } else if (delta < -6 && _navCtrl.value == 1) {
      _navCtrl.reverse(); // scrolling up → show
    }

    _lastScrollOffset[tabIndex] = current;
  }

  // ── Tab Tap ────────────────────────────────────────────────────────────
  void _onTabTap(int index) {
    if (_currentIndex == index) {
      // Tap same tab → scroll to top
      if (_scrollControllers[index].hasClients) {
        _scrollControllers[index].animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    setState(() => _currentIndex = index);
    _navCtrl.reverse(); // always show nav on tab switch
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(scrollController: _scrollControllers[0]),
          AlertsScreen(scrollController: _scrollControllers[1]),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SlideTransition(
        position: _navSlide,
        child: _BottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV BAR  (private — shell owns it entirely)
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const _navy          = Color(0xFF0B1628);
  static const _gold          = Color(0xFFC9A227);
  static const _textSecondary = Color(0xFF6B7280);
  static const _surface       = Colors.white;

  static const _tabs = [
    {'icon': Icons.home_rounded,               'label': 'Home'},
    {'icon': Icons.notifications_none_rounded, 'label': 'Alerts'},
    {'icon': Icons.person_rounded,             'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    double s(double v) => v * (w / 390).clamp(0.80, 1.30);
    double f(double v) => v * (w / 390).clamp(0.85, 1.15);

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: s(20),
            vertical: s(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final selected = i == currentIndex;
              final tab      = _tabs[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: s(selected ? 18 : 10),
                    vertical: s(8),
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? _gold.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(s(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        color: selected ? _gold : _textSecondary,
                        size: s(22),
                      ),
                      if (selected) ...[
                        SizedBox(width: s(6)),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            color: _gold,
                            fontSize: f(13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}