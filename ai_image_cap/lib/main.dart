import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CaptionGenieApp());
}

class CaptionGenieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaptionGenie',
      theme: ThemeData.dark(useMaterial3: true),
      home: CaptionHome(),
    );
  }
}

class CaptionHome extends StatefulWidget {
  @override
  _CaptionHomeState createState() => _CaptionHomeState();
}

class _CaptionHomeState extends State<CaptionHome> {
  Uint8List? imageBytes;
  String? caption;
  bool loading = false;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        imageBytes = result.files.single.bytes;
        caption = null;
      });
    }
  }

  Future<void> generateCaption() async {
    if (imageBytes == null) return;
    setState(() => loading = true);

    // Example: Call Hugging Face Inference API (replace with your token)
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/nlpconnect/vit-gpt2-image-captioning'),
      headers: {
        'Authorization': 'Bearer ...',
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() => caption = result[0]['generated_text']);
    } else {
       print("Error: ${response.statusCode}");
        print("Body: ${response.body}");
        setState(() => caption = 'Failed to generate caption. (${response.statusCode})');
      }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade900, Colors.blue.shade600])),
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("🧠 CaptionGenie", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)).animate().fadeIn(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: Text("Upload Image"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            ),
            const SizedBox(height: 20),
            if (imageBytes != null) ...[
              Image.memory(imageBytes!, width: 300).animate().scale(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: generateCaption,
                child: loading ? CircularProgressIndicator() : Text("Generate Caption"),
              ),
              const SizedBox(height: 10),
              if (caption != null)
                Text(caption!, style: TextStyle(fontSize: 18)).animate().fadeIn(duration: 1000.ms),
            ]
          ]),
        ),
      ),
    );
  }
}
