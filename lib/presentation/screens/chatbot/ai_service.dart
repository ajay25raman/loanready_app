import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../Model/ChatMessage.dart';
import '../../../data/chatbot.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];
  List<ChatSession> chatHistory = [];
  String currentContext = "welcome";
  bool _isTyping = false;

  // ✅ Thinking timer
  Timer? _thinkingTimer;
  double _thinkingSeconds = 0.0;

  // ✅ Typing animation controller
  late AnimationController _dotController;

  static const String _chatHistoryKey = 'chatbot_history';
  static const String _currentSessionKey = 'current_chat_session';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "guest";

  final Color bgColor = const Color(0xff0B3C5D);
  final Color primaryColor = const Color(0xff3FA9F5);
  final Color accentColor = const Color(0xff1DB954);
  final Color userBubble = const Color(0xff3FA9F5);
  final Color botBubble = Colors.white;
  final Color chipColor = const Color(0xff1C4E6D);
  final Color tabBarColor = const Color(0xff082e48);

  final Map<String, List<ChatOption>> contextOptions = {
    "welcome": chatOptions,
    "eligibility": [
      ChatOption(
        question: "Apply Now",
        answer: "Redirecting to loan application form...",
        context: "apply",
        isPolicyRelated: false,
      ),
      ChatOption(
        question: "Check EMI Calculator",
        answer: "Opening EMI calculator...",
        context: "emi",
        isPolicyRelated: false,
      ),
      ChatOption(
        question: "Documents Required",
        answer: "Here are the documents needed for loan application...",
        context: "documents",
        isPolicyRelated: true,
      ),
    ],
    "documents": [
      ChatOption(
        question: "Upload Documents",
        answer: "Redirecting to document upload portal...",
        context: "upload",
        isPolicyRelated: false,
      ),
      ChatOption(
        question: "Check Eligibility",
        answer: "Let me check your eligibility...",
        context: "eligibility",
        isPolicyRelated: false,
      ),
      ChatOption(
        question: "Contact Support",
        answer: "Connecting you with our support team...",
        context: "support",
        isPolicyRelated: false,
      ),
    ],
    "interest": [
      ChatOption(
        question: "Apply for Loan",
        answer: "Starting your loan application process...",
        context: "apply",
        isPolicyRelated: false,
      ),
      ChatOption(
        question: "Compare Interest Rates",
        answer: "Showing comparison of interest rates...",
        context: "compare",
        isPolicyRelated: true,
      ),
      ChatOption(
        question: "EMI Calculator",
        answer: "Opening EMI calculator with current rates...",
        context: "emi",
        isPolicyRelated: false,
      ),
    ],
    "apply": [
      ChatOption(
        question: "Track Application",
        answer: "Checking your application status...",
        context: "track",
        isPolicyRelated: false,
      ),
      ChatOption(
        question: "Contact Support",
        answer: "Connecting with loan specialist...",
        context: "support",
        isPolicyRelated: false,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _loadLocalChatHistory().then((_) {
      if (messages.isEmpty) {
        loadChatHistory().then((_) {
          if (messages.isEmpty) {
            _initializeChat();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    _dotController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────
  // ✅ THINKING TIMER — starts when bot types
  // ────────────────────────────────────────────
  void _startThinkingTimer() {
    _thinkingSeconds = 0.0;
    _thinkingTimer?.cancel();
    _thinkingTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        _thinkingSeconds += 0.1;
      });
    });
  }

  void _stopThinkingTimer() {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
  }

  // ────────────────────────────────────────────
  // LOCAL STORAGE
  // ────────────────────────────────────────────
  Future<void> _saveCurrentChatToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> messageList =
      messages.map((msg) => msg.toJson()).toList();
      await prefs.setString(_currentSessionKey, jsonEncode(messageList));

      if (messages.isNotEmpty) {
        final session = ChatSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _generateSessionTitle(),
          timestamp: DateTime.now(),
          messageCount: messages.length,
          lastMessage: messages.last.message,
        );

        final exists = chatHistory.any((s) =>
        s.lastMessage == session.lastMessage &&
            s.title == session.title);

        if (!exists) {
          chatHistory.insert(0, session);
          await _saveChatHistoryToLocal();
        }
      }
    } catch (e) {
      debugPrint('Error saving chat to local: $e');
    }
  }

  Future<void> _loadLocalChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionJson = prefs.getString(_currentSessionKey);
      if (sessionJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionJson);
        setState(() {
          messages = decoded
              .map((item) =>
              ChatMessage.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      }
      final String? historyJson = prefs.getString(_chatHistoryKey);
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        chatHistory = decoded
            .map((item) =>
            ChatSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading local chat: $e');
    }
  }

  Future<void> _saveChatHistoryToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _chatHistoryKey,
        jsonEncode(chatHistory.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  Future<void> _clearLocalChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentSessionKey);
      await prefs.remove(_chatHistoryKey);
      setState(() {
        messages.clear();
        chatHistory.clear();
      });
    } catch (e) {
      debugPrint('Error clearing local chat: $e');
    }
  }

  String _generateSessionTitle() {
    if (messages.isEmpty) return "New Chat";
    final userMessages = messages.where((msg) => msg.isUser).toList();
    if (userMessages.isNotEmpty) {
      final firstUserMsg = userMessages.first.message;
      return firstUserMsg.length > 30
          ? '${firstUserMsg.substring(0, 30)}...'
          : firstUserMsg;
    }
    return "Chat ${DateTime.now().day}/${DateTime.now().month}";
  }

  // ────────────────────────────────────────────
  // FIRESTORE
  // ────────────────────────────────────────────
  Future<void> saveMessage(ChatMessage msg) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("chats")
        .add(msg.toJson());
    _saveCurrentChatToLocal();
  }

  Future<void> loadChatHistory() async {
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("chats")
        .orderBy("time")
        .get();
    setState(() {
      messages = snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
      if (messages.isNotEmpty) _saveCurrentChatToLocal();
    });
  }

  void _initializeChat() {
    final welcomeMessage = ChatMessage(
      message:
      "Hello 👋 I'm your loan assistant.\nSelect a question below or type your query.",
      isUser: false,
      time: DateTime.now(),
      context: "welcome",
      showVerifiedBadge: false,
    );
    setState(() => messages.add(welcomeMessage));
    saveMessage(welcomeMessage);
  }

  // ────────────────────────────────────────────
  // OPTION SELECTED
  // ────────────────────────────────────────────
  void onOptionSelected(ChatOption option) {
    final userMsg = ChatMessage(
      message: option.question,
      isUser: true,
      time: DateTime.now(),
      context: option.context ?? "general",
    );
    setState(() {
      messages.add(userMsg);
      _isTyping = true;
    });
    saveMessage(userMsg);

    // ✅ Start thinking timer
    _startThinkingTimer();

    Future.delayed(const Duration(milliseconds: 1200), () {
      _stopThinkingTimer();

      final botMsg = ChatMessage(
        message: option.answer,
        isUser: false,
        time: DateTime.now(),
        context: option.context ?? "general",
        showVerifiedBadge: option.isPolicyRelated ?? false,
      );

      setState(() {
        _isTyping = false;
        _thinkingSeconds = 0.0;
        messages.add(botMsg);
        if (option.context != null) currentContext = option.context!;
      });

      saveMessage(botMsg);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _refreshChat() {
    setState(() {
      messages.clear();
      currentContext = "welcome";
    });
    _initializeChat();
  }

  // ────────────────────────────────────────────
  // CHAT HISTORY BOTTOM SHEET
  // ────────────────────────────────────────────
  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.history, color: primaryColor),
                  const SizedBox(width: 12),
                  const Text(
                    "Chat History",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (chatHistory.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _clearLocalChat();
                        Navigator.pop(context);
                      },
                      child: const Text("Clear All",
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (chatHistory.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: Colors.white30, size: 48),
                        const SizedBox(height: 16),
                        const Text("No chat history yet",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text("Start a conversation to see it here",
                            style: TextStyle(
                                color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) =>
                        _buildHistoryItem(chatHistory[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ChatSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: chipColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loading chat: ${session.title}'),
              backgroundColor: primaryColor,
            ),
          );
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.chat_bubble, color: primaryColor, size: 20),
        ),
        title: Text(session.title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(session.lastMessage,
                style:
                const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Text(_formatDate(session.timestamp),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
                const SizedBox(width: 12),
                Icon(Icons.message, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Text("${session.messageCount} msgs",
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing:
        const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }

  // ────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────
  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return "Today";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.support_agent, color: primaryColor),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Loan Assistant",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  "Online • Ready to help",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xff1C4E6D),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'refresh') _refreshChat();
              if (value == 'history') _showChatHistory();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                    const Text("Refresh Chat",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                    const Text("Chat History",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Chat messages ──
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(messages[index], index),
                  ),
                ),
                if (_isTyping) _buildThinkingIndicator(),
              ],
            ),
          ),

          // ── Suggested chips ──
          if (!_isTyping &&
              contextOptions.containsKey(currentContext))
            _buildSuggestedQuestions(),

          // ── Bottom nav bar ──
          _buildBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
            Icon(Icons.support_agent, size: 60, color: primaryColor.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          const Text("Start a conversation",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text("Select a question below",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // ✅ THINKING INDICATOR with live timer
  // ────────────────────────────────────────────
  Widget _buildThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.support_agent, size: 16, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Thinking",
                    style:
                    TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(width: 10),
                // ✅ Animated dots
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, _) {
                    return Row(
                      children: List.generate(3, (i) {
                        final offset =
                        ((_dotController.value * 3) - i).clamp(0.0, 1.0);
                        final bounce = (offset < 0.5
                            ? offset
                            : 1.0 - offset) *
                            2;
                        return Transform.translate(
                          offset: Offset(0, -4 * bounce),
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 2),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 10),
                // ✅ Live seconds counter
                Text(
                  "${_thinkingSeconds.toStringAsFixed(1)}s",
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 11,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // SUGGESTED CHIPS
  // ────────────────────────────────────────────
  Widget _buildSuggestedQuestions() {
    final options = contextOptions[currentContext] ?? [];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_forward, color: accentColor, size: 16),
              const SizedBox(width: 8),
              const Text("Suggested next steps",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onOptionSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            option.question.length > 28
                                ? '${option.question.substring(0, 28)}...'
                                : option.question,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.chevron_right,
                              size: 14, color: primaryColor),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // ✅ BOTTOM NAV BAR (new!)
  // ────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      color: tabBarColor,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.chat_bubble, "Chat", isActive: true),
          _navItem(Icons.calculate_outlined, "EMI Calc"),
          _navItem(Icons.description_outlined, "Docs"),
          _navItem(Icons.history, "History",
              onTap: _showChatHistory),
          _navItem(Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 22,
              color: isActive ? primaryColor : Colors.white38),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color:
                  isActive ? primaryColor : Colors.white38)),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // MESSAGE BUBBLE
  // ────────────────────────────────────────────
  Widget _buildMessageBubble(ChatMessage msg, int index) {
    final showHeader = index == 0 ||
        (index > 0 && messages[index - 1].isUser != msg.isUser);

    return Column(
      crossAxisAlignment:
      msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: EdgeInsets.only(
                bottom: 6, top: index == 0 ? 0 : 14),
            child: Row(
              mainAxisAlignment: msg.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!msg.isUser)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.support_agent,
                        size: 14, color: primaryColor),
                  ),
                const SizedBox(width: 6),
                Text(
                  msg.isUser ? "You" : "Assistant",
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(msg.time),
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: EdgeInsets.only(
            bottom: 6,
            left: msg.isUser ? 0 : 36,
            right: msg.isUser ? 36 : 0,
          ),
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: msg.isUser
                  ? const Radius.circular(18)
                  : const Radius.circular(4),
              bottomRight: msg.isUser
                  ? const Radius.circular(4)
                  : const Radius.circular(18),
            ),
            color: msg.isUser ? userBubble : botBubble,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: TextStyle(
                      color:
                      msg.isUser ? Colors.white : Colors.black87,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  if (!msg.isUser && msg.showVerifiedBadge) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified,
                            size: 12, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          "Verified • RBI Compliant",
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════
// ChatSession model
// ════════════════════════════════════════════════
class ChatSession {
  final String id;
  final String title;
  final DateTime timestamp;
  final int messageCount;
  final String lastMessage;

  ChatSession({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messageCount,
    required this.lastMessage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timestamp': timestamp.toIso8601String(),
    'messageCount': messageCount,
    'lastMessage': lastMessage,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'],
    title: json['title'],
    timestamp: DateTime.parse(json['timestamp']),
    messageCount: json['messageCount'],
    lastMessage: json['lastMessage'],
  );
}