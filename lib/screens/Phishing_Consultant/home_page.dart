import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:demo_app/const.dart';
import 'dart:convert';
import 'dart:async';

class HomePage extends StatefulWidget{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Assistant");
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Phishing Analyser"),
      ),

      body: _buildUI(),
    );

    
  }

  // File: lib/screens/Phishing_Consultant/home_page.dart

Widget _buildUI() {
  return DashChat(
    // 1. Add MessageOptions to style the chat bubbles
    messageOptions: MessageOptions(
      currentUserContainerColor: Colors.grey[700], // Color for your messages
      containerColor: const Color(0xFF2a0b0f), // Color for Gemini's messages
      textColor: Colors.white,
    ),
    // 2. Modify InputOptions to style the text input bar
    inputOptions: InputOptions(
      inputTextStyle: const TextStyle(color: Colors.white), // Makes your typing visible
      inputDecoration: InputDecoration(
        isDense: true,
        hintText: "Type here...",
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[800], // Dark background for the input box
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      sendButtonBuilder: (send) {
        return IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: send,
        );
      },
      trailing: [
        IconButton(
          onPressed: _sendMediaMessage,
          icon: const Icon(
            Icons.image,
            color: Colors.grey, // Style the image icon
          ),
        )
      ],
    ),
    currentUser: currentUser,
    onSend: _sendMessage,
    messages: messages,
  );
}

void _sendMessage(ChatMessage chatMessage) {
  setState(() {
    messages = [chatMessage, ...messages];
  });

  String question = chatMessage.text.trim();

  if (_looksLikeUrl(question)) {
    // Show a scanning placeholder message
    final scanningMsg = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: "🔍 Scanning URL ...",
    );

    setState(() {
      messages = [scanningMsg, ...messages];
    });

    _virustotalScanUrlAndReport(question).then((resultText) {
      final resultMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: resultText,
      );

      setState(() {
        // Remove scanning placeholder and show result
        final rest = messages.where((m) => m != scanningMsg).toList();
        messages = [resultMessage, ...rest];
      });
    }).catchError((e) {
      final errorMsg = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "⚠️ Error scanning URL: $e",
      );

      setState(() {
        final rest = messages.where((m) => m != scanningMsg).toList();
        messages = [errorMsg, ...rest];
      });
    });

    return;  // Skip Gemini when input is a URL
  }

  // Gemini API flow for non-URL inputs
  String fullResponse = "";

  Gemini.instance.promptStream(parts: [Part.text(question)]).listen(
    (event) {
      fullResponse += " ${event?.output ?? ""}";
    },
    onError: (error) {
      print("Gemini error: $error");
    },
    onDone: () {
      ChatMessage message = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: fullResponse.isNotEmpty ? fullResponse : "No response from Gemini.",
      );

      setState(() {
        messages = [message, ...messages];
      });
    },
  );
}

// function used to send screenshot to gemini
void _sendMediaMessage() async {
  ImagePicker picker = ImagePicker();
  XFile? file = await picker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    ChatMessage chatMessage = ChatMessage(
      user: currentUser, 
      createdAt: DateTime.now(), 
      text: "Describe this picture?", 
      medias: [
        ChatMedia(
          url: file.path, 
          fileName: "", type: 
          MediaType.image
          )
      ],
    );
  }
}

// function used to check whether string is url or not
bool _looksLikeUrl(String text) {
  final uri = Uri.tryParse(text);
  return (uri != null && (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')))
      || (text.contains('.') && !text.contains(' '));
}

// Future function to scan url and give its rating
Future<String> _virustotalScanUrlAndReport(String rawUrl) async {
  final normalized = rawUrl.startsWith(RegExp(r'https?://')) ? rawUrl : 'http://$rawUrl';

  final postUri = Uri.parse('https://www.virustotal.com/api/v3/urls');
  final headers = {
    'x-apikey': VIRUSTOTAL_API_KEY,
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  final body = 'url=${Uri.encodeComponent(normalized)}';

  final postResp = await http.post(postUri, headers: headers, body: body);

  if (!(postResp.statusCode == 200 || postResp.statusCode == 201)) {
    throw Exception('VirusTotal scan request failed: ${postResp.statusCode} ${postResp.body}');
  }

  final Map j = jsonDecode(postResp.body);
  final String? analysisId = j['data']?['id'];

  if (analysisId == null) {
    throw Exception('VirusTotal did not return analysis ID.');
  }

  // Poll for completion
  final analysisUri = Uri.parse('https://www.virustotal.com/api/v3/analyses/$analysisId');
  bool completed = false;
  int tries = 0;
  while (!completed && tries < 10) {
    await Future.delayed(const Duration(seconds: 2));

    final r = await http.get(analysisUri, headers: {'x-apikey': VIRUSTOTAL_API_KEY});

    if (r.statusCode == 200) {
      final Map a = jsonDecode(r.body);
      final status = a['data']?['attributes']?['status'];
      if (status == 'completed') {
        completed = true;
        break;
      }
    }
    tries++;
  }

  String urlId = base64Url.encode(utf8.encode(normalized)).replaceAll('=', '');
  final reportUri = Uri.parse('https://www.virustotal.com/api/v3/urls/$urlId');
  final reportResp = await http.get(reportUri, headers: {'x-apikey': VIRUSTOTAL_API_KEY});

  if (reportResp.statusCode != 200) {
    throw Exception('Failed to get VirusTotal URL report.');
  }

  final Map reportJson = jsonDecode(reportResp.body);
  final stats = reportJson['data']?['attributes']?['last_analysis_stats'] ?? {};

  final int malicious = (stats['malicious'] ?? 0) as int;
  final int suspicious = (stats['suspicious'] ?? 0) as int;
  final int harmless = (stats['harmless'] ?? 0) as int;
  final int undetected = (stats['undetected'] ?? 0) as int;

  final int total = malicious + suspicious + harmless + undetected;

  if (malicious > 0 || suspicious > 0) {
    return "⚠️ *Potential malicious URL detected!*\n$malicious engines flagged this URL as malicious.";
  } else {
    return "✅ URL appears clean. Scanned by $total engines.";
  }
}

}