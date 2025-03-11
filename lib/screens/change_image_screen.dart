import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeImageScreen extends StatefulWidget {
  final VoidCallback onImageChanged;

  const ChangeImageScreen({Key? key, required this.onImageChanged})
    : super(key: key);

  @override
  _ChangeImageScreenState createState() => _ChangeImageScreenState();
}

class _ChangeImageScreenState extends State<ChangeImageScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImage(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);
    final savedImage = await image.copy('${appDir.path}/$fileName');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', savedImage.path);
    widget.onImageChanged();
  }

  void _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImagePath');
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
      await prefs.remove('profileImagePath');
    }

    setState(() {
      _image = null;
    });
    widget.onImageChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff13263B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).pop(); // Gebruik GoRouter voor navigatie
          },
        ),
        title: const Text(
          'Wijzig Profielfoto',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child:
                      _image == null
                          ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                          : null,
                ),
                if (_image != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    'Maak foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff13263B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text(
                    'Upload foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff13263B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
            if (_image != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await _saveImage(_image!);
                  GoRouter.of(context).pop(); // Gebruik GoRouter voor navigatie
                },
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Opslaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
