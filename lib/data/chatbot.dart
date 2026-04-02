class ChatOption {
  final String question;
  final String answer;
  final String? context;
  final bool? isPolicyRelated;

  ChatOption({
    required this.question,
    required this.answer,
    this.context,
    this.isPolicyRelated,
  });
}
final List<ChatOption> chatOptions = [

  // 🔹 Business Loan Entry
  ChatOption(
    question: "Are you a micro or small business owner looking for a collateral-free government loan?",
    answer:
    "Yes or No. If yes, you can proceed to select your loan amount requirement.",
  ),

  // 🔹 Loan Amount Selection
  ChatOption(
    question: "How much loan amount do you need?",
    answer:
    "Available options are ₹15,000–₹50,000, ₹50,001–₹5,00,000, ₹5,00,001–₹10,00,000, and ₹10,00,001–₹20,00,000.",
  ),

  // 🔹 Schemes: 15,000–50,000
  ChatOption(
    question: "Which schemes are available for ₹15,000 to ₹50,000 loans?",
    answer:
    "PM SVANidhi for street vendors, PM Vishwakarma for artisans, and MUDRA Shishu for all businesses.",
  ),

  // 🔹 Schemes: 50,001–5,00,000
  ChatOption(
    question: "Which schemes are available for ₹50,001 to ₹5,00,000 loans?",
    answer:
    "PM Vishwakarma for artisans, MUDRA Kishore for businesses, and state-specific schemes like West Bengal Bhabishyat Credit Card.",
  ),

  // 🔹 Schemes: 5,00,001–10,00,000
  ChatOption(
    question: "Which schemes are available for ₹5,00,001 to ₹10,00,000 loans?",
    answer:
    "MUDRA Tarun, West Bengal Bhabishyat Credit Card, and other state-specific schemes.",
  ),

  // 🔹 Schemes: 10,00,001–20,00,000
  ChatOption(
    question: "Which schemes are available for ₹10,00,001 to ₹20,00,000 loans?",
    answer:
    "MUDRA Tarun Plus is available for established businesses only.",
  ),

  // 🔹 Documents: 15,000–50,000
  ChatOption(
    question: "What documents are required for a ₹15,000 to ₹50,000 loan?",
    answer:
    "KYC, business proof, scheme-specific certificate, financial reports (preferred), ITR (preferred), and good credit score.",
  ),

  // 🔹 Documents: 50,001–5,00,000
  ChatOption(
    question: "What documents are required for a ₹50,001 to ₹5,00,000 loan?",
    answer:
    "KYC, business proof, scheme-specific documents, project report (preferred), financials and ITR mandatory above ₹2,00,000.",
  ),

  // 🔹 Documents: 5,00,001–10,00,000
  ChatOption(
    question: "What documents are required for a ₹5,00,001 to ₹10,00,000 loan?",
    answer:
    "KYC, business proof, scheme documents, project report, mandatory financial reports, ITR, and good credit score.",
  ),

  // 🔹 Documents: 10,00,001–20,00,000
  ChatOption(
    question: "What documents are required for a ₹10,00,001 to ₹20,00,000 loan?",
    answer:
    "KYC, business proof, scheme documents, project report, mandatory financials, ITR, good credit score, and existing business history.",
  ),
];
