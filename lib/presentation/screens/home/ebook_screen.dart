import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EbookScreen extends StatelessWidget {
  const EbookScreen({super.key});

  static final List<Map<String, String>> ebooks = [
    {'title': 'PM Street Vendor\'s AtmaNirbhar Nidhi (PM SVANidhi)',
      'url': 'https://drive.google.com/uc?export=download&id=1fOwlkog1L1H3SHCkRJ80N5PglGGhEF0S',
    },
    {
      'title': 'PM Vishwakarma Loan Scheme',
      'url': 'https://drive.google.com/uc?export=download&id=1zbU8yP3iW8t1Z28Ev-iCYJg-OzMLNQ61',
    },
    {
      'title': 'StandUpIndia_MSME_Consultants_EBook',
      'url': 'https://drive.google.com/uc?export=download&id=1-MKB4TILrG3c58s8G6GQG_MojysaqgiK',
    },
    {
      'title': 'PM Vishwakarma Loan Scheme',
      'url': 'https://drive.google.com/uc?export=download&id=1xgTsgjBJHhb2b0MoAwlUa2053eHnF3_n',
    },
    {
      'title': 'CGTMSE_Complete_Guide_The_MSME_Consultants',
      'url': 'https://drive.google.com/uc?export=download&id=1EOEgguNz4py732qVmKABFK5jyMNSBFFC',
    },
    {
      'title': 'PMFME Scheme Complete Guide MSME Consultants',
      'url': 'https://drive.google.com/uc?export=download&id=1c7dkeERkAxiJXwoI4nhRG9pqMrjqhGL8',
    },
    {
      'title': 'PMFME Scheme Complete Guide MSME Consultants',
      'url': 'https://drive.google.com/uc?export=download&id=1JXOUSO2swkUFC25Tv-geuiG2e95klc7i',
    },
    {
      'title': 'Startup_Govt_Loan_Schemes_Ebook',
      'url': 'https://drive.google.com/uc?export=download&id=1oSzF4DX_73ts719MbWMng-g19gmL8Nyq',
    },
    {
      'title': 'MSE Govt Loan Schemes India 2025',
      'url': 'https://drive.google.com/uc?export=download&id=14XQ0oYldgjsxLNGN6zAMnqxkZwSfY2dp',
    },
    {
      'title': 'Fisheries_Loan_Schemes_eBook_MSME_Consultants',
      'url': 'https://drive.google.com/uc?export=download&id=1MbAxVyGUrI4CK-AUiI0plJf7hIht4p1x',
    },
    {
      'title': 'SHG_Loans_India_NULM_NRLM_MSME_Consultants',
      'url': 'https://drive.google.com/uc?export=download&id=1NhiLNk1b1HnlIgd-jmfk9-o3FI4pl9Pn',
    },
    {
      'title': 'ECLGS_Complete_Guide_MSME_Consultants 13.pdf',
      'url': 'https://drive.google.com/uc?export=download&id=15UD09t-lG-69rwfKq0y_rK_2T_Sj_BVw',
    },
  ];
  void _openPDF(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewScreen(pdfUrl: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // soft background like register screen
      appBar: AppBar(
        title: const Text(
          'E-Book Library',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Optional: header with stats or search (premium touch)
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A227).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Color(0xFFC9A227), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Government Schemes Library',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${ebooks.length} PDF guides available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 26),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: ebooks.length,
              itemBuilder: (context, index) {
                final book = ebooks[index];
                return _buildPremiumCard(
                  context: context,
                  title: book['title']!,
                  url: book['url']!,
                  onTap: () => _openPDF(context, book['url']!, book['title']!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({
    required BuildContext context,
    required String title,
    required String url,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: const Color(0xFFC9A227).withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: const Color(0xFFC9A227).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  // PDF icon with gold accent background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFC9A227).withOpacity(0.15),
                          const Color(0xFFC9A227).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFC9A227).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Color(0xFFC9A227),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.5,
                            color: Color(0xFF1E293B),
                            height: 1.3,
                          ),
                           maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.description_outlined, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              'Government Scheme • PDF',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow button with gold circle
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A227).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFFC9A227),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// PDF Viewer Screen (unchanged functionality, just polished)
class PdfViewScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}