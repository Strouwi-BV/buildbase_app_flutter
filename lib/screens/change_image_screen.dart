import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChangeImageScreen extends StatefulWidget {
  const ChangeImageScreen({Key? key}) : super(key: key);

  @override
  _ChangeImageScreenState createState() => _ChangeImageScreenState();
}

class _ChangeImageScreenState extends State<ChangeImageScreen> {
  String? _avatarUrl;
  File? _newImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final avatarUrl = await ApiService().usersAvatarComplete();
    if (avatarUrl != null) {
      setState(() {
        _avatarUrl = avatarUrl;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _newImage = imageFile;
      });
    }
  }

  Future<void> _postImage() async {
    await ApiService().usersAvatarPost(_newImage);
    const FlutterSecureStorage().write(key: 'avatarUrl', value: _avatarUrl);
    setState(() {
      _newImage = null;
    });
    _loadAvatar();
  }

  void _removeImage() async {
    await ApiService().deleteAvatar();
    setState(() {
      _avatarUrl = null;
      _newImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff13263B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            GoRouter.of(context).pop();
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
                  backgroundImage:
                      _newImage != null
                          ? FileImage(_newImage!)
                          : (_avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null),
                  child:
                      (_avatarUrl == null && _newImage == null)
                          ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                          : null,
                ),
                if (_avatarUrl != null && _newImage == null)
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
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
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
                    elevation: 5, // Subtiele schaduw
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 20), // Ruimte tussen de knoppen
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 24,
                  ),
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
                    elevation: 5, // Subtiele schaduw
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            if (_newImage != null) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      _postImage();
                    },
                    icon: const Icon(Icons.save, color: Colors.white, size: 24),
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
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _newImage = null;
                      });
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Annuleren',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5, // Subtiele schaduw
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
