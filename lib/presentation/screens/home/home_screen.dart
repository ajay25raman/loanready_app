// // ignore_for_file: unused_import
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:loanready_app/presentation/screens/home/ebook_screen.dart';
// import 'package:loanready_app/presentation/screens/home/one_year_trading_screen.dart';
// import 'package:loanready_app/presentation/screens/reports/one_year_report_view_screen.dart';
// import 'package:loanready_app/presentation/screens/reports/one_year_reports_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../Model/user_model.dart';
// import '../../../controllers/user_controller.dart';
// import '../../../providers/user_provider.dart';
// import '../auth/otp_login_screen.dart';
// import '../chatbot/ai_service.dart';
// import '../loan/loan_scheme.dart';
// import '../register/profile_screen.dart';
// import 'financial_statement_screen.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // DESIGN TOKENS
// // ─────────────────────────────────────────────────────────────────────────────
// class _T {
//   static const Color navy          = Color(0xFF0B1628);
//   static const Color navyDeep      = Color(0xFF060D1C);
//   static const Color navyLight     = Color(0xFF162035);
//   static const Color gold          = Color(0xFFC9A227);
//   static const Color goldLight     = Color(0xFFE7C766);
//   static const Color bg            = Color(0xFFF3F5F9);
//   static const Color surface       = Colors.white;
//   static const Color textPrimary   = Color(0xFF0B1628);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color textTertiary  = Color(0xFF9AA1AE);
//   static const Color border        = Color(0xFFE7E9F0);
//
//   // Gold reserved strictly as an accent — used sparingly (badges, dividers,
//   // key CTAs) rather than as a dominant surface color.
//   static const Map<String, List<Color>> cats = {
//     'navy':   [Color(0xFF0B1628), Color(0xFFEAECF2)],
//     'violet': [Color(0xFF5B50E8), Color(0xFFEEEDFD)],
//     'green':  [Color(0xFF0A9464), Color(0xFFE4F6EF)],
//     'amber':  [Color(0xFFD97706), Color(0xFFFEF3E2)],
//     'rose':   [Color(0xFFE84F6E), Color(0xFFFDECF1)],
//   };
//
//   // Standardized spacing scale
//   static const double sp8  = 8;
//   static const double sp16 = 16;
//   static const double sp24 = 24;
//   static const double sp32 = 32;
//
//   // Standardized radius scale
//   static const double radiusSm = 14;
//   static const double radiusMd = 20;
//   static const double radiusLg = 24;
//   static const double radiusXl = 24;
//
//
//   static List<BoxShadow> shadowSm(Color c) => [
//     BoxShadow(color: c.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
//   ];
//   static List<BoxShadow> shadowMd(Color c) => [
//     BoxShadow(color: c.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 8)),
//   ];
//   static List<BoxShadow> shadowLg(Color c) => [
//     BoxShadow(color: c.withOpacity(0.18), blurRadius: 32, offset: const Offset(0, 14)),
//   ];
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // RESPONSIVE HELPER
// // ─────────────────────────────────────────────────────────────────────────────
// class _R {
//   final double screenW;
//   final double topPad;
//   final double bottomPad;
//
//   _R(BuildContext context)
//       : screenW   = MediaQuery.sizeOf(context).width,
//         topPad    = MediaQuery.paddingOf(context).top,
//         bottomPad = MediaQuery.paddingOf(context).bottom;
//
//   double s(double v) => v * (screenW / 390).clamp(0.80, 1.30);
//   double f(double v) => v * (screenW / 390).clamp(0.85, 1.15);
//   double get hPad => s(20);
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // TIPS DATA MODEL
// // ─────────────────────────────────────────────────────────────────────────────
// class _TipItem {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final String cat;
//   final String tag;
//   const _TipItem({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.cat,
//     required this.tag,
//   });
// }
//
// const _tips = [
//   _TipItem(
//     title: 'Improve Your CIBIL Score to 750+',
//     subtitle: 'Pay your EMIs on time and keep credit utilisation below 30% for a strong credit profile.',
//     icon: Icons.credit_score_rounded,
//     cat: 'green',
//     tag: 'Tip',
//   ),
//   _TipItem(
//     title: 'Documents Required for a Loan',
//     subtitle: 'Keep Aadhaar, PAN, 3-month salary slips, and 6-month bank statements ready before applying.',
//     icon: Icons.folder_copy_rounded,
//     cat: 'violet',
//     tag: 'Checklist',
//   ),
//   _TipItem(
//     title: 'How to Choose the Right Loan Amount',
//     subtitle: 'Your EMI should not exceed 40% of your monthly income — this protects your financial health.',
//     icon: Icons.balance_rounded,
//     cat: 'amber',
//     tag: 'Guide',
//   ),
//   _TipItem(
//     title: 'Business Loan vs Personal Loan',
//     subtitle: 'Business loans offer tax benefits while personal loans are more flexible with fewer restrictions.',
//     icon: Icons.compare_arrows_rounded,
//     cat: 'navy',
//     tag: 'News',
//   ),
//   _TipItem(
//     title: 'Understand the Risk of Being a Guarantor',
//     subtitle: 'Before becoming a guarantor for someone, make sure you understand the legal and financial risks involved.',
//     icon: Icons.warning_amber_rounded,
//     cat: 'rose',
//     tag: 'Alert',
//   ),
// ];
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HOME SCREEN
// // scrollController is injected from MainNavigationScreen
// // ─────────────────────────────────────────────────────────────────────────────
// class HomeScreen extends StatefulWidget {
//   final ScrollController scrollController;
//
//   const HomeScreen({super.key, required this.scrollController});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   String get _greeting {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good Morning ☀️';
//     if (h < 17) return 'Good Afternoon 🌤';
//     if (h < 21) return 'Good Evening 🌙';
//     return 'Good Night 🌛';
//   }
//
//   Future<void> _openWebsite() async {
//     final Uri url = Uri.parse("https://themsmcconsultants.com");
//
//     await launchUrl(
//       url,
//       mode: LaunchMode.externalApplication,
//     );
//   }
//
//
//   Future<void> _openEmail() async {
//     final Uri email = Uri.parse(
//       "mailto:info@themsmcconsultants.com",
//     );
//
//     await launchUrl(email);
//   }
//
//   Future<void> _openPhone() async {
//     final Uri phone = Uri.parse("tel:+91824 092 8803");
//     await launchUrl(phone);
//   }
//
//
//   Future<void> _openLocation() async {
//     final Uri location = Uri.parse(
//       "https://www.google.com/maps/search/?api=1&query=MSMC+Consultants",
//     );
//     await launchUrl(location, mode: LaunchMode.externalApplication);
//   }
//
//   late UserController controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller = UserController();
//
//     Future.microtask(() {
//       controller.fetchCurrentUser(
//         context.read<UserProvider>(),
//       );
//     });
//   }
//
//   Future<void> _openFinancialReports() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     final isGuest = prefs.getBool('is_guest') ?? false;
//
//     debugPrint('IS GUEST: $isGuest');
//
//     if (isGuest) {
//       if (!mounted) return;
//
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text(
//               'Login Required',
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             content: const Text(
//               'Please login to access Financial Reports.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//
//                   _push(
//                     const OtpLoginScreen(),
//                   );
//                 },
//                 child: const Text('Login'),
//               ),
//             ],
//           );
//         },
//       );
//
//       return;
//     }
//
//     _push(
//       const OneYearReportsScreen(),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     final r = _R(context);
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         backgroundColor: _T.bg,
//         extendBodyBehindAppBar: true,
//         body: Column(
//           children: [
//             Consumer<UserProvider>(
//               builder: (_, provider, __) {
//                 return _Header(
//                   r: r,
//                   greeting: _greeting,
//                   user: provider.user,
//                   isLoading: provider.loading,
//                 );
//               },
//             ),
//             Expanded(
//               child: ListView(
//                 controller: widget.scrollController,
//                 padding: EdgeInsets.only(
//                   left: r.hPad,
//                   right: r.hPad,
//                   top: r.s(20),
//                   bottom: r.s(24),
//                 ),
//                 children: [
//                   _SectionTitle(r: r, text: 'Services'),
//                   SizedBox(height: r.s(16)),
//                   _QuickActions(r: r, onTap: _handleQuickAction),
//                   SizedBox(height: r.s(28)),
//                   _SectionTitle(r: r, text: 'More Options'),
//                   SizedBox(height: r.s(14)),
//                   _MoreGrid(r: r, onTap: _handleGridTap),
//                   SizedBox(height: r.s(28)),
//                   _SectionTitle(r: r, text: 'Tips & News'),
//                   SizedBox(height: r.s(14)),
//                   _TipsNews(r: r),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Navigation ─────────────────────────────────────────────────────────
//   void _push(Widget screen) => Navigator.push(context, _slide(screen));
//
//   void _handleQuickAction(String label) {
//     switch (label) {
//       case 'Loan':
//         _push(const LoanSchemeFormScreen());
//         break;
//
//       case 'Bot':
//         _push(const ChatbotScreen());
//         break;
//
//       case 'Financial':
//         _push(const FinancialStatementScreen());
//         break;
//
//       case 'Projection':
//         _push(const OneYearTradingScreen());
//         break;
//
//       case 'E-Book':
//         _push(const EbookScreen());
//         break;
//
//       case 'Website':
//         _openWebsite();
//         break;
//
//       case 'Email':
//         _openEmail();
//         break;
//     }
//   }
//
//
//
//   void _handleGridTap(String title) {
//     switch (title) {
//       case 'Register':
//         _push(const OtpLoginScreen());
//         break;
//
//       case 'About':
//         Navigator.pushNamed(
//           context,
//           '/about',
//         );
//         break;
//
//       case 'Plans':
//         Navigator.pushNamed(
//           context,
//           '/choosePlan',
//         );
//         break;
//
//       case 'Loan Scheme':
//         _push(
//           const LoanSchemeFormScreen(),
//         );
//         break;
//
//       case 'Business Projections':
//         _push(
//           const OneYearTradingScreen(),
//         );
//         break;
//
//       case 'Financial Generator':
//         _openFinancialReports();
//         break;
//
//       case 'E-Book':
//         _push(
//           const EbookScreen(),
//         );
//         break;
//     }
//   }
//
//   static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
//     pageBuilder: (_, a, __) => page,
//     transitionsBuilder: (_, a, __, child) => SlideTransition(
//       position: Tween(begin: const Offset(1, 0), end: Offset.zero)
//           .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
//       child: child,
//     ),
//     transitionDuration: const Duration(milliseconds: 320),
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HEADER
// // ─────────────────────────────────────────────────────────────────────────────
// class _Header extends StatelessWidget {
//   final _R r;
//   final String greeting;
//   final UserModel? user;
//   final bool isLoading;
//
//   const _Header({
//     required this.r,
//     required this.greeting,
//     this.user,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final name = user?.fullName ?? "Guest";
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [Color(0xFF0F1D35), _T.navy],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(r.s(30)),
//           bottomRight: Radius.circular(r.s(30)),
//         ),
//         boxShadow: _T.shadowLg(_T.navy),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//           top: r.topPad + r.s(14),
//           bottom: r.s(22),
//           left: r.hPad,
//           right: r.hPad,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     greeting,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.60),
//                       fontSize: r.f(13),
//                       fontWeight: FontWeight.w500,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                   SizedBox(height: r.s(4)),
//                   isLoading
//                       ? Shimmer.fromColors(
//                           baseColor: Colors.white.withOpacity(0.1),
//                           highlightColor: Colors.white.withOpacity(0.2),
//                           child: Container(
//                             width: r.s(120),
//                             height: r.f(26),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(r.s(4)),
//                             ),
//                           ),
//                         )
//                       : Text(
//                           name,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: r.f(26),
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: -0.6,
//                             height: 1.1,
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//             _HeaderIconBtn(
//               icon: Icons.notifications_none_rounded,
//               showDot: true,
//               r: r,
//             ),
//             SizedBox(width: r.s(10)),
//             _UserAvatar(user: user, r: r, isLoading: isLoading),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _UserAvatar extends StatelessWidget {
//   final UserModel? user;
//   final _R r;
//   final bool isLoading;
//
//   const _UserAvatar({this.user, required this.r, this.isLoading = false});
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Shimmer.fromColors(
//         baseColor: Colors.white.withOpacity(0.1),
//         highlightColor: Colors.white.withOpacity(0.2),
//         child: Container(
//           width: r.s(37),
//           height: r.s(37),
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white,
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(2.5),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: const LinearGradient(
//           colors: [_T.goldLight, _T.gold],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(2),
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: _T.navy,
//         ),
//         child: CircleAvatar(
//           radius: r.s(16),
//           backgroundColor: Colors.transparent,
//           backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
//               ? NetworkImage(user!.photoUrl!)
//               : null,
//           child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
//               ? Text(
//                   user?.initials ?? "?",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: r.f(12),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )
//               : null,
//         ),
//       ),
//     );
//   }
// }
//
// class _HeaderIconBtn extends StatelessWidget {
//   final IconData icon;
//   final bool showDot;
//   final _R r;
//   const _HeaderIconBtn({
//     required this.icon,
//     required this.r,
//     this.showDot = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           padding: EdgeInsets.all(r.s(9)),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.10),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white, size: r.s(20)),
//         ),
//         if (showDot)
//           Positioned(
//             right: r.s(6),
//             top: r.s(6),
//             child: Container(
//               width: r.s(8),
//               height: r.s(8),
//               decoration: BoxDecoration(
//                 color: _T.gold,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: _T.navy, width: 1.5),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HERO CARD — new premium welcome banner beneath the header
// // ─────────────────────────────────────────────────────────────────────────────
// class _HeroCard extends StatelessWidget {
//   final _R r;
//   final String userName;
//   const _HeroCard({required this.r, required this.userName});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(r.s(_T.sp24)),
//       decoration: BoxDecoration(
//         color: _T.surface,
//         borderRadius: BorderRadius.circular(r.s(_T.radiusLg)),
//         border: Border.all(color: _T.border, width: 0.8),
//         boxShadow: _T.shadowSm(_T.navy),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: r.s(6),
//                       height: r.s(6),
//                       decoration: const BoxDecoration(
//                         color: _T.gold,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     SizedBox(width: r.s(6)),
//                     Expanded(
//                       child: Text(
//                         'EMPOWERING YOUR FINANCIAL JOURNEY',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: _T.textTertiary,
//                           fontSize: r.f(10.5),
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: r.s(10)),
//                 Text(
//                   'Your Finances, Sorted.',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: _T.textPrimary,
//                     fontSize: r.f(19),
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.4,
//                     height: 1.15,
//                   ),
//                 ),
//                 SizedBox(height: r.s(6)),
//                 Text(
//                   'Track loans, generate financial statements and plan ahead — all in one premium dashboard.',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: _T.textSecondary,
//                     fontSize: r.f(12.5),
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: r.s(14)),
//           Container(
//             width: r.s(56),
//             height: r.s(56),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [_T.goldLight, _T.gold],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(r.s(16)),
//               boxShadow: [
//                 BoxShadow(
//                   color: _T.gold.withOpacity(0.28),
//                   blurRadius: 14,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Icon(Icons.trending_up_rounded, color: _T.navy, size: r.s(26)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SERVICES — premium rectangular action cards (4 primary actions)
// // ─────────────────────────────────────────────────────────────────────────────
// class _PrimaryActions extends StatelessWidget {
//   final _R r;
//   final void Function(String) onTap;
//   const _PrimaryActions({required this.r, required this.onTap});
//
//   static const _items = [
//     {
//       'label': 'Loan',
//       'title': 'Apply for a Loan',
//       'subtitle': 'Explore schemes tailored to your business',
//       'icon': Icons.currency_rupee_rounded,
//       'cat': 'navy',
//     },
//     {
//       'label': 'Bot',
//       'title': 'AI Assistant',
//       'subtitle': 'Get instant answers on loans & eligibility',
//       'icon': Icons.smart_toy_rounded,
//       'cat': 'violet',
//     },
//     {
//       'label': 'Financial',
//       'title': 'Financial Statement',
//       'subtitle': 'Generate a clean, shareable statement',
//       'icon': Icons.description_rounded,
//       'cat': 'green',
//     },
//     {
//       'label': 'Projection',
//       'title': 'Business Projection',
//       'subtitle': 'View your one year trading outlook',
//       'icon': Icons.bar_chart_rounded,
//       'cat': 'rose',
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: _items.map((item) {
//         final colors = _T.cats[item['cat'] as String]!;
//         final isLast = item == _items.last;
//         return Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : r.s(_T.sp16)),
//           child: _Tap(
//             onTap: () => onTap(item['label'] as String),
//             child: Container(
//               padding: EdgeInsets.all(r.s(_T.sp16)),
//               decoration: BoxDecoration(
//                 color: _T.surface,
//                 borderRadius: BorderRadius.circular(r.s(_T.radiusMd)),
//                 border: Border.all(color: _T.border, width: 0.8),
//                 boxShadow: _T.shadowSm(_T.navy),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: r.s(50),
//                     height: r.s(50),
//                     decoration: BoxDecoration(
//                       color: colors[1],
//                       borderRadius: BorderRadius.circular(r.s(14)),
//                     ),
//                     child: Icon(
//                       item['icon'] as IconData,
//                       color: colors[0],
//                       size: r.s(24),
//                     ),
//                   ),
//                   SizedBox(width: r.s(14)),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item['title'] as String,
//                           style: TextStyle(
//                             color: _T.textPrimary,
//                             fontSize: r.f(14.5),
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                         SizedBox(height: r.s(3)),
//                         Text(
//                           item['subtitle'] as String,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: _T.textSecondary,
//                             fontSize: r.f(11.5),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: r.s(8)),
//                   Container(
//                     padding: EdgeInsets.all(r.s(7)),
//                     decoration: BoxDecoration(
//                       color: _T.bg,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       size: r.s(11),
//                       color: _T.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
//
// // ─────────────────────────────────────────────────────────────────────────────
// // QUICK ACTIONS
// // ─────────────────────────────────────────────────────────────────────────────
// class _QuickActions extends StatelessWidget {
//   final _R r;
//   final void Function(String) onTap;
//   const _QuickActions({required this.r, required this.onTap});
//
//   static const _items = [
//     {'label': 'Loan',       'icon': Icons.currency_rupee_rounded, 'cat': 'navy'},
//     {'label': 'Bot',        'icon': Icons.smart_toy_rounded,       'cat': 'violet'},
//     {'label': 'Projection', 'icon': Icons.bar_chart_rounded,       'cat': 'green'},
//     {'label': 'E-Book',     'icon': Icons.menu_book_rounded,       'cat': 'amber'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: _items.map((item) {
//         final colors = _T.cats[item['cat']]!;
//         return _Tap(
//           onTap: () => onTap(item['label'] as String),
//           child: SizedBox(
//             width: r.s(72),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: r.s(60),
//                   height: r.s(60),
//                   decoration: BoxDecoration(
//                     color: colors[1],
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: colors[0].withOpacity(0.12),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     item['icon'] as IconData,
//                     color: colors[0],
//                     size: r.s(26),
//                   ),
//                 ),
//                 SizedBox(height: r.s(10)),
//                 Text(
//                   item['label'] as String,
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: _T.textPrimary,
//                     fontSize: r.f(11.5),
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // MORE OPTIONS GRID
// // ─────────────────────────────────────────────────────────────────────────────
// class _MoreGrid extends StatelessWidget {
//   final _R r;
//   final void Function(String) onTap;
//   const _MoreGrid({required this.r, required this.onTap});
//
//   static const _cards = [
//     // {'title': 'Register',    'icon': Icons.person_add_rounded,        'cat': 'violet'},
//     {'title': 'About',       'icon': Icons.info_rounded,              'cat': 'navy'},
//     {'title': 'Plans',     'icon': Icons.workspace_premium_rounded, 'cat': 'amber'},
//     {'title': 'Loan Scheme', 'icon': Icons.account_balance_rounded,   'cat': 'navy'},
//     {'title': 'Business Projections',   'icon': Icons.bar_chart_rounded,         'cat': 'green'},
//     {'title': 'Financial Generator', 'icon': Icons.description_rounded, 'cat': 'green'},
//     {'title': 'E-Book', 'icon': Icons.menu_book_rounded, 'cat': 'amber'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: r.s(14),
//         mainAxisSpacing: r.s(14),
//         childAspectRatio: 1.12,
//       ),
//       itemCount: _cards.length,
//       itemBuilder: (_, i) {
//         final card   = _cards[i];
//         final colors = _T.cats[card['cat']]!;
//         return _Tap(
//           onTap: () => onTap(card['title'] as String),
//           child: Container(
//             decoration: BoxDecoration(
//               color: _T.surface,
//               borderRadius: BorderRadius.circular(r.s(_T.radiusLg)),
//               border: Border.all(color: _T.border, width: 0.8),
//               boxShadow: _T.shadowSm(_T.navy),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(r.s(13)),
//                   decoration: BoxDecoration(
//                     color: colors[1],
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     card['icon'] as IconData,
//                     color: colors[0],
//                     size: r.s(26),
//                   ),
//                 ),
//                 SizedBox(height: r.s(12)),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: r.s(8)),
//                   child: Text(
//                     card['title'] as String,
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: _T.textPrimary,
//                       fontSize: r.f(13.5),
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: -0.2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // TIPS & NEWS
// // ─────────────────────────────────────────────────────────────────────────────
// // ─────────────────────────────────────────────────────────────────────────────
// // TIPS & NEWS — refined cards with badges + read more indicator
// // ─────────────────────────────────────────────────────────────────────────────
// class _TipsNews extends StatelessWidget {
//   final _R r;
//   const _TipsNews({required this.r});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: _tips.map((tip) {
//         final colors = _T.cats[tip.cat]!;
//         final isLast = tip == _tips.last;
//         return Padding(
//           padding: EdgeInsets.only(bottom: isLast ? 0 : r.s(_T.sp16)),
//           child: _Tap(
//             onTap: () {},
//             child: Container(
//               decoration: BoxDecoration(
//                 color: _T.surface,
//                 borderRadius: BorderRadius.circular(r.s(_T.radiusMd)),
//                 border: Border.all(color: _T.border, width: 0.8),
//                 boxShadow: _T.shadowSm(_T.navy),
//               ),
//               padding: EdgeInsets.all(r.s(_T.sp16)),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(r.s(11)),
//                     decoration: BoxDecoration(
//                       color: colors[1],
//                       borderRadius: BorderRadius.circular(r.s(14)),
//                     ),
//                     child: Icon(tip.icon, color: colors[0], size: r.s(22)),
//                   ),
//                   SizedBox(width: r.s(14)),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: r.s(9),
//                             vertical: r.s(3.5),
//                           ),
//                           decoration: BoxDecoration(
//                             color: colors[1],
//                             borderRadius: BorderRadius.circular(r.s(20)),
//                             border: Border.all(color: colors[0].withOpacity(0.15)),
//                           ),
//                           child: Text(
//                             tip.tag,
//                             style: TextStyle(
//                               color: colors[0],
//                               fontSize: r.f(10),
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: r.s(8)),
//                         Text(
//                           tip.title,
//                           style: TextStyle(
//                             color: _T.textPrimary,
//                             fontSize: r.f(13.5),
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: -0.2,
//                           ),
//                         ),
//                         SizedBox(height: r.s(4)),
//                         Text(
//                           tip.subtitle,
//                           style: TextStyle(
//                             color: _T.textSecondary,
//                             fontSize: r.f(12),
//                             height: 1.45,
//                           ),
//                         ),
//                         SizedBox(height: r.s(10)),
//                         Row(
//                           children: [
//                             Text(
//                               'Read More',
//                               style: TextStyle(
//                                 color: _T.gold,
//                                 fontSize: r.f(11),
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             SizedBox(width: r.s(4)),
//                             Icon(
//                               Icons.arrow_forward_rounded,
//                               size: r.s(13),
//                               color: _T.gold,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SECTION TITLE
// // ─────────────────────────────────────────────────────────────────────────────
// // ─────────────────────────────────────────────────────────────────────────────
// // SECTION TITLE
// // ─────────────────────────────────────────────────────────────────────────────
// class _SectionTitle extends StatelessWidget {
//   final _R r;
//   final String text;
//   const _SectionTitle({required this.r, required this.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: r.s(4),
//           height: r.s(18),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [_T.goldLight, _T.gold],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             borderRadius: BorderRadius.circular(r.s(4)),
//           ),
//         ),
//         SizedBox(width: r.s(10)),
//         Text(
//           text,
//           style: TextStyle(
//             color: _T.textPrimary,
//             fontSize: r.f(17),
//             fontWeight: FontWeight.w800,
//             letterSpacing: -0.3,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // CONTACT SECTION — replaces the old brand footer
// // ─────────────────────────────────────────────────────────────────────────────
// class _ContactSection extends StatelessWidget {
//   final _R r;
//   final VoidCallback onWebsite;
//   final VoidCallback onEmail;
//   final VoidCallback onPhone;
//   final VoidCallback onLocation;
//   const _ContactSection({
//     required this.r,
//     required this.onWebsite,
//     required this.onEmail,
//     required this.onPhone,
//     required this.onLocation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(r.s(_T.sp24)),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [_T.navyDeep, _T.navy],
//         ),
//         borderRadius: BorderRadius.circular(r.s(_T.radiusXl)),
//         boxShadow: _T.shadowMd(_T.navy),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(r.s(9)),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [_T.goldLight, _T.gold],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(r.s(12)),
//                 ),
//                 child: Icon(Icons.verified_rounded, color: _T.navy, size: r.s(18)),
//               ),
//               SizedBox(width: r.s(10)),
//               Expanded(
//                 child: Text(
//                   'Contact MSMC Consultants',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: r.f(15),
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: r.s(10)),
//           Text(
//             'Trusted financial consultants helping businesses access the right loans, plan smarter and grow with confidence.',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.55),
//               fontSize: r.f(12),
//               height: 1.5,
//             ),
//           ),
//           SizedBox(height: r.s(20)),
//           Row(
//             children: [
//               Expanded(
//                 child: _ContactTile(
//                   r: r,
//                   icon: Icons.language_rounded,
//                   label: 'Website',
//                   onTap: onWebsite,
//                 ),
//               ),
//               SizedBox(width: r.s(10)),
//               Expanded(
//                 child: _ContactTile(
//                   r: r,
//                   icon: Icons.email_rounded,
//                   label: 'Email',
//                   onTap: onEmail,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: r.s(10)),
//           Row(
//             children: [
//               Expanded(
//                 child: _ContactTile(
//                   r: r,
//                   icon: Icons.call_rounded,
//                   label: 'Phone',
//                   onTap: onPhone,
//                 ),
//               ),
//               SizedBox(width: r.s(10)),
//               Expanded(
//                 child: _ContactTile(
//                   r: r,
//                   icon: Icons.location_on_rounded,
//                   label: 'Location',
//                   onTap: onLocation,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: r.s(20)),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _SocialIcon(r: r, icon: Icons.language_rounded, onTap: onWebsite),
//               SizedBox(width: r.s(12)),
//               _SocialIcon(r: r, icon: Icons.alternate_email_rounded, onTap: onEmail),
//               SizedBox(width: r.s(12)),
//               _SocialIcon(r: r, icon: Icons.share_rounded, onTap: () {}),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ContactTile extends StatelessWidget {
//   final _R r;
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _ContactTile({
//     required this.r,
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return _Tap(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(14)),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(r.s(_T.radiusSm)),
//           border: Border.all(color: Colors.white.withOpacity(0.10)),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: _T.goldLight, size: r.s(16)),
//             SizedBox(width: r.s(8)),
//             Expanded(
//               child: Text(
//                 label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.85),
//                   fontSize: r.f(12),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SocialIcon extends StatelessWidget {
//   final _R r;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _SocialIcon({required this.r, required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return _Tap(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(r.s(10)),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.06),
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white.withOpacity(0.10)),
//         ),
//         child: Icon(icon, color: Colors.white.withOpacity(0.8), size: r.s(16)),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // FADE + SLIDE-IN — subtle entrance animation wrapper for sections
// // ─────────────────────────────────────────────────────────────────────────────
// class _FadeSlideIn extends StatefulWidget {
//   final Widget child;
//   const _FadeSlideIn({required this.child});
//
//   @override
//   State<_FadeSlideIn> createState() => _FadeSlideInState();
// }
//
// class _FadeSlideInState extends State<_FadeSlideIn>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 420),
//   );
//   late final Animation<double> _fade =
//   CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
//   late final Animation<Offset> _slide = Tween(
//     begin: const Offset(0, 0.04),
//     end: Offset.zero,
//   ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl.forward();
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: SlideTransition(position: _slide, child: widget.child),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // UTILITY — scale-on-tap wrapper
// // ─────────────────────────────────────────────────────────────────────────────
// class _Tap extends StatefulWidget {
//   final Widget child;
//   final VoidCallback onTap;
//   const _Tap({required this.child, required this.onTap});
//
//   @override
//   State<_Tap> createState() => _TapState();
// }
// class _TapState extends State<_Tap> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 80),
//     reverseDuration: const Duration(milliseconds: 160),
//     lowerBound: 0.96,
//     upperBound: 1.0,
//     value: 1.0,
//   );
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTapDown:   (_) => _ctrl.reverse(),
//       onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
//       onTapCancel: () => _ctrl.forward(),
//       child: AnimatedBuilder(
//         animation: _ctrl,
//         builder: (_, child) =>
//             Transform.scale(scale: _ctrl.value, child: child),
//         child: widget.child,
//       ),
//     );
//   }
// }


// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loanready_app/presentation/screens/home/ebook_screen.dart';
import 'package:loanready_app/presentation/screens/home/one_year_trading_screen.dart';
import 'package:loanready_app/presentation/screens/reports/one_year_report_view_screen.dart';
import 'package:loanready_app/presentation/screens/reports/one_year_reports_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Model/user_model.dart';
import '../../../controllers/user_controller.dart';
import '../../../providers/user_provider.dart';
import '../auth/otp_login_screen.dart';
import '../chatbot/ai_service.dart';
import '../loan/loan_scheme.dart';
import '../register/profile_screen.dart';
import 'financial_statement_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static const Color navy          = Color(0xFF0B1628);
  static const Color navyDeep      = Color(0xFF060D1C);
  static const Color navyLight     = Color(0xFF162035);
  static const Color gold          = Color(0xFFC9A227);
  static const Color goldLight     = Color(0xFFE7C766);
  static const Color bg            = Color(0xFFF3F5F9);
  static const Color surface       = Colors.white;
  static const Color textPrimary   = Color(0xFF0B1628);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary  = Color(0xFF9AA1AE);
  static const Color border        = Color(0xFFE7E9F0);

  static const Map<String, List<Color>> cats = {
    'navy':   [Color(0xFF0B1628), Color(0xFFEAECF2)],
    'violet': [Color(0xFF5B50E8), Color(0xFFEEEDFD)],
    'green':  [Color(0xFF0A9464), Color(0xFFE4F6EF)],
    'amber':  [Color(0xFFD97706), Color(0xFFFEF3E2)],
    'rose':   [Color(0xFFE84F6E), Color(0xFFFDECF1)],
  };

  static const double sp8  = 8;
  static const double sp16 = 16;
  static const double sp24 = 24;
  static const double sp32 = 32;

  static const double radiusSm = 14;
  static const double radiusMd = 20;
  static const double radiusLg = 24;
  static const double radiusXl = 24;

  static List<BoxShadow> shadowSm(Color c) => [
    BoxShadow(color: c.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> shadowMd(Color c) => [
    BoxShadow(color: c.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 8)),
  ];
  static List<BoxShadow> shadowLg(Color c) => [
    BoxShadow(color: c.withOpacity(0.18), blurRadius: 32, offset: const Offset(0, 14)),
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
    subtitle: 'Keep identity proofs, salary slips, and bank statements ready before applying.',
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
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final ScrollController scrollController;

  const HomeScreen({super.key, required this.scrollController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤';
    if (h < 21) return 'Good Evening 🌙';
    return 'Good Night 🌛';
  }

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse("https://themsmcconsultants.com");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail() async {
    final Uri email = Uri.parse("mailto:info@themsmcconsultants.com");
    await launchUrl(email);
  }

  Future<void> _openPhone() async {
    final Uri phone = Uri.parse("tel:+918240928803");
    await launchUrl(phone);
  }

  Future<void> _openLocation() async {
    final Uri location = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=MSMC+Consultants",
    );
    await launchUrl(location, mode: LaunchMode.externalApplication);
  }

  late UserController controller;

  @override
  void initState() {
    super.initState();
    controller = UserController();
    Future.microtask(() {
      if (!mounted) return;
      controller.fetchCurrentUser(context.read<UserProvider>());
    });
  }

  Future<void> _openFinancialReports() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('is_guest') ?? false;

    if (isGuest) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Required', style: TextStyle(fontWeight: FontWeight.w700)),
            content: const Text('Please login to access Financial Reports.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _push(const OtpLoginScreen());
                },
                child: const Text('Login'),
              ),
            ],
          );
        },
      );
      return;
    }

    _push(const OneYearReportsScreen());
  }

  @override
  Widget build(BuildContext context) {
    final r = _R(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0B1628),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F9),

        body: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================

            Consumer<UserProvider>(
              builder: (_, provider, __) {
                return _Header(
                  r: r,
                  greeting: _greeting,
                  user: provider.user,
                  isLoading: provider.isLoading,
                );
              },
            ),

            // =====================================================
            // CONTENT
            // =====================================================

            Expanded(
              child: ListView(
                controller: widget.scrollController,

                physics: const BouncingScrollPhysics(),

                padding: EdgeInsets.only(
                  left: r.hPad,
                  right: r.hPad,
                  top: r.s(26),
                  bottom: r.s(32),
                ),

                children: [
                  // -------------------------------------------------
                  // SERVICES
                  // -------------------------------------------------

                  _SectionTitle(
                    r: r,
                    text: 'Services',
                  ),

                  SizedBox(height: r.s(16)),

                  _QuickActions(
                    r: r,
                    onTap: _handleQuickAction,
                  ),

                  SizedBox(height: r.s(30)),

                  // -------------------------------------------------
                  // MORE OPTIONS
                  // -------------------------------------------------

                  _SectionTitle(
                    r: r,
                    text: 'More Options',
                  ),

                  SizedBox(height: r.s(14)),

                  _MoreGrid(
                    r: r,
                    onTap: _handleGridTap,
                  ),

                  SizedBox(height: r.s(30)),

                  // -------------------------------------------------
                  // TIPS & NEWS
                  // -------------------------------------------------

                  _SectionTitle(
                    r: r,
                    text: 'Tips & News',
                  ),

                  SizedBox(height: r.s(14)),

                  _TipsNews(
                    r: r,
                  ),

                  SizedBox(height: r.s(10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) => Navigator.push(context, _slide(screen));

  void _handleQuickAction(String label) {
    switch (label) {
      case 'Loan':
        _push(const LoanSchemeFormScreen());
        break;
      case 'Bot':
        _push(const ChatbotScreen());
        break;
      case 'Financial':
        _push(const FinancialStatementScreen());
        break;
      case 'Projection':
        _push(const OneYearTradingScreen());
        break;
      case 'E-Book':
        _push(const EbookScreen());
        break;
      case 'Website':
        _openWebsite();
        break;
      case 'Email':
        _openEmail();
        break;
    }
  }

  void _handleGridTap(String title) {
    switch (title) {
      case 'Register':
        _push(const OtpLoginScreen());
        break;
      case 'About':
        Navigator.pushNamed(context, '/about');
        break;
      case 'Plans':
        Navigator.pushNamed(context, '/choosePlan');
        break;
      case 'Loan Scheme':
        _push(const LoanSchemeFormScreen());
        break;
      case 'Business Projections':
        _push(const OneYearTradingScreen());
        break;
      case 'Financial Generator':
        _openFinancialReports();
        break;
      case 'E-Book':
        _push(const EbookScreen());
        break;
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
  final UserModel? user;
  final bool isLoading;

  const _Header({
    required this.r,
    required this.greeting,
    this.user,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : 'Guest';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111D33),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(r.s(34)),
          bottomRight: Radius.circular(r.s(34)),
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x220B1628),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: r.topPad + r.s(18),
          bottom: r.s(28),
          left: r.hPad,
          right: r.hPad,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =====================================================
            // GREETING + NAME
            // =====================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.62),
                      fontSize: r.f(13),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),

                  SizedBox(height: r.s(5)),

                  if (isLoading)
                    Shimmer.fromColors(
                      baseColor: Colors.white.withOpacity(0.10),
                      highlightColor: Colors.white.withOpacity(0.22),
                      child: Container(
                        width: r.s(125),
                        height: r.s(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            r.s(6),
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: r.f(27),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        height: 1.05,
                      ),
                    ),
                ],
              ),
            ),

            // =====================================================
            // NOTIFICATION
            // =====================================================

            _HeaderIconBtn(
              icon: Icons.notifications_none_rounded,
              showDot: true,
              r: r,
            ),

            SizedBox(width: r.s(10)),

            // =====================================================
            // PROFILE
            // =====================================================

            _UserAvatar(
              user: user,
              r: r,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserModel? user;
  final _R r;
  final bool isLoading;

  const _UserAvatar({this.user, required this.r, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.2),
        child: Container(
          width: r.s(37),
          height: r.s(37),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
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
          backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
              ? NetworkImage(user!.photoUrl!)
              : null,
          child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
              ? Text(
            user?.initials ?? "?",
            style: TextStyle(
              color: Colors.white,
              fontSize: r.f(12),
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
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
    {'title': 'About',                'icon': Icons.info_rounded,              'cat': 'navy'},
    {'title': 'Plans',                'icon': Icons.workspace_premium_rounded, 'cat': 'amber'},
    {'title': 'Loan Scheme',          'icon': Icons.account_balance_rounded,   'cat': 'navy'},
    {'title': 'Business Projections', 'icon': Icons.bar_chart_rounded,         'cat': 'green'},
    {'title': 'Financial Generator',  'icon': Icons.description_rounded,       'cat': 'green'},
    {'title': 'E-Book',               'icon': Icons.menu_book_rounded,         'cat': 'amber'},
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
// TIPS & NEWS (FIXED & COMPLETED)
// ─────────────────────────────────────────────────────────────────────────────
class _TipsNews extends StatelessWidget {
  final _R r;
  const _TipsNews({required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _tips.map((tip) {
        final colors = _T.cats[tip.cat]!;
        final isLast = tip == _tips.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : r.s(_T.sp16)),
          child: _Tap(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(r.s(_T.sp16)),
              decoration: BoxDecoration(
                color: _T.surface,
                borderRadius: BorderRadius.circular(r.s(_T.radiusMd)),
                border: Border.all(color: _T.border, width: 0.8),
                boxShadow: _T.shadowSm(_T.navy),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: r.s(44),
                    height: r.s(44),
                    decoration: BoxDecoration(
                      color: colors[1],
                      borderRadius: BorderRadius.circular(r.s(12)),
                    ),
                    child: Icon(
                      tip.icon,
                      color: colors[0],
                      size: r.s(22),
                    ),
                  ),
                  SizedBox(width: r.s(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: r.s(8),
                                vertical: r.s(3),
                              ),
                              decoration: BoxDecoration(
                                color: colors[1],
                                borderRadius: BorderRadius.circular(r.s(6)),
                              ),
                              child: Text(
                                tip.tag,
                                style: TextStyle(
                                  color: colors[0],
                                  fontSize: r.f(10),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.s(6)),
                        Text(
                          tip.title,
                          style: TextStyle(
                            color: _T.textPrimary,
                            fontSize: r.f(14),
                            fontWeight: FontWeight.w700,
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
// HELPER COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final _R r;
  final String text;
  const _SectionTitle({required this.r, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: _T.textPrimary,
        fontSize: r.f(18),
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _Tap extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Tap({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}