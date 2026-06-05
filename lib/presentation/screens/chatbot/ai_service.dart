import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../Model/ChatMessage.dart';
import '../../../data/chatbot.dart';

// ══════════════════════════════════════════════════════════════
// THEME
// ══════════════════════════════════════════════════════════════
class _CT {
  static const bg            = Color(0xFF061E2F);
  static const surface       = Color(0xFF0B3C5D);
  static const surfaceHigh   = Color(0xFF0F4A72);
  static const primary       = Color(0xFF3FA9F5);
  static const primaryGlow   = Color(0x443FA9F5);
  static const accent        = Color(0xFF1DB954);
  static const accentGlow    = Color(0x331DB954);
  static const glass         = Color(0x14FFFFFF);
  static const glassBorder   = Color(0x1FFFFFFF);
  static const userBubble    = Color(0xFF3FA9F5);
  static const botBubble     = Color(0xFF0F4A72);
  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xAAFFFFFF);
  static const textMuted     = Color(0x66FFFFFF);
  static const danger        = Color(0xFFFF6B6B);
}

// ══════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage>  messages     = [];
  List<ChatSession>  chatHistory  = [];
  String             currentContext = "welcome";
  bool               _isTyping     = false;

  Timer?  _thinkingTimer;
  double  _thinkingSeconds = 0.0;

  late AnimationController _dotController;
  late AnimationController _pulseController;

  static const String _chatHistoryKey    = 'chatbot_history';
  static const String _currentSessionKey = 'current_chat_session';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "guest";

  final Map<String, List<ChatOption>> contextOptions = {
    "welcome": chatOptions,
    "eligibility": [
      ChatOption(question: "Apply Now",          answer: "Redirecting to loan application...", context: "apply",     isPolicyRelated: false),
      ChatOption(question: "Documents Required", answer: "Here are the documents needed...",   context: "documents", isPolicyRelated: true),
    ],
    "documents": [
      ChatOption(question: "Check Eligibility", answer: "Let me check your eligibility...", context: "eligibility", isPolicyRelated: false),
      ChatOption(question: "Contact Support",   answer: "Connecting with support...",       context: "support",     isPolicyRelated: false),
    ],
    "interest": [
      ChatOption(question: "Apply for Loan", answer: "Starting your application...", context: "apply",   isPolicyRelated: false),
      ChatOption(question: "Compare Rates",  answer: "Showing rate comparison...",   context: "compare", isPolicyRelated: true),
    ],
    "apply": [
      ChatOption(question: "Track Application", answer: "Checking your status...",      context: "track",   isPolicyRelated: false),
      ChatOption(question: "Contact Support",   answer: "Connecting with specialist...", context: "support", isPolicyRelated: false),
    ],
  };

  // ── lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _loadLocalChatHistory().then((_) {
      if (messages.isEmpty) {
        loadChatHistory().then((_) {
          if (messages.isEmpty) _initializeChat();
        });
      }
    });
  }

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    _dotController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── thinking timer ───────────────────────────────────────
  void _startThinkingTimer() {
    _thinkingSeconds = 0.0;
    _thinkingTimer?.cancel();
    _thinkingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _thinkingSeconds += 0.1);
    });
  }

  void _stopThinkingTimer() {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
  }

  // ── local storage ────────────────────────────────────────
  Future<void> _saveCurrentChatToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _currentSessionKey,
          jsonEncode(messages.map((m) => m.toJson()).toList()));
      if (messages.isNotEmpty) {
        final session = ChatSession(
          id:           DateTime.now().millisecondsSinceEpoch.toString(),
          title:        _generateSessionTitle(),
          timestamp:    DateTime.now(),
          messageCount: messages.length,
          lastMessage:  messages.last.message,
        );
        final exists = chatHistory.any(
                (s) => s.lastMessage == session.lastMessage && s.title == session.title);
        if (!exists) {
          chatHistory.insert(0, session);
          await _saveChatHistoryToLocal();
        }
      }
    } catch (e) { debugPrint('Save error: $e'); }
  }

  Future<void> _loadLocalChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_currentSessionKey);
      if (sessionJson != null) {
        final decoded = jsonDecode(sessionJson) as List;
        setState(() {
          messages = decoded.map((i) => ChatMessage.fromJson(i as Map<String, dynamic>)).toList();
        });
      }
      final historyJson = prefs.getString(_chatHistoryKey);
      if (historyJson != null) {
        final decoded = jsonDecode(historyJson) as List;
        chatHistory = decoded.map((i) => ChatSession.fromJson(i as Map<String, dynamic>)).toList();
      }
    } catch (e) { debugPrint('Load error: $e'); }
  }

  Future<void> _saveChatHistoryToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _chatHistoryKey,
          jsonEncode(chatHistory.map((s) => s.toJson()).toList()));
    } catch (e) { debugPrint('Save history error: $e'); }
  }

  Future<void> _clearLocalChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentSessionKey);
      await prefs.remove(_chatHistoryKey);
      setState(() { messages.clear(); chatHistory.clear(); });
    } catch (e) { debugPrint('Clear error: $e'); }
  }

  String _generateSessionTitle() {
    if (messages.isEmpty) return "New Chat";
    final userMsgs = messages.where((m) => m.isUser).toList();
    if (userMsgs.isNotEmpty) {
      final first = userMsgs.first.message;
      return first.length > 30 ? '${first.substring(0, 30)}...' : first;
    }
    return "Chat ${DateTime.now().day}/${DateTime.now().month}";
  }

  // ── firestore ────────────────────────────────────────────
  Future<void> saveMessage(ChatMessage msg) async {
    await _firestore.collection("users").doc(userId).collection("chats").add(msg.toJson());
    _saveCurrentChatToLocal();
  }

  Future<void> loadChatHistory() async {
    final snapshot = await _firestore
        .collection("users").doc(userId).collection("chats")
        .orderBy("time").get();
    setState(() {
      messages = snapshot.docs.map((d) => ChatMessage.fromJson(d.data())).toList();
      if (messages.isNotEmpty) _saveCurrentChatToLocal();
    });
  }

  void _initializeChat() {
    final welcome = ChatMessage(
      message: "Hello Suraj 👋 I'm your AI Loan Assistant.\nAsk me anything about loans, eligibility, or rates.",
      isUser:           false,
      time:             DateTime.now(),
      context:          "welcome",
      showVerifiedBadge: false,
    );
    setState(() => messages.add(welcome));
    saveMessage(welcome);
  }

  // ── option selected ──────────────────────────────────────
  void onOptionSelected(ChatOption option) {
    HapticFeedback.lightImpact();
    final userMsg = ChatMessage(
      message: option.question,
      isUser:  true,
      time:    DateTime.now(),
      context: option.context ?? "general",
    );
    setState(() { messages.add(userMsg); _isTyping = true; });
    saveMessage(userMsg);
    _startThinkingTimer();

    Future.delayed(const Duration(milliseconds: 1400), () {
      _stopThinkingTimer();
      final botMsg = ChatMessage(
        message:          option.answer,
        isUser:           false,
        time:             DateTime.now(),
        context:          option.context ?? "general",
        showVerifiedBadge: option.isPolicyRelated ?? false,
      );
      setState(() {
        _isTyping        = false;
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
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _refreshChat() {
    HapticFeedback.mediumImpact();
    setState(() { messages.clear(); currentContext = "welcome"; });
    _initializeChat();
  }

  // ── chat history sheet ───────────────────────────────────
  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChatHistorySheet(
        chatHistory: chatHistory,
        onClear: () { _clearLocalChat(); Navigator.pop(context); },
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────
  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:${m} ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CT.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // bg gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:   Alignment.bottomCenter,
                colors: [Color(0xFF082A42), Color(0xFF061E2F)],
              ),
            ),
          ),
          // top glow
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _CT.primary.withOpacity(0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // bottom glow
          Positioned(
            bottom: -60, left: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _CT.accent.withOpacity(0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // content
          SafeArea(
            child: Column(
              children: [
                // messages list
                Expanded(
                  child: messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _buildMessageBubble(messages[i], i),
                  ),
                ),
                // typing indicator
                if (_isTyping) _buildThinkingIndicator(),
                // divider
                Container(height: 1, color: _CT.glassBorder),
                // chips
                if (!_isTyping && contextOptions.containsKey(currentContext))
                  _buildSuggestedChips(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── appbar ───────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: _CT.surface.withOpacity(0.55),
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: _CT.glass,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _CT.glassBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_CT.primary, _CT.primary.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [BoxShadow(color: _CT.primaryGlow, blurRadius: 12)],
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Loan Assistant",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2),
                    ),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, __) => Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _CT.accent,
                              boxShadow: [BoxShadow(
                                color: _CT.accent.withOpacity(
                                    0.4 + _pulseController.value * 0.4),
                                blurRadius: 6, spreadRadius: 1,
                              )],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text("Online • AI Ready",
                            style: TextStyle(fontSize: 10, color: _CT.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // AI badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_CT.primary.withOpacity(0.25), _CT.primaryGlow]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _CT.primary.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: _CT.primary, size: 10),
                    SizedBox(width: 4),
                    Text("AI", style: TextStyle(
                        color: _CT.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: _CT.textSecondary),
                color: _CT.surfaceHigh,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (v) {
                  if (v == 'refresh') _refreshChat();
                  if (v == 'history') _showChatHistory();
                },
                itemBuilder: (_) => [
                  _menuItem('refresh', Icons.refresh_rounded,  "Refresh Chat"),
                  _menuItem('history', Icons.history_rounded,   "Chat History"),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String val, IconData icon, String label) =>
      PopupMenuItem(
        value: val,
        child: Row(children: [
          Icon(icon, color: _CT.primary, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ]),
      );

  // ── empty state ──────────────────────────────────────────
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 86, height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              _CT.primary.withOpacity(0.18),
              _CT.primary.withOpacity(0.04),
            ]),
            border: Border.all(color: _CT.primary.withOpacity(0.2)),
          ),
          child: const Icon(Icons.support_agent_rounded,
              color: _CT.primary, size: 38),
        ),
        const SizedBox(height: 20),
        const Text("How can I help you?",
            style: TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text("Select a suggestion below to start",
            style: TextStyle(color: _CT.textMuted, fontSize: 13)),
      ],
    ),
  );

  // ── thinking indicator ───────────────────────────────────
  Widget _buildThinkingIndicator() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _botAvatar(),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _CT.botBubble,
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(18),
              topRight:    Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft:  Radius.circular(4),
            ),
            border: Border.all(color: _CT.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Thinking",
                  style: TextStyle(color: _CT.textSecondary, fontSize: 12)),
              const SizedBox(width: 10),
              // animated dots
              AnimatedBuilder(
                animation: _dotController,
                builder: (_, __) => Row(
                  children: List.generate(3, (i) {
                    final offset = ((_dotController.value * 3) - i).clamp(0.0, 1.0);
                    final bounce = (offset < 0.5 ? offset : 1.0 - offset) * 2;
                    return Transform.translate(
                      offset: Offset(0, -5 * bounce),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5),
                        child: Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                              color: _CT.primary, shape: BoxShape.circle),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${_thinkingSeconds.toStringAsFixed(1)}s",
                style: const TextStyle(
                    color: _CT.textMuted, fontSize: 10,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── suggested chips ──────────────────────────────────────
  Widget _buildSuggestedChips() {
    final options = contextOptions[currentContext] ?? [];
    return Container(
      color: _CT.bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: _CT.accent, size: 13),
            const SizedBox(width: 6),
            const Text("Suggested",
                style: TextStyle(color: _CT.textSecondary,
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              itemBuilder: (_, i) => _AnimatedChip(
                label:  options[i].question,
                onTap:  () => onOptionSelected(options[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── message bubble ───────────────────────────────────────
  Widget _buildMessageBubble(ChatMessage msg, int index) {
    final showHeader =
        index == 0 || messages[index - 1].isUser != msg.isUser;

    return TweenAnimationBuilder<double>(
      tween:    Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve:    Curves.easeOut,
      builder:  (_, v, child) => Opacity(opacity: v,
          child: Transform.translate(
              offset: Offset(0, 12 * (1 - v)), child: child)),
      child: Padding(
        padding: EdgeInsets.only(
            top: showHeader ? (index == 0 ? 0 : 16) : 3,
            bottom: 2),
        child: Column(
          crossAxisAlignment:
          msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // header row
            if (showHeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: msg.isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!msg.isUser) ...[
                      _botAvatar(size: 22),
                      const SizedBox(width: 7),
                    ],
                    Text(msg.isUser ? "You" : "AI Assistant",
                        style: const TextStyle(
                            color: _CT.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    Text(_formatTime(msg.time),
                        style: const TextStyle(color: _CT.textMuted, fontSize: 9)),
                    if (msg.isUser) ...[
                      const SizedBox(width: 7),
                      _userAvatar(size: 22),
                    ],
                  ],
                ),
              ),
            // bubble
            Row(
              mainAxisAlignment: msg.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!msg.isUser && !showHeader) const SizedBox(width: 29),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.74),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: msg.isUser
                          ? const LinearGradient(colors: [
                        Color(0xFF3FA9F5), Color(0xFF2896E5)])
                          : null,
                      color: msg.isUser ? null : _CT.botBubble,
                      borderRadius: BorderRadius.only(
                        topLeft:     const Radius.circular(18),
                        topRight:    const Radius.circular(18),
                        bottomLeft:  msg.isUser
                            ? const Radius.circular(18)
                            : const Radius.circular(4),
                        bottomRight: msg.isUser
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
                      ),
                      border: Border.all(
                          color: msg.isUser
                              ? Colors.transparent
                              : _CT.glassBorder),
                      boxShadow: [
                        if (msg.isUser)
                          BoxShadow(
                              color: _CT.primary.withOpacity(0.25),
                              blurRadius: 12, offset: const Offset(0, 4)),
                        if (!msg.isUser)
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.message,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              height: 1.5),
                        ),
                        if (!msg.isUser && msg.showVerifiedBadge) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _CT.accentGlow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.verified_rounded,
                                    size: 11, color: _CT.accent),
                                SizedBox(width: 4),
                                Text("Verified • RBI Compliant",
                                    style: TextStyle(
                                        color: _CT.accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── avatars ──────────────────────────────────────────────
  Widget _botAvatar({double size = 28}) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [Color(0xFF3FA9F5), Color(0xFF2371B5)]),
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: _CT.primaryGlow, blurRadius: 8)],
    ),
    child: Icon(Icons.support_agent_rounded,
        size: size * 0.52, color: Colors.white),
  );

  Widget _userAvatar({double size = 28}) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: _CT.primary.withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(color: _CT.primary.withOpacity(0.4)),
    ),
    child: Icon(Icons.person_rounded,
        size: size * 0.52, color: _CT.primary),
  );
}

// ══════════════════════════════════════════════════════════════
// ANIMATED CHIP
// ══════════════════════════════════════════════════════════════
class _AnimatedChip extends StatefulWidget {
  final String       label;
  final VoidCallback onTap;
  const _AnimatedChip({required this.label, required this.onTap});

  @override
  State<_AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<_AnimatedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ac    = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.92)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown:  (_) => _ac.forward(),
    onTapUp:    (_) { _ac.reverse(); widget.onTap(); },
    onTapCancel: ()  => _ac.reverse(),
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            _CT.primary.withOpacity(0.18),
            _CT.primary.withOpacity(0.06),
          ]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _CT.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label.length > 26
                  ? '${widget.label.substring(0, 26)}...'
                  : widget.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 9, color: _CT.primary),
          ],
        ),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// CHAT HISTORY BOTTOM SHEET
// ══════════════════════════════════════════════════════════════
class _ChatHistorySheet extends StatelessWidget {
  final List<ChatSession> chatHistory;
  final VoidCallback       onClear;
  const _ChatHistorySheet({required this.chatHistory, required this.onClear});

  String _fmt(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return "Today";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7)  return "${diff.inDays}d ago";
    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xF00B3C5D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, sc) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                        color: _CT.primaryGlow,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.history_rounded,
                        color: _CT.primary, size: 17),
                  ),
                  const SizedBox(width: 12),
                  const Text("Chat History",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (chatHistory.isNotEmpty)
                    TextButton(
                      onPressed: onClear,
                      child: const Text("Clear All",
                          style: TextStyle(color: _CT.danger, fontSize: 13)),
                    ),
                ]),
                const SizedBox(height: 16),
                if (chatHistory.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              color: Colors.white24, size: 48),
                          const SizedBox(height: 14),
                          const Text("No history yet",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 15)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: sc,
                      itemCount: chatHistory.length,
                      itemBuilder: (_, i) {
                        final s = chatHistory[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _CT.glass,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _CT.glassBorder),
                          ),
                          child: Row(children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                  color: _CT.primaryGlow,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.chat_bubble_rounded,
                                  color: _CT.primary, size: 17),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  const SizedBox(height: 3),
                                  Text(s.lastMessage,
                                      style: const TextStyle(
                                          color: _CT.textMuted, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_fmt(s.timestamp),
                                    style: const TextStyle(
                                        color: _CT.textMuted, fontSize: 9)),
                                const SizedBox(height: 3),
                                Text("${s.messageCount} msgs",
                                    style: const TextStyle(
                                        color: _CT.textMuted, fontSize: 9)),
                              ],
                            ),
                          ]),
                        );
                      },
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

// ══════════════════════════════════════════════════════════════
// ChatSession MODEL
// ══════════════════════════════════════════════════════════════
class ChatSession {
  final String   id, title, lastMessage;
  final DateTime timestamp;
  final int      messageCount;

  const ChatSession({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messageCount,
    required this.lastMessage,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title,
    'timestamp': timestamp.toIso8601String(),
    'messageCount': messageCount, 'lastMessage': lastMessage,
  };

  factory ChatSession.fromJson(Map<String, dynamic> j) => ChatSession(
    id: j['id'], title: j['title'],
    timestamp:    DateTime.parse(j['timestamp']),
    messageCount: j['messageCount'],
    lastMessage:  j['lastMessage'],
  );
}