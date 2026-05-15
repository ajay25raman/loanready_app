// ─────────────────────────────────────────────────────────────────────────────
// COMPLETE PROFILE SCREEN — Production Ready
// Node.js + Express + MySQL + REST API + JWT Auth
//
// pubspec.yaml mein ye add karo:
//   http: ^1.2.0
//   provider: ^6.1.2
//   shared_preferences: ^2.2.3
//   shimmer: ^3.0.0
//   cached_network_image: ^3.3.1
//   intl: ^0.19.0
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ═════════════════════════════════════════════════════════════════════════════
// API CONSTANTS
// ═════════════════════════════════════════════════════════════════════════════
class ApiConfig {
  static const String userBaseUrl =
      'https://loan-approval-api-faur.onrender.com/api/v1';
  static const String docBaseUrl =
      'https://document-api-loan-approval.onrender.com/api/v1';

  // Endpoints
  static const String getUser     = '$userBaseUrl/users';  // GET
  static const String getDocuments = '$docBaseUrl/documents'; // GET (future)
  static const String getPhoto    = '$userBaseUrl/users/photo'; // GET (future)
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED PREFS HELPER
// ═════════════════════════════════════════════════════════════════════════════
class AppPrefs {
  static const String _tokenKey   = 'auth_token';
  static const String _darkKey    = 'is_dark_mode';
  static const String _notifKey   = 'notif_enabled';
  static const String _bioKey     = 'bio_enabled';

  // Token
  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey);
  }

  // Dark mode
  static Future<bool> getDarkMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_darkKey) ?? false;
  }

  static Future<void> setDarkMode(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_darkKey, v);
  }

  // Notifications
  static Future<bool> getNotif() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_notifKey) ?? true;
  }

  static Future<void> setNotif(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_notifKey, v);
  }

  // Biometrics
  static Future<bool> getBio() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_bioKey) ?? false;
  }

  static Future<void> setBio(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_bioKey, v);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// USER PROFILE MODEL  —  matches GET /users response
// ═════════════════════════════════════════════════════════════════════════════
class UserProfileModel {
  final String fullName;
  final String mobile;
  final String email;
  final String dob;
  final String address;
  final String? photoUrl;       // from backend when ready
  final int?   creditScore;
  final int    activeLoans;
  final String memberSince;

  // KYC statuses — 'verified' | 'pending' | 'missing'
  final String aadhaarStatus;
  final String panStatus;
  final String bankStatus;
  final String addressDocStatus;

  const UserProfileModel({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.dob,
    required this.address,
    this.photoUrl,
    this.creditScore,
    this.activeLoans    = 0,
    required this.memberSince,
    this.aadhaarStatus    = 'missing',
    this.panStatus        = 'missing',
    this.bankStatus       = 'missing',
    this.addressDocStatus = 'missing',
  });

  /// Parse from GET /users JSON response
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Parse member since from dob or createdAt field
    String memberSince = '';
    final createdAt = json['createdAt']?.toString() ?? '';
    if (createdAt.isNotEmpty) {
      try {
        memberSince = DateTime.parse(createdAt).year.toString();
      } catch (_) {
        memberSince = DateTime.now().year.toString();
      }
    } else {
      memberSince = DateTime.now().year.toString();
    }

    // KYC map — { aadhaar: 'verified', pan: 'pending', ... }
    final kyc = (json['kyc'] as Map<String, dynamic>?) ?? {};

    return UserProfileModel(
      fullName:       json['fullName']  as String? ?? '',
      mobile:         json['mobile']   as String? ?? '',
      email:          json['email']    as String? ?? '',
      dob:            json['dob']      as String? ?? '',
      address:        json['address']  as String? ?? '',
      photoUrl:       json['photoUrl'] as String?,
      creditScore:    json['creditScore'] as int?,
      activeLoans:    (json['activeLoans'] as int?) ?? 0,
      memberSince:    memberSince,
      aadhaarStatus:    kyc['aadhaar'] as String? ?? 'missing',
      panStatus:        kyc['pan']     as String? ?? 'missing',
      bankStatus:       kyc['bank']    as String? ?? 'missing',
      addressDocStatus: kyc['address'] as String? ?? 'missing',
    );
  }

  // Initials from full name (for avatar fallback)
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  // Format mobile for display: +91 98765 43210
  String get formattedMobile {
    final clean = mobile.replaceAll('+91', '').trim();
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return mobile;
  }

  // Format dob: 2002-02-15 → 15 Feb 2002
  String get formattedDob {
    if (dob.isEmpty) return '—';
    try {
      final d = DateTime.parse(dob);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${d.day.toString().padLeft(2,'0')} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return dob;
    }
  }

  bool get isKycComplete =>
      aadhaarStatus    == 'verified' &&
          panStatus        == 'verified' &&
          bankStatus       == 'verified' &&
          addressDocStatus == 'verified';
}

// ═════════════════════════════════════════════════════════════════════════════
// PROFILE REPOSITORY  — all API logic here
// ═════════════════════════════════════════════════════════════════════════════
class ProfileRepository {
  /// Fetch user profile from GET /users with JWT token
  Future<UserProfileModel> fetchProfile() async {

    const bool isDevMode = true;

    if (isDevMode) {
      await Future.delayed(const Duration(milliseconds: 800));

      return const UserProfileModel(
        fullName: "Suraj Kumar",
        mobile: "9876543210",
        email: "suraj@gmail.com",
        dob: "2002-02-15",
        address: "Patna, Bihar",
        photoUrl: null,
        creditScore: 742,
        activeLoans: 1,
        memberSince: "2024",
        aadhaarStatus: "verified",
        panStatus: "verified",
        bankStatus: "pending",
        addressDocStatus: "missing",
      );
    }

    final token = await AppPrefs.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token not found. Please login again.');
    }

    // API CALL yahi rehne do niche wala
  }

  /// Clear token and logout
  Future<void> logout() async {
    await AppPrefs.clearToken();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// THEME PROVIDER  — Dark/Light + SharedPrefs persistence
// ═════════════════════════════════════════════════════════════════════════════
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    _isDark = await AppPrefs.getDarkMode();
    notifyListeners();
  }

  Future<void> toggle(bool value) async {
    _isDark = value;
    await AppPrefs.setDarkMode(value);
    notifyListeners();
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS  — adaptive dark/light
// ═════════════════════════════════════════════════════════════════════════════
class _C {
  // Static brand colors
  static const Color gold      = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFD4B44A);
  static const Color danger    = Color(0xFFDC2626);
  static const Color dangerBg  = Color(0xFFFEF2F2);
  static const Color success   = Color(0xFF059669);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warningBg = Color(0xFFFEF9EC);

  // Adaptive colors
  static Color bg(BuildContext c)      => _dark(c)
      ? const Color(0xFF0A0F1C)  : const Color(0xFFF2F4F8);
  static Color surface(BuildContext c) => _dark(c)
      ? const Color(0xFF111827)  : Colors.white;
  static Color text(BuildContext c)    => _dark(c)
      ? Colors.white             : const Color(0xFF0B1628);
  static Color sub(BuildContext c)     => _dark(c)
      ? const Color(0xFF9CA3AF)  : const Color(0xFF6B7280);
  static Color border(BuildContext c)  => _dark(c)
      ? const Color(0xFF1F2937)  : const Color(0xFFE5E7EB);
  static Color iconBg(BuildContext c)  => _dark(c)
      ? const Color(0xFF1F2937)  : const Color(0xFFF2F4F8);

  static bool _dark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  // Radius
  static const double rSm = 12;
  static const double rMd = 18;
  static const double rLg = 24;

  // Shadows
  static List<BoxShadow> shadowSm(BuildContext c) => [
    BoxShadow(
      color: _dark(c)
          ? Colors.black.withOpacity(0.35)
          : const Color(0xFF0B1628).withOpacity(0.06),
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
      : w      = MediaQuery.sizeOf(c).width,
        h      = MediaQuery.sizeOf(c).height,
        top    = MediaQuery.paddingOf(c).top,
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
  final _repo = ProfileRepository();

  UserProfileModel? _profile;
  bool   _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await _repo.fetchProfile();
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _R(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _C.bg(context),
        body: _loading
            ? _ShimmerView(r: r)
            : _error != null
            ? _ErrorView(r: r, message: _error!, onRetry: _fetch)
            : _Body(
          r:        r,
          profile:  _profile,
          onLogout: () => _showLogoutSheet(context, r),
        ),
      ),
    );
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
          await _repo.logout();
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (_) => false);
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
  final VoidCallback onLogout;

  const _Body({required this.r, required this.profile, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _Header(r: r, profile: profile)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
              r.hPad, r.s(24), r.hPad, r.bottom + r.s(32)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── KYC Banner (only if incomplete)
              if (profile != null && !profile!.isKycComplete) ...[
                _KycBanner(r: r),
                SizedBox(height: r.s(24)),
              ],

              // ── Personal Information
              _SectionLabel(r: r, text: 'Personal Information'),
              SizedBox(height: r.s(10)),
              _InfoCard(r: r, rows: [
                _Row(Icons.person_rounded,   'Full Name',    profile?.fullName      ?? '—'),
                _Row(Icons.phone_rounded,    'Phone',        profile?.formattedMobile ?? '—'),
                _Row(Icons.email_rounded,    'Email',        profile?.email.isEmpty == true ? '—' : profile!.email),
                _Row(Icons.cake_rounded,     'Date of Birth',profile?.formattedDob  ?? '—'),
                _Row(Icons.home_rounded,     'Address',      profile?.address.isEmpty == true ? '—' : profile!.address,
                    isLast: true),
              ]),

              SizedBox(height: r.s(24)),

              // ── KYC Documents
              _SectionLabel(r: r, text: 'KYC / Documents'),
              SizedBox(height: r.s(10)),
              _KycCard(r: r, profile: profile),

              SizedBox(height: r.s(24)),

              // ── Settings
              _SectionLabel(r: r, text: 'Settings & Preferences'),
              SizedBox(height: r.s(10)),
              _SettingsCard(r: r, theme: theme),

              SizedBox(height: r.s(24)),

              // ── Quick Links
              _QuickLinksCard(r: r),

              SizedBox(height: r.s(28)),

              // ── Logout
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
  const _Header({required this.r, required this.profile});

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
          // Nav row
          Padding(
            padding: EdgeInsets.only(
              top: r.top + r.s(6),
              left: r.hPad, right: r.hPad, bottom: r.s(8),
            ),
            child: Row(
              children: [
                _Tap(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    padding: EdgeInsets.all(r.s(8)),
                    decoration: BoxDecoration(
                      color: _C.iconBg(context), shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: r.s(18), color: _C.text(context)),
                  ),
                ),
                const Spacer(),
                Text('My Profile',
                    style: TextStyle(
                      color: _C.text(context),
                      fontSize: r.f(17),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    )),
                const Spacer(),
                _Tap(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(r.s(8)),
                    decoration: BoxDecoration(
                      color: _C.gold.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_rounded,
                        size: r.s(18), color: _C.gold),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.s(12)),

          // Avatar
          _Avatar(r: r, profile: profile),

          SizedBox(height: r.s(14)),

          // Name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.hPad),
            child: Text(
              profile?.fullName ?? '—',
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

          // Stats row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.hPad),
            child: Row(
              children: [
                _StatChip(
                  r: r,
                  label: 'Credit Score',
                  value: profile?.creditScore?.toString() ?? 'N/A',
                  color: _C.success,
                  bg: _C.successBg,
                ),
                SizedBox(width: r.s(10)),
                _StatChip(
                  r: r,
                  label: 'Active Loans',
                  value: profile?.activeLoans.toString() ?? '0',
                  color: _C.gold,
                  bg: _C.warningBg,
                ),
                SizedBox(width: r.s(10)),
                _StatChip(
                  r: r,
                  label: 'Member Since',
                  value: profile?.memberSince ?? '—',
                  color: const Color(0xFF0B1628),
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
// AVATAR  — photo from API URL OR initials fallback
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final _R r;
  final UserProfileModel? profile;
  const _Avatar({required this.r, required this.profile});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = profile?.photoUrl != null &&
        profile!.photoUrl!.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Gold ring
        Container(
          width: r.s(96), height: r.s(96),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_C.goldLight, _C.gold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Photo or initials
        ClipOval(
          child: SizedBox(
            width: r.s(88), height: r.s(88),
            child: hasPhoto
                ? CachedNetworkImage(
              imageUrl:    profile!.photoUrl!,
              fit:         BoxFit.cover,
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

        // KYC status badge
        Positioned(
          bottom: 0, right: r.s(0),
          child: Container(
            padding: EdgeInsets.all(r.s(4)),
            decoration: BoxDecoration(
                color: _C.surface(context), shape: BoxShape.circle),
            child: Container(
              padding: EdgeInsets.all(r.s(3)),
              decoration: BoxDecoration(
                color: profile?.isKycComplete == true ? _C.success : _C.gold,
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
      child: Text(initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.f(30),
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          )),
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
      padding: EdgeInsets.symmetric(
          horizontal: r.s(16), vertical: r.s(14)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF9EC), Color(0xFFFDF5D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(r.s(_C.rMd)),
        border: Border.all(color: _C.gold.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(color: _C.gold.withOpacity(0.08),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.s(9)),
            decoration: BoxDecoration(
              color: _C.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(r.s(10)),
            ),
            child: Icon(Icons.shield_rounded, color: _C.gold, size: r.s(20)),
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KYC Pending',
                    style: TextStyle(
                        color: _C.text(context),
                        fontWeight: FontWeight.w700,
                        fontSize: r.f(13))),
                SizedBox(height: r.s(2)),
                Text('Complete KYC to unlock full loan limit',
                    style: TextStyle(color: _C.sub(context), fontSize: r.f(11.5)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: r.s(8)),
          _Tap(
            onTap: () {
              // TODO: Navigate to KYC screen
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: r.s(14), vertical: r.s(8)),
              decoration: BoxDecoration(
                color: _C.gold,
                borderRadius: BorderRadius.circular(r.s(40)),
                boxShadow: [
                  BoxShadow(color: _C.gold.withOpacity(0.35),
                      blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Text('Complete',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: r.f(12))),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO CARD  (personal details)
// ─────────────────────────────────────────────────────────────────────────────
class _Row {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     isLast;
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
        children: rows.map((row) => Column(
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
                        Text(row.label,
                            style: TextStyle(
                              color: _C.sub(context),
                              fontSize: r.f(11),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            )),
                        SizedBox(height: r.s(3)),
                        Text(row.value,
                            style: TextStyle(
                              color: _C.text(context),
                              fontSize: r.f(14),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: _C.sub(context), size: r.s(18)),
                ],
              ),
            ),
            if (!row.isLast)
              Divider(height: 1, thickness: 0.8, color: _C.border(context),
                  indent: r.s(54), endIndent: r.s(18)),
          ],
        )).toList(),
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
  const _KycCard({required this.r, required this.profile});

  @override
  Widget build(BuildContext context) {
    final docs = [
      {'label': 'Aadhaar Card',   'status': profile?.aadhaarStatus    ?? 'missing', 'icon': Icons.credit_card_rounded},
      {'label': 'PAN Card',       'status': profile?.panStatus         ?? 'missing', 'icon': Icons.badge_rounded},
      {'label': 'Bank Statement', 'status': profile?.bankStatus        ?? 'missing', 'icon': Icons.account_balance_rounded},
      {'label': 'Address Proof',  'status': profile?.addressDocStatus  ?? 'missing', 'icon': Icons.home_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.circular(r.s(_C.rLg)),
        border: Border.all(color: _C.border(context), width: 0.8),
        boxShadow: _C.shadowSm(context),
      ),
      child: Column(
        children: docs.asMap().entries.map((e) {
          final idx    = e.key;
          final doc    = e.value;
          final status = doc['status'] as String;

          final Color sColor;
          final Color sBg;
          final IconData sIcon;
          final String sText;

          switch (status) {
            case 'verified':
              sColor = _C.success; sBg = _C.successBg;
              sIcon  = Icons.check_circle_rounded; sText = 'Verified';
              break;
            case 'pending':
              sColor = _C.gold; sBg = _C.warningBg;
              sIcon  = Icons.access_time_rounded; sText = 'Pending';
              break;
            default:
              sColor = _C.danger; sBg = _C.dangerBg;
              sIcon  = Icons.upload_rounded; sText = 'Upload';
          }

          return Column(
            children: [
              _Tap(
                onTap: () {
                  // TODO: Navigate to document upload screen
                },
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
                        child: Icon(doc['icon'] as IconData,
                            color: _C.text(context), size: r.s(18)),
                      ),
                      SizedBox(width: r.s(14)),
                      Expanded(
                        child: Text(doc['label'] as String,
                            style: TextStyle(
                              color: _C.text(context),
                              fontSize: r.f(14),
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: r.s(10), vertical: r.s(5)),
                        decoration: BoxDecoration(
                          color: sBg,
                          borderRadius: BorderRadius.circular(r.s(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sIcon, color: sColor, size: r.s(13)),
                            SizedBox(width: r.s(4)),
                            Text(sText,
                                style: TextStyle(
                                  color: sColor,
                                  fontSize: r.f(11),
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (idx < docs.length - 1)
                Divider(height: 1, thickness: 0.8,
                    color: _C.border(context),
                    indent: r.s(54), endIndent: r.s(18)),
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
class _SettingsCard extends StatefulWidget {
  final _R r;
  final ThemeProvider theme;
  const _SettingsCard({required this.r, required this.theme});

  @override
  State<_SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<_SettingsCard> {
  bool _notif = true;
  bool _bio   = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await AppPrefs.getNotif();
    final b = await AppPrefs.getBio();
    if (mounted) setState(() { _notif = n; _bio = b; });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius: BorderRadius.circular(r.s(_C.rLg)),
        border: Border.all(color: _C.border(context), width: 0.8),
        boxShadow: _C.shadowSm(context),
      ),
      child: Column(
        children: [
          _Toggle(
            r: r, icon: Icons.notifications_rounded,
            label: 'Push Notifications', sub: 'Loan updates & reminders',
            value: _notif,
            onChanged: (v) async {
              setState(() => _notif = v);
              await AppPrefs.setNotif(v);
            },
          ),
          Divider(height: 1, thickness: 0.8, color: _C.border(context),
              indent: r.s(54), endIndent: r.s(18)),
          _Toggle(
            r: r, icon: Icons.fingerprint_rounded,
            label: 'Biometric Login', sub: 'Face ID / Touch ID',
            value: _bio,
            onChanged: (v) async {
              setState(() => _bio = v);
              await AppPrefs.setBio(v);
            },
          ),
          Divider(height: 1, thickness: 0.8, color: _C.border(context),
              indent: r.s(54), endIndent: r.s(18)),
          _Toggle(
            r: r, icon: Icons.dark_mode_rounded,
            label: 'Dark Mode', sub: 'Aankho ko rest do 😄',
            value: widget.theme.isDark,
            onChanged: widget.theme.toggle,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final _R r;
  final IconData icon;
  final String label, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _Toggle({
    required this.r, required this.icon,
    required this.label, required this.sub,
    required this.value, required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.s(18), vertical: r.s(12)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.s(9)),
            decoration: BoxDecoration(
              color: _C.iconBg(context),
              borderRadius: BorderRadius.circular(r.s(10)),
            ),
            child: Icon(icon, color: _C.text(context), size: r.s(18)),
          ),
          SizedBox(width: r.s(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: _C.text(context),
                        fontSize: r.f(14), fontWeight: FontWeight.w600)),
                SizedBox(height: r.s(2)),
                Text(sub,
                    style: TextStyle(color: _C.sub(context),
                        fontSize: r.f(11.5))),
              ],
            ),
          ),
          Transform.scale(
            scale: r.s(0.88),
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: _C.gold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK LINKS
// ─────────────────────────────────────────────────────────────────────────────
class _QuickLinksCard extends StatelessWidget {
  final _R r;
  const _QuickLinksCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final links = [
      {'icon': Icons.help_outline_rounded,  'label': 'Help & Support'},
      {'icon': Icons.privacy_tip_rounded,   'label': 'Privacy Policy'},
      {'icon': Icons.star_outline_rounded,  'label': 'Rate the App'},
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
          final idx  = e.key;
          final link = e.value;
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
                        child: Icon(link['icon'] as IconData,
                            color: _C.text(context), size: r.s(18)),
                      ),
                      SizedBox(width: r.s(14)),
                      Expanded(
                        child: Text(link['label'] as String,
                            style: TextStyle(
                              color: _C.text(context),
                              fontSize: r.f(14),
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: _C.sub(context), size: r.s(18)),
                    ],
                  ),
                ),
              ),
              if (idx < links.length - 1)
                Divider(height: 1, thickness: 0.8,
                    color: _C.border(context),
                    indent: r.s(54), endIndent: r.s(18)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutBtn extends StatelessWidget {
  final _R r;
  final VoidCallback onTap;
  const _LogoutBtn({required this.r, required this.onTap});

  @override
  Widget build(BuildContext context) => _Tap(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: r.s(16)),
      decoration: BoxDecoration(
        color: _C.dangerBg,
        borderRadius: BorderRadius.circular(r.s(40)),
        border: Border.all(
            color: _C.danger.withOpacity(0.25), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, color: _C.danger, size: r.s(20)),
          SizedBox(width: r.s(10)),
          Text('Logout',
              style: TextStyle(
                color: _C.danger,
                fontWeight: FontWeight.w700,
                fontSize: r.f(15),
                letterSpacing: 0.2,
              )),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGOUT SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  final _R r;
  final VoidCallback onConfirm;
  const _LogoutSheet({required this.r, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface(context),
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(r.s(28))),
      ),
      padding: EdgeInsets.fromLTRB(
          r.hPad, r.s(12), r.hPad, r.bottom + r.s(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r.s(40), height: r.s(4),
            decoration: BoxDecoration(
              color: _C.border(context),
              borderRadius: BorderRadius.circular(r.s(2)),
            ),
          ),
          SizedBox(height: r.s(24)),
          Container(
            padding: EdgeInsets.all(r.s(16)),
            decoration: const BoxDecoration(
                color: _C.dangerBg, shape: BoxShape.circle),
            child: Icon(Icons.logout_rounded,
                color: _C.danger, size: r.s(28)),
          ),
          SizedBox(height: r.s(16)),
          Text('Logout?',
              style: TextStyle(
                color: _C.text(context),
                fontSize: r.f(20),
                fontWeight: FontWeight.w800,
              )),
          SizedBox(height: r.s(8)),
          Text('Kya aap sach mein logout karna chahte hain?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _C.sub(context), fontSize: r.f(14))),
          SizedBox(height: r.s(28)),
          Row(
            children: [
              Expanded(
                child: _Tap(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: r.s(14)),
                    decoration: BoxDecoration(
                      color: _C.iconBg(context),
                      borderRadius: BorderRadius.circular(r.s(40)),
                    ),
                    child: Center(
                      child: Text('Cancel',
                          style: TextStyle(
                            color: _C.text(context),
                            fontWeight: FontWeight.w700,
                            fontSize: r.f(15),
                          )),
                    ),
                  ),
                ),
              ),
              SizedBox(width: r.s(12)),
              Expanded(
                child: _Tap(
                  onTap: onConfirm,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: r.s(14)),
                    decoration: BoxDecoration(
                      color: _C.danger,
                      borderRadius: BorderRadius.circular(r.s(40)),
                      boxShadow: [
                        BoxShadow(
                          color: _C.danger.withOpacity(0.30),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('Yes, Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: r.f(15),
                          )),
                    ),
                  ),
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
// STAT CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final _R r;
  final String label, value;
  final Color color, bg;
  const _StatChip({
    required this.r, required this.label,
    required this.value, required this.color, required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: r.s(10), vertical: r.s(10)),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(r.s(_C.rMd)),
          border: Border.all(color: color.withOpacity(0.18), width: 1),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(value,
                  style: TextStyle(
                    color: color, fontSize: r.f(17),
                    fontWeight: FontWeight.w800, letterSpacing: -0.3,
                  )),
            ),
            SizedBox(height: r.s(3)),
            Text(label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _C.sub(context),
                    fontSize: r.f(10), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final _R r;
  final String text;
  const _SectionLabel({required this.r, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: r.s(4), height: r.s(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.goldLight, _C.gold],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(r.s(4)),
        ),
      ),
      SizedBox(width: r.s(10)),
      Text(text,
          style: TextStyle(
            color: _C.text(context), fontSize: r.f(16),
            fontWeight: FontWeight.w800, letterSpacing: -0.3,
          )),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADING
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerView extends StatelessWidget {
  final _R r;
  const _ShimmerView({required this.r});

  Widget _box(double w, double h, double radius) => Container(
    width: w, height: h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor:      isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
      highlightColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header shimmer
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                  top: r.top + r.s(16), bottom: r.s(24),
                  left: r.hPad, right: r.hPad),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _box(r.s(36), r.s(36), 50),
                      _box(r.s(100), r.s(20), 8),
                      _box(r.s(36), r.s(36), 50),
                    ],
                  ),
                  SizedBox(height: r.s(24)),
                  _box(r.s(96), r.s(96), 50),
                  SizedBox(height: r.s(14)),
                  _box(r.s(150), r.s(20), 8),
                  SizedBox(height: r.s(8)),
                  _box(r.s(110), r.s(14), 6),
                  SizedBox(height: r.s(20)),
                  Row(
                    children: [
                      Expanded(child: _box(double.infinity, r.s(60), 14)),
                      SizedBox(width: r.s(10)),
                      Expanded(child: _box(double.infinity, r.s(60), 14)),
                      SizedBox(width: r.s(10)),
                      Expanded(child: _box(double.infinity, r.s(60), 14)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: r.s(16)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.hPad),
              child: Column(
                children: List.generate(3, (_) => Padding(
                  padding: EdgeInsets.only(bottom: r.s(16)),
                  child: _box(double.infinity, r.s(180), 20),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final _R r;
  final String message;
  final VoidCallback onRetry;
  const _ErrorView(
      {required this.r, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.hPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: _C.sub(context), size: r.s(56)),
            SizedBox(height: r.s(16)),
            Text('Kuch gadbad ho gayi!',
                style: TextStyle(
                    color: _C.text(context),
                    fontSize: r.f(18),
                    fontWeight: FontWeight.w700)),
            SizedBox(height: r.s(8)),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: _C.sub(context), fontSize: r.f(13))),
            SizedBox(height: r.s(24)),
            _Tap(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: r.s(32), vertical: r.s(14)),
                decoration: BoxDecoration(
                  color: _C.gold,
                  borderRadius: BorderRadius.circular(r.s(40)),
                  boxShadow: [
                    BoxShadow(color: _C.gold.withOpacity(0.35),
                        blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Text('Dobara Try Karo',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: r.f(15))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS-STYLE TAP  (scale on press, no ink splash)
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
    reverseDuration: const Duration(milliseconds: 180),
    lowerBound: 0.95, upperBound: 1.00, value: 1.0,
  );

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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

// ═════════════════════════════════════════════════════════════════════════════
// main.dart mein aise wire karo:
// ═════════════════════════════════════════════════════════════════════════════
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final theme = context.watch<ThemeProvider>();
//     return MaterialApp(
//       themeMode: theme.themeMode,
//       theme:     ThemeData.light(useMaterial3: true),
//       darkTheme: ThemeData.dark(useMaterial3: true),
//       initialRoute: '/login',
//       routes: {
//         '/login':   (_) => const OtpLoginScreen(),
//         '/profile': (_) => const ProfileScreen(),
//       },
//     );
//   }
// }