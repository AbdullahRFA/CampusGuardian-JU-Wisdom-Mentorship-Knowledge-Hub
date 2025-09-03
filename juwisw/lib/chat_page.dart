import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Load saved chat history
  }

  // 🔹 Save messages to local storage
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(messages);
    await prefs.setString("chat_history", encoded);
  }

// 🔹 Load messages from local storage
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString("chat_history");
    if (stored != null) {
      final decoded = jsonDecode(stored) as List; // Decode as a generic List

      setState(() {
        // Map each item in the list to the correct type
        messages = decoded
            .map((item) => Map<String, String>.from(item as Map))
            .toList();
      });
    }
  }

  // 🔹 Fetch AI response from Gemini API
  Future<void> getResponse(String query) async {
    const String apiKey = "AIzaSyAohznfnNbj-R6yvNGU89UNQGzrUKeMp7k"; // Replace with your API key
    final String url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    Map<String, dynamic> bodyParams = {
      "contents": [
        {
          "parts": [
            {"text": query}
          ]
        }
      ]
    };

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyParams),
      );

      setState(() {
        messages.removeWhere((msg) => msg["role"] == "typing");
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final output = data["candidates"]?[0]["content"]?["parts"]?[0]?["text"] ??
            "⚠️ No response";

        setState(() {
          messages.add({"role": "ai", "text": output});
        });

        _scrollToBottom();
        _saveMessages(); // Save after AI responds
      } else {
        setState(() {
          messages.add({"role": "ai", "text": "❌ Error ${res.statusCode}: ${res.body}"});
        });
        _scrollToBottom();
        _saveMessages();
      }
    } catch (e) {
      setState(() {
        messages.removeWhere((msg) => msg["role"] == "typing");
        messages.add({"role": "ai", "text": "⚠️ Exception: $e"});
      });
      _scrollToBottom();
      _saveMessages();
    }
  }

  // 🔹 When user sends message
  void sendMessage() {
    final text = searchController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      searchController.clear();
      messages.add({"role": "typing", "text": "..."});
    });

    _scrollToBottom();
    _saveMessages(); // Save after user sends

    getResponse(text);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat",
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.deepPurpleAccent.shade700,
      ),
      body: Column(
        children: [
          // Chat area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["role"] == "user";
                final isTyping = msg["role"] == "typing";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isTyping
                        ? const TypingIndicator()
                        : isUser
                        ? Text(msg["text"] ?? "",
                        style: const TextStyle(fontSize: 16))
                        : TypingText(msg["text"] ?? ""),
                  ),
                );
              },
            ),
          ),
          // Input area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated typing effect for AI response
class TypingText extends StatefulWidget {
  final String text;
  const TypingText(this.text, {super.key});

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String displayedText = "";
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_index < widget.text.length) {
        setState(() {
          displayedText += widget.text[_index];
          _index++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GptMarkdown(displayedText, style: const TextStyle(fontSize: 16));
  }
}

/// "AI is typing..." indicator
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _dotCount = StepTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        return Text("AI is typing${"." * _dotCount.value}",
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic));
      },
    );
  }
}