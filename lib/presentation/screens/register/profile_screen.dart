import 'package:flutter/material.dart';
import 'package:loanready_app/core/constants/colors.dart';
import 'package:loanready_app/presentation/screens/register/document_edit_screen.dart';
import 'package:loanready_app/presentation/screens/register/edit_profile_screen.dart';
import 'package:loanready_app/providers/auth_provider.dart';
import 'package:loanready_app/providers/user_provider.dart';
import 'package:loanready_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../Model/user_profile_model.dart';
import '../../../routes/app_routes.dart';

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS (powered by AppColors)
// ═════════════════════════════════════════════════════════════════════════════
class _C {
  static Color bg(BuildContext c) =>
      _dark(c) ? AppColors.bgDark : AppColors.bgLight;

  static Color surface(BuildContext c) =>
      _dark(c) ? AppColors.surfaceDark : AppColors.surfaceLight;

  static Color text(BuildContext c) =>
      _dark(c) ? AppColors.textLight : AppColors.textDark;

  static Color sub(BuildContext c) =>
      _dark(c) ? AppColors.subTextDark : AppColors.subText;

  static Color border(BuildContext c) =>
      _dark(c) ? AppColors.borderDark : AppColors.borderLight;

  static Color iconBg(BuildContext c) =>
      _dark(c) ? AppColors.iconBgDark : AppColors.iconBgLight;

  static bool _dark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static const double rSm = 12;
  static const double rMd = 18;
  static const double rLg = 24;

  static List<BoxShadow> shadowSm(BuildContext c) => [
    BoxShadow(
      color: _dark(c)
          ? Colors.black.withOpacity(0.35)
          : AppColors.textDark.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
}

// ═════════════════════════════════════════════════════════════════════════════
// RESPONSIVE HELPER
// ═════════════════════════════════════════════════════════════════════════════
class _R {
  final double w, h, top, bottom;
  _R(BuildContext c)
      : w = MediaQuery.sizeOf(c).width,
        h = MediaQuery.sizeOf(c).height,
        top = MediaQuery.paddingOf(c).top,
        bottom = MediaQuery.paddingOf(c).bottom;

  double s(double v) => v * (w / 390).clamp(0.80, 1.30);
  double f(double v) => v * (w / 390).clamp(0.85, 1.15);
  double get hPad => s(20);
}

// ═════════════════════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<UserProvider>();

      // Parallel + cache respect karega
      Future.wait([
        provider.fetchProfile(),
        provider.fetchDocuments(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    final userProvider = context.watch<UserProvider>();

    final profile = userProvider.userProfile;

    // Only show full screen loader when there is
    // absolutely no profile data available.
    final showInitialLoader =
        profile == null && userProvider.isFetchingData;

    // Only show full error screen when profile is
    // completely unavailable.
    final showInitialError =
        profile == null &&
            !userProvider.isFetchingData &&
            userProvider.errorMessage != null;

    return Scaffold(
      backgroundColor: _C.bg(context),

      body: showInitialLoader
          ? _ShimmerView(r: r)

          : showInitialError
          ? _ErrorView(
        r: r,
        message: _getSafeErrorMessage(
          userProvider.errorMessage,
        ),
        onRetry: () {
          final provider =
          context.read<UserProvider>();

          provider.fetchProfile();
          provider.fetchDocuments();
        },
      )
          : _Body(
        r: r,
        profile: profile,
        isGuest: userProvider.isGuest,
        onLogout: () =>
            _showLogoutSheet(context, r),
      ),
    );
  }

  String _getSafeErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return 'Unable to load your profile.\nPlease try again.';
    }

    final value = error.toLowerCase();

    if (value.contains('socketexception') ||
        value.contains('no_internet') ||
        value.contains('failed host lookup') ||
        value.contains('network is unreachable')) {
      return 'No internet connection.\nPlease check your network.';
    }

    if (value.contains('clientexception') ||
        value.contains('connection aborted') ||
        value.contains('connection abort') ||
        value.contains('connection reset')) {
      return 'Unable to connect to server.\nPlease try again.';
    }

    if (value.contains('timeout') ||
        value.contains('request_timeout')) {
      return 'Server is taking too long to respond.\nPlease try again.';
    }

    if (value.contains('session_expired')) {
      return 'Your session has expired.\nPlease login again.';
    }

    return 'Unable to load your profile.\nPlease try again.';
  }
  void _showLogoutSheet(BuildContext context, _R r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LogoutSheet(
        r: r,
        onConfirm: () async {
          Navigator.pop(context);
          await context.read<AuthProvider>().logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.otpLogin,
                  (route) => false,
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final _R r;
  final UserProfileModel? profile;
  final bool isGuest;
  final VoidCallback onLogout;

  const _Body({
    required this.r,
    required this.profile,
    required this.isGuest,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _Header(r: r, profile: profile)),
        SliverPadding(
          padding:
          EdgeInsets.fromLTRB(r.hPad, r.s(24), r.hPad, r.bottom + r.s(32)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (profile != null && !profile!.isKycComplete && !isGuest) ...[
                _KycBanner(r: r),
                SizedBox(height: r.s(24)),
              ],
              _SectionLabel(r: r, text: 'Personal Information'),
              SizedBox(height: r.s(10)),
              _InfoCard(r: r, rows: [
                _Row(Icons.person_rounded, 'Full Name',
                    profile?.displayName ?? '—'),
                _Row(Icons.phone_rounded, 'Phone',
                    profile?.formattedMobile ?? '—'),
                _Row(Icons.email_rounded, 'Email',
                    profile?.displayEmail ?? '—'),
                _Row(Icons.cake_rounded, 'Date of Birth',
                    profile?.formattedDob ?? '—'),
                _Row(
                  Icons.home_rounded,
                  'Address',
                  profile?.displayAddress ?? '—',
                  isLast: true,
                ),
              ]),
              SizedBox(height: r.s(24)),
              _SectionLabel(r: r, text: 'KYC / Documents'),
              SizedBox(height: r.s(10)),
              _KycCard(r: r, profile: profile),
              SizedBox(height: r.s(24)),
              _SectionLabel(r: r, text: 'Settings & Preferences'),
              SizedBox(height: r.s(10)),
              _SettingsCard(r: r, theme: theme),
              SizedBox(height: r.s(24)),
              _QuickLinksCard(r: r),
              SizedBox(height: r.s(28)),
              _LogoutBtn(r: r, onTap: onLogout),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final _R r;
  final UserProfileModel? profile;
  final VoidCallback? onRefresh;

  const _Header({
    required this.r,
    required this.profile,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.30)
                : const Color(0x0D0B1628),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: r.top + r.s(6),
              left: r.hPad,
              right: r.hPad,
              bottom: r.s(8),
            ),
            child: Row(
              children: [
                _Tap(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    padding: EdgeInsets.all(r.s(8)),
                    decoration: BoxDecoration(
                      color: _C.iconBg(context),
                      shape: BoxShape.circle,
                    ),
                    // child: Icon(
                    //   Icons.arrow_back_ios_new_rounded,
                    //   size: r.s(18),
                    //   color: _C.text(context),
                    // ),
                  ),
                ),
                const Spacer(),
                Text(
                  'My Profile',
                  style: TextStyle(
                    color: _C.text(context),
                    fontSize: r.f(17),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                _Tap(
                  onTap: () async {
                    if (profile != null) {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfileScreen(profile: profile!),
                        ),
                      );

                      if (updated == true && context.mounted) {
                        await context.read<UserProvider>().fetchProfile();
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(r.s(8)),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: r.s(18),
                      color: AppColors.gold,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: r.s(12)),
          _Avatar(r: r, profile: profile),
          SizedBox(height: r.s(14)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.hPad),
            child: Text(
              profile?.displayName ?? '—',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _C.text(context),
                fontSize: r.f(20),
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          SizedBox(height: r.s(4)),
          Text(
            profile?.formattedMobile ?? '',
            style: TextStyle(
              color: _C.sub(context),
              fontSize: r.f(13),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: r.s(18)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.hPad),
            child: Row(
              children: [
                _StatChip(
                  r: r,
                  label: 'Credit Score',
                  value: profile?.creditScore?.toString() ?? 'N/A',
                  color: AppColors.success,
                  bg: AppColors.successBg,
                ),
                SizedBox(width: r.s(10)),
                _StatChip(
                  r: r,
                  label: 'Active Loans',
                  value: (profile?.activeLoans ?? 0).toString(),
                  color: AppColors.gold,
                  bg: AppColors.warningBg,
                ),
                SizedBox(width: r.s(10)),
                _StatChip(
                  r: r,
                  label: 'Member Since',
                  value: profile?.memberSince ?? '—',
                  color: AppColors.textDark,
                  bg: const Color(0xFFE8EAF0),
                ),
              ],
            ),
          ),
          SizedBox(height: r.s(20)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final _R r;
  final UserProfileModel? profile;
  const _Avatar({required this.r, required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: r.s(96),
          height: r.s(96),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.goldLight, AppColors.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        ClipOval(
          child: SizedBox(
            width: r.s(88),
            height: r.s(88),
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl: profile!.photoUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  _InitialsCircle(r: r, initials: profile!.initials),
              errorWidget: (_, __, ___) =>
                  _InitialsCircle(r: r, initials: profile!.initials),
            )
                : _InitialsCircle(
              r: r,
              initials: profile?.initials ?? '?',
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: r.s(0),
          child: Container(
            padding: EdgeInsets.all(r.s(4)),
            decoration: BoxDecoration(
              color: _C.surface(context),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: EdgeInsets.all(r.s(3)),
              decoration: BoxDecoration(
                color: profile?.isKycComplete == true
                    ? AppColors.success
                    : AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: Icon(
                profile?.isKycComplete == true
                    ? Icons.check_rounded
                    : Icons.access_time_rounded,
                color: Colors.white,
                size: r.s(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  final _R r;
  final String initials;
  const _InitialsCircle({required this.r, required this.initials});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF162035), Color(0xFF0B1628)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: r.f(30),
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// KYC BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _KycBanner extends StatelessWidget {
  final _R r;
  const _KycBanner({required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(14)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF9EC), Color(0xFFFDF5D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(r.s(_C.rMd)),
        border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.s(9)),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(r.s(10)),
            ),
            child: Icon(Icons.shield_rounded,
                color: AppColors.gold, size: r.s(20)),
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Pending',
                  style: TextStyle(
                    color: _C.text(context),
                    fontWeight: FontWeight.w700,
                    fontSize: r.f(13),
                  ),
                ),
                SizedBox(height: r.s(2)),
                Text(
                  'Complete KYC to unlock full loan limit',
                  style: TextStyle(
                    color: _C.sub(context),
                    fontSize: r.f(11.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: r.s(8)),
          _Tap(
            onTap: () {},
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(8)),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(r.s(40)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: r.f(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _Row {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _Row(this.icon, this.label, this.value, {this.isLast = false});
}

class _InfoCard extends StatelessWidget {
  final _R r;
  final List<_Row> rows;
  const _InfoCard({required this.r, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.circular(r.s(_C.rLg)),
        border: Border.all(color: _C.border(context), width: 0.8),
        boxShadow: _C.shadowSm(context),
      ),
      child: Column(
        children: rows
            .map((row) => Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: r.s(18), vertical: r.s(14)),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.s(9)),
                    decoration: BoxDecoration(
                      color: _C.iconBg(context),
                      borderRadius: BorderRadius.circular(r.s(10)),
                    ),
                    child: Icon(row.icon,
                        color: _C.text(context), size: r.s(18)),
                  ),
                  SizedBox(width: r.s(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: TextStyle(
                            color: _C.sub(context),
                            fontSize: r.f(11),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: r.s(3)),
                        Text(
                          row.value,
                          style: TextStyle(
                            color: _C.text(context),
                            fontSize: r.f(14),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: _C.sub(context), size: r.s(18)),
                ],
              ),
            ),
            if (!row.isLast)
              Divider(
                height: 1,
                thickness: 0.8,
                color: _C.border(context),
                indent: r.s(54),
                endIndent: r.s(18),
              ),
          ],
        ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KYC DOCUMENTS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _KycCard extends StatelessWidget {
  final _R r;
  final UserProfileModel? profile;

  const _KycCard({
    required this.r,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    final docs = [
      {
        'label': 'Aadhaar Card',
        'uploaded': userProvider.isAadhaarUploaded,
        'icon': Icons.credit_card_rounded,
      },
      {
        'label': 'PAN Card',
        'uploaded': userProvider.isPanUploaded,
        'icon': Icons.badge_rounded,
      },
      {
        'label': 'Shop License',
        'uploaded': userProvider.isShopLicenseUploaded,
        'icon': Icons.store_rounded,
      },
      {
        'label': 'GST Certificate',
        'uploaded': userProvider.isGstUploaded,
        'icon': Icons.receipt_long_rounded,
      },
      {
        'label': 'Business Proof',
        'uploaded': userProvider.isBusinessProofUploaded,
        'icon': Icons.business_center_rounded,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.circular(r.s(_C.rLg)),
        border: Border.all(
          color: _C.border(context),
          width: 0.8,
        ),
        boxShadow: _C.shadowSm(context),
      ),
      child: Column(
        children: docs.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;

          final bool uploaded =
              doc['uploaded'] as bool? ?? false;

          final bool isLast =
              index == docs.length - 1;

          final String documentType =
          doc['label'] as String;

          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.vertical(
                  top: index == 0
                      ? Radius.circular(r.s(_C.rLg))
                      : Radius.zero,
                  bottom: isLast
                      ? Radius.circular(r.s(_C.rLg))
                      : Radius.zero,
                ),
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentEditScreen(
                        documentType: documentType,
                      ),
                    ),
                  );

                  if (updated == true && context.mounted) {
                    await context
                        .read<UserProvider>()
                        .fetchDocuments();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.s(18),
                    vertical: r.s(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(r.s(9)),
                        decoration: BoxDecoration(
                          color: _C.iconBg(context),
                          borderRadius:
                          BorderRadius.circular(r.s(10)),
                        ),
                        child: Icon(
                          doc['icon'] as IconData,
                          color: _C.text(context),
                          size: r.s(18),
                        ),
                      ),

                      SizedBox(width: r.s(14)),

                      Expanded(
                        child: Text(
                          documentType,
                          style: TextStyle(
                            color: _C.text(context),
                            fontSize: r.f(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.s(10),
                          vertical: r.s(5),
                        ),
                        decoration: BoxDecoration(
                          color: uploaded
                              ? AppColors.successBg
                              : AppColors.dangerBg,
                          borderRadius:
                          BorderRadius.circular(r.s(20)),
                        ),
                        child: Text(
                          uploaded ? 'Uploaded' : 'Missing',
                          style: TextStyle(
                            color: uploaded
                                ? AppColors.success
                                : AppColors.danger,
                            fontSize: r.f(11),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(width: r.s(6)),

                      Icon(
                        Icons.chevron_right_rounded,
                        color: _C.sub(context),
                        size: r.s(18),
                      ),
                    ],
                  ),
                ),
              ),

              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: _C.border(context),
                  indent: r.s(54),
                  endIndent: r.s(18),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final _R r;
  final ThemeProvider theme;
  const _SettingsCard({required this.r, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.circular(r.s(_C.rLg)),
        border: Border.all(color: _C.border(context), width: 0.8),
        boxShadow: _C.shadowSm(context),
      ),
      child: Column(
        children: [
          Padding(
            padding:
            EdgeInsets.symmetric(horizontal: r.s(18), vertical: r.s(10)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.s(9)),
                  decoration: BoxDecoration(
                    color: _C.iconBg(context),
                    borderRadius: BorderRadius.circular(r.s(10)),
                  ),
                  child: Icon(
                    theme.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: _C.text(context),
                    size: r.s(18),
                  ),
                ),
                SizedBox(width: r.s(14)),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: _C.text(context),
                      fontSize: r.f(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: theme.isDark,
                  activeColor: AppColors.gold,
                  onChanged: (v) => theme.toggle(v),
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
// QUICK LINKS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _QuickLinksCard extends StatelessWidget {
  final _R r;
  const _QuickLinksCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final links = [
      {'title': 'Help & Support', 'icon': Icons.support_agent_rounded},
      {'title': 'Terms & Conditions', 'icon': Icons.description_rounded},
      {'title': 'Privacy Policy', 'icon': Icons.privacy_tip_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.circular(r.s(_C.rLg)),
        border: Border.all(color: _C.border(context), width: 0.8),
        boxShadow: _C.shadowSm(context),
      ),
      child: Column(
        children: links.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          final isLast = idx == links.length - 1;

          return Column(
            children: [
              _Tap(
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: r.s(18), vertical: r.s(14)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(r.s(9)),
                        decoration: BoxDecoration(
                          color: _C.iconBg(context),
                          borderRadius: BorderRadius.circular(r.s(10)),
                        ),
                        child: Icon(item['icon'] as IconData,
                            color: _C.text(context), size: r.s(18)),
                      ),
                      SizedBox(width: r.s(14)),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: _C.text(context),
                            fontSize: r.f(14),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: _C.sub(context), size: r.s(18)),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: _C.border(context),
                  indent: r.s(54),
                  endIndent: r.s(18),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT BUTTON & SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutBtn extends StatelessWidget {
  final _R r;
  final VoidCallback onTap;
  const _LogoutBtn({required this.r, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Tap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: r.s(14)),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(r.s(_C.rMd)),
          border: Border.all(color: AppColors.danger.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.danger, size: r.s(18)),
            SizedBox(width: r.s(8)),
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: r.f(15),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutSheet extends StatelessWidget {
  final _R r;
  final VoidCallback onConfirm;
  const _LogoutSheet({required this.r, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      EdgeInsets.fromLTRB(r.hPad, r.s(20), r.hPad, r.bottom + r.s(20)),
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.s(_C.rLg))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r.s(40),
            height: r.s(4),
            decoration: BoxDecoration(
              color: _C.sub(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: r.s(20)),
          Text(
            'Confirm Logout',
            style: TextStyle(
              color: _C.text(context),
              fontSize: r.f(18),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: r.s(8)),
          Text(
            'Are you sure you want to log out of your account?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _C.sub(context),
              fontSize: r.f(13),
            ),
          ),
          SizedBox(height: r.s(24)),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: _C.sub(context))),
                ),
              ),
              SizedBox(width: r.s(12)),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.s(_C.rSm)),
                    ),
                  ),
                  onPressed: onConfirm,
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTILITY & STATE VIEWS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final _R r;
  final String text;
  const _SectionLabel({required this.r, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: _C.text(context),
        fontSize: r.f(14),
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final _R r;
  final String label, value;
  final Color color, bg;
  const _StatChip({
    required this.r,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.s(10)),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(r.s(_C.rSm)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: r.f(14),
              ),
            ),
            SizedBox(height: r.s(2)),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
                fontSize: r.f(10),
              ),
            ),
          ],
        ),
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

class _ShimmerView extends StatelessWidget {
  final _R r;
  const _ShimmerView({required this.r});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(r.hPad),
        child: Column(
          children: [
            SizedBox(height: r.top + 40),
            CircleAvatar(radius: r.s(44)),
            SizedBox(height: r.s(20)),
            Container(width: 150, height: 20, color: Colors.white),
            SizedBox(height: r.s(30)),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.s(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final _R r;
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({
    required this.r,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.hPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: r.s(48)),
            SizedBox(height: r.s(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: _C.text(context)),
            ),
            SizedBox(height: r.s(16)),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}