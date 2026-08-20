import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:loanready_app/providers/upload_photo_provider.dart';

class UploadPhotoScreen extends StatelessWidget {
  const UploadPhotoScreen({super.key});

  void _showImagePickerOptions(BuildContext context) {
    final provider = context.read<UploadPhotoProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 35),
                  onPressed: () {
                    Navigator.pop(context);
                    provider.pickImage(ImageSource.camera);
                  },
                ),
                const Text("Camera"),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library, size: 35),
                  onPressed: () {
                    Navigator.pop(context);
                    provider.pickImage(ImageSource.gallery);
                  },
                ),
                const Text("Gallery"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UploadPhotoProvider>();
    final isCaptured = provider.image != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Upload Photo"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: isCaptured ? 1.0 : 0.95,
                      backgroundColor: Colors.grey.shade300,
                      color: const Color(0xFF1A237E),
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCaptured ? "100%" : "95%",
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Profile Image Display
            CircleAvatar(
              radius: 65,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                isCaptured ? FileImage(provider.image!) : null,
                backgroundColor: const Color(0xFFEFEFEF),
                child: !isCaptured
                    ? const Icon(Icons.person, size: 70, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 25),

            // Capture / Retake Button
            ElevatedButton(
              onPressed: () => _showImagePickerOptions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002D72),
                padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCaptured ? 'Retake Photo' : 'Capture Photo',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCaptured
                        ? const Color(0xFF002D72)
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (isCaptured && !provider.isLoading)
                      ? () async {
                    final result = await provider.uploadProfilePic();
                    if (!context.mounted) return;

                    final isSuccess = result['success'] == true;
                    _showSnackBar(
                      context,
                      result['message'] ?? '',
                      isSuccess,
                    );

                    if (isSuccess) {
                      Navigator.pushNamed(context, '/choosePlan');
                    }
                  }
                      : null,
                  child: provider.isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}