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

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];
  List<ChatSession> chatHistory = []; // For chat history sessions
  String currentContext = "welcome"; // Tracks conversation context
  bool _isTyping = false; // For typing indicator

  // Local storage keys
  static const String _chatHistoryKey = 'chatbot_history';
  static const String _currentSessionKey = 'current_chat_session';

  // Firestore variables
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "guest";

  final Color bgColor = const Color(0xff0B3C5D); // Dark blue
  final Color primaryColor = const Color(0xff3FA9F5); // Light blue
  final Color accentColor = const Color(0xff1DB954); // Green accent
  final Color userBubble = const Color(0xff3FA9F5); // Light blue
  final Color botBubble = Colors.white;
  final Color chipColor = const Color(0xff1C4E6D); // Darker blue for chips

  // Context-based suggested questions
  final Map<String, List<ChatOption>> contextOptions = {
    "welcome": chatOptions, // Initial options
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


  Future<void> _saveCurrentChatToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> messageList = messages
          .map((msg) => msg.toJson())
          .toList();

      await prefs.setString(
        _currentSessionKey,
        jsonEncode(messageList),
      );

      // Update chat history sessions
      if (messages.isNotEmpty) {
        final session = ChatSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _generateSessionTitle(),
          timestamp: DateTime.now(),
          messageCount: messages.length,
          lastMessage: messages.last.message,
        );

        // Add to history if not already present
        final exists = chatHistory.any((s) =>
        s.lastMessage == session.lastMessage &&
            s.title == session.title);

        if (!exists) {
          chatHistory.insert(0, session);
          await _saveChatHistoryToLocal();
        }
      }
    } catch (e) {
      print('Error saving chat to local: $e');
    }
  }

  // 🔄 Load current chat from local storage
  Future<void> _loadLocalChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load current session
      final String? sessionJson = prefs.getString(_currentSessionKey);
      if (sessionJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionJson);
        setState(() {
          messages = decoded
              .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      }

      // Load chat history sessions
      final String? historyJson = prefs.getString(_chatHistoryKey);
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        chatHistory = decoded
            .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading local chat: $e');
    }
  }

  // 🔄 Save chat history sessions to local storage
  Future<void> _saveChatHistoryToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> historyList = chatHistory
          .map((session) => session.toJson())
          .toList();

      await prefs.setString(
        _chatHistoryKey,
        jsonEncode(historyList),
      );
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // 🔄 Clear chat history from local storage
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
      print('Error clearing local chat: $e');
    }
  }

  // 🔄 Generate session title based on first user message
  String _generateSessionTitle() {
    if (messages.isEmpty) return "New Chat";

    final userMessages = messages.where((msg) => msg.isUser).toList();
    if (userMessages.isNotEmpty) {
      final firstUserMsg = userMessages.first.message;
      if (firstUserMsg.length > 30) {
        return "${firstUserMsg.substring(0, 30)}...";
      }
      return firstUserMsg;
    }

    return "Chat ${DateTime.now().day}/${DateTime.now().month}";
  }

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


      if (messages.isNotEmpty) {
        _saveCurrentChatToLocal();
      }
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

    setState(() {
      messages.add(welcomeMessage);
    });

    // Save welcome message
    saveMessage(welcomeMessage);
  }

  void onOptionSelected(ChatOption option) {
    // Save USER message
    final userMsg = ChatMessage(
      message: option.question,
      isUser: true,
      time: DateTime.now(),
      context: option.context ?? "general",
    );

    setState(() {
      messages.add(userMsg);
    });

    // Save user message
    saveMessage(userMsg);

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      // Save BOT reply
      final botMsg = ChatMessage(
        message: option.answer,
        isUser: false,
        time: DateTime.now(),
        context: option.context ?? "general",
        showVerifiedBadge: option.isPolicyRelated ?? false,
      );

      setState(() {
        _isTyping = false;
        messages.add(botMsg);
        // Update context for next suggestions
        if (option.context != null) {
          currentContext = option.context!;
        }
      });

      // Save bot reply
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

  // 🆕 Refresh Chat function
  void _refreshChat() {
    setState(() {
      messages.clear();
      currentContext = "welcome";
      _initializeChat();
    });
  }

  // 🆕 Show Chat History Bottom Sheet
  void _showChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                      Icon(Icons.history, color: primaryColor, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        "Chat History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (chatHistory.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _clearLocalChat();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Clear All",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 24),

                  if (chatHistory.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white30,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No chat history yet",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Start a conversation to see it here",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: chatHistory.length,
                        itemBuilder: (context, index) {
                          final session = chatHistory[index];
                          return _buildHistoryItem(session, index);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(ChatSession session, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: chipColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          // TODO: Load this specific chat session
          Navigator.pop(context);
          // Show snackbar for now
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loading chat from ${session.title}'),
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
          child: Icon(
            Icons.chat_bubble,
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          session.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              session.lastMessage,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(session.timestamp),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.message,
                  size: 12,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  "${session.messageCount} messages",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  // Format time to 12-hour with AM/PM
  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

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
            child: Icon(
              Icons.support_agent,
              color: primaryColor,
            ),
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
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.greenAccent,
                ),
                SizedBox(width: 6),
                Text(
                  "Online • Ready to help",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Changed from refresh to more_vert icon
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white70),
            color: chipColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshChat();
              } else if (value == 'history') {
                _showChatHistory();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      "Refresh Chat",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      "Chat History",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 💬 Chat Messages
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgColor.withOpacity(0.8),
                    bgColor,
                  ],
                ),
              ),
              child: messages.isEmpty
                  ? Center(
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
                      child: Icon(
                        Icons.support_agent,
                        size: 60,
                        color: primaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Start a conversation",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select a question below",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _buildMessageBubble(msg, index);
                      },
                    ),
                  ),
                  // Typing Indicator
                  if (_isTyping) _buildTypingIndicator(),
                ],
              ),
            ),
          ),

          // 📝 Context-based Suggested Questions
          if (!_isTyping && contextOptions.containsKey(currentContext))
            _buildSuggestedQuestions(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent,
              size: 16,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    "Typing",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTypingDot(0),
                      _buildTypingDot(1),
                      _buildTypingDot(2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final options = contextOptions[currentContext] ?? [];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.arrow_forward,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Suggested Next Steps",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
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
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            option.question.length > 30
                                ? '${option.question.substring(0, 30)}...'
                                : option.question,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: primaryColor,
                          ),
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

  Widget _buildMessageBubble(ChatMessage msg, int index) {
    return Column(
      crossAxisAlignment:
      msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (index == 0 ||
            (index > 0 && messages[index - 1].isUser != msg.isUser))
          Padding(
            padding: EdgeInsets.only(bottom: 8, top: index == 0 ? 0 : 16),
            child: Row(
              mainAxisAlignment:
              msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!msg.isUser)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.support_agent,
                      size: 16,
                      color: primaryColor,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  msg.isUser ? "You" : "Assistant",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(msg.time),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            bottom: 8,
            left: msg.isUser ? 0 : 40,
            right: msg.isUser ? 40 : 0,
          ),
          child: Material(
            elevation: 2,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: TextStyle(
                      color: msg.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Show verified badge only for policy-related answers
                  if (!msg.isUser && msg.showVerifiedBadge)
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Verified information • RBI Compliant",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 🆕 Chat Session Model for History
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