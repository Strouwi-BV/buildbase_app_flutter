// import 'package:buildbase_app_flutter/screens/header_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChangeImageScreen extends StatefulWidget {
  const ChangeImageScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wijzig Afbeelding',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff13263B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: _image == null
                ? const CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  )
                : CircleAvatar(
                    radius: 80,
                    backgroundImage: FileImage(_image!),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera),
                label: const Text('Maak foto'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload foto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
