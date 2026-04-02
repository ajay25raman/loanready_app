import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:ui';

class EbookScreen extends StatelessWidget {
  const EbookScreen({super.key});

  // 📚 Expanded Ebook List with your new PDFs
  static final List<Map<String, String>> ebooks = [
    {
      'title': 'Pradhan Mantri Mudra Yojana (PMMY)',
      'url':
      'https://drive.google.com/uc?export=download&id=1SEBwb7koT-MUypMqqkyFrfHCGIsYLSij',
    },
    {
      'title': 'SBI e-Mudra',
      'url': 'https://drive.google.com/uc?export=download&id=16HVjCXIOSH3mkEJ5hlfMO5BZblLeE5Ff',
    },
    {
      'title': 'Stand-Up India Scheme',
      'url': 'https://drive.google.com/uc?export=download&id=1UWq2lHunUMMaaP3P2X7YmF5J_jQOxXO0',
    },
    {
      'title': 'PM Street Vendor’s AtmaNirbhar Nidhi (PM SVANidhi)',
      'url': 'https://drive.google.com/uc?export=download&id=1-ogeSHrs5IZDBEqVCmXPiTQ1UvDXqMHg',
    },
    {
      'title': 'Prime Minister’s Employment Generation Programme (PMEGP)',
      'url': 'https://drive.google.com/uc?export=download&id=1NnvSs-r9K2Zq0PudCCzVQRZhcSRjbWtX',
    },
    {
      'title': 'Deendayal Antyodaya Yojana – National Rural Livelihoods Mission (DAY-NRLM)',
      'url': 'https://drive.google.com/uc?export=download&id=16JlOaLLzO5yqM5IA-1W7SPXOdeokTgVM',
    },
    {
      'title': 'Deendayal Antyodaya Yojana – National Urban Livelihoods Mission (DAY-NULM)',
      'url': 'https://drive.google.com/uc?export=download&id=1LzdAkJ9Ful01PjPNHIzox4AyoRbXScIc',
    },
    {
      'title': 'Revised SB-OD Scheme for BSBD Accounts',
      'url': 'https://drive.google.com/uc?export=download&id=1x7LuixjugAoKsdAZMXhRJqq1y3dLzpTp',
    },
    {
      'title': 'Agriculture Infrastructure Fund (AIF)',
      'url': 'https://drive.google.com/uc?export=download&id=14ZI9VP0oxpfu09C5NEvUz7Z_ayAVGJYE',
    },
    {
      'title': 'Animal Husbandry Infrastructure Development Fund (AHIDF)',
      'url': 'https://drive.google.com/uc?export=download&id=1O2eD3Rard133UPrufyoaKu1wwiCWJCeg',
    },
    {
      'title': 'PM Formalization of Micro Food Processing Enterprises (PMFME)',
      'url': 'https://drive.google.com/uc?export=download&id=1ow-9EsNZ5pgNBm3w1SeiEA9C3DTfuOCo',
    },
    {
      'title': 'Pradhan Mantri Kisan Urja Suraksha evam Utthaan Mahabiyan (PM KUSUM)',
      'url': 'https://drive.google.com/uc?export=download&id=1PpQXN-scbIxs6uiQs7E2NdF-9vie_46k',
    },
    {
      'title': 'Credit Guarantee Fund Trust for Micro and Small Enterprises',
      'url': 'https://drive.google.com/uc?export=download&id=1chPA9Yw5uArLna1ps7YERT1a3gNBndd4',
    },
    {
      'title': 'Credit Guarantee Fund for Micro Units',
      'url': 'https://drive.google.com/uc?export=download&id=1lWLsVxMyzlQ8IbKhW7KdOLrtyFGgcyHY',
    },
    {
      'title': 'Credit Guarantee Scheme for Stand-Up India',
      'url': 'https://drive.google.com/uc?export=download&id=1Dna7B3unksh8JCK7klg2YnmNO09S_JEl',
    },
    {
      'title': 'Interest Subvention',
      'url': 'https://drive.google.com/uc?export=download&id=1VXAkDFjdopwoUW10P407yVVG1GsgCQfa',
    },
    {
      'title': 'MSME Subsidy Schemes',
      'url': 'https://drive.google.com/uc?export=download&id=1X8qFKX5-uwjIKlfJe68bkBCOWBifj-Rv',
    },
    {
      'title': 'PMFME Scheme',
      'url': 'https://drive.google.com/uc?export=download&id=1FPO0NRKgZbf3CG9KndQ_-vjXe7MDuYsT',
    }, 

  ];

  void _openPDF(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewScreen(
          pdfUrl: url,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'E-Book Library',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF001F3F).withOpacity(0.95),
              const Color(0xFF002856).withOpacity(0.98),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ebooks.length,
          itemBuilder: (context, index) {
            final book = ebooks[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassmorphicCard(
                onTap: () => _openPDF(context, book['url']!, book['title']!),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    book['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  subtitle: Text(
                    'Tap to read • PDF',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            // ⭐ IMPORTANT: BackdropFilter ke andar child ko Container mein wrap karo
            // aur background color with opacity do
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class PdfViewScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.network(
        pdfUrl,
      ),
    );
  }
}