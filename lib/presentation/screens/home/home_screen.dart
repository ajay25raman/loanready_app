import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loanready_app/presentation/screens/home/ebook_screen.dart';
import 'package:loanready_app/presentation/screens/home/one_year_trading_screen.dart';
import '../auth/OtpLoginScreen.dart';
import '../chatbot/chatbotdata_screen.dart';
import '../loan/loan_scheme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F3F),
              Color(0xFF023E73),
              Color(0xFF055A8C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              _header(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [

                    const SizedBox(height: 12),

                    _loanCard(),

                    const SizedBox(height: 22),

                    _sectionTitle("Services"),
                    const SizedBox(height: 12),
                    _quickActions(context),

                    const SizedBox(height: 24),

                    _sectionTitle("More Options"),
                    const SizedBox(height: 12),
                    _grid(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔷 HEADER
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                "User Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  // 🔵 LOAN CARD
  Widget _loanCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF023E73),
            Color(0xFF055A8C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Loan Available",
              style: TextStyle(color: Colors.white70)),
          SizedBox(height: 6),
          Text(
            "Up to ₹5,00,000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ⚡ QUICK ACTIONS
  Widget _quickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickItem(Icons.currency_rupee, "Loan", context),
        _quickItem(Icons.smart_toy, "Bot", context),
        _quickItem(Icons.trending_up, "Trading", context),
        _quickItem(Icons.menu_book, "E-Book", context),
      ],
    );
  }

  Widget _quickItem(IconData icon, String text, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (text == "Loan") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LoanSchemeFormScreen()));
        } else if (text == "Bot") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()));
        } else if (text == "Trading") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const OneYearTradingScreen()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const EbookScreen()));
        }
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  // 📊 GRID
  Widget _grid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [

        _glassMenuCard("Register", Icons.person_add, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const OtpLoginScreen()));
        }),

        _glassMenuCard("About", Icons.info_outline, () {
          Navigator.pushNamed(context, '/about');
        }),

        _glassMenuCard("Premium", Icons.workspace_premium, () {
          Navigator.pushNamed(context, '/choosePlan');
        }),

        _glassMenuCard("Loan Scheme", Icons.account_balance, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LoanSchemeFormScreen()));
        }),
      ],
    );
  }

  // 💎 GLASS CARD (REFINED)
  Widget _glassMenuCard(
      String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 26),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔤 TITLE
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}