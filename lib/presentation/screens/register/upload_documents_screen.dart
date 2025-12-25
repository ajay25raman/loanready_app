import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  String? panFile;
  String? aadhaarFile;
  String? shopLicense;
  String? gstCertificate;
  String? businessProof;

  // 🔍 Function: Extract text using ML Kit OCR
  Future<String?> extractTextFromImage(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  // 📂 Pick File + OCR extraction logic
  Future<void> pickFile(Function(String?) onPicked,
      {bool isPan = false, bool isAadhaar = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      onPicked(fileName);

      // Run OCR and extract number
      final extractedText = await extractTextFromImage(filePath);

      if (extractedText != null) {
        if (isPan) {
          final panRegex = RegExp(r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b');
          final match = panRegex.firstMatch(extractedText);
          if (match != null) {
            setState(() => _panController.text = match.group(0)!);
          }
        } else if (isAadhaar) {
          final aadhaarRegex = RegExp(r'\b\d{4}\s\d{4}\s\d{4}\b');
          final match = aadhaarRegex.firstMatch(extractedText);
          if (match != null) {
            setState(() => _aadhaarController.text = match.group(0)!);
          }
        }
      }
    }
  }

  Widget buildUploadTile(String title, String? fileName,
      Function(String?) onPicked, {
        bool isPan = false,
        bool isAadhaar = false,
      }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading:
        const Icon(Icons.insert_drive_file_outlined, color: Colors.grey),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: fileName != null
            ? Text(fileName, style: const TextStyle(fontSize: 12))
            : null,
        trailing: ElevatedButton(
          onPressed: () =>
              pickFile(onPicked, isPan: isPan, isAadhaar: isAadhaar),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF002D72),
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child:
          const Text('Upload', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 0.95,
              color: const Color(0xFF002D72),
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('95%',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 20),

            const Text('PAN Number*'),
            const SizedBox(height: 6),
            TextField(
              controller: _panController,
              decoration: InputDecoration(
                hintText: 'AAACH2702H',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildUploadTile(
              'Upload PAN (Only Front)',
              panFile,
                  (f) => setState(() => panFile = f),
              isPan: true,
            ),

            const SizedBox(height: 10),
            const Text('Aadhaar Number*'),
            const SizedBox(height: 6),
            TextField(
              controller: _aadhaarController,
              decoration: InputDecoration(
                hintText: '1234 5678 9012',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildUploadTile(
              'Upload Aadhaar (Front and Back)',
              aadhaarFile,
                  (f) => setState(() => aadhaarFile = f),
              isAadhaar: true,
            ),

            buildUploadTile('Shop License', shopLicense,
                    (f) => setState(() => shopLicense = f)),
            buildUploadTile('GST Certificate', gstCertificate,
                    (f) => setState(() => gstCertificate = f)),
            buildUploadTile('Business Proof (GST/Udyam)', businessProof,
                    (f) => setState(() => businessProof = f)),

            const SizedBox(height: 10),
            const Text(
              'Notes: “Accepted format: PNG, JPG (PDF not supported for auto-read)”.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                        Text('Documents Saved Successfully!')),
                  );
                  Navigator.pushNamed(context, '/uploadPhoto');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002D72),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
