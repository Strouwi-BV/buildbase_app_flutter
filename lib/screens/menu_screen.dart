import 'package:flutter/material.dart';
import 'package:buildbase_app_flutter/main.dart'; // Zorg ervoor dat buildHeader en buildMenuItems zijn geïmporteerd

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff13263B),
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: Colors.white, width: 2)),
        backgroundColor: const Color(0xff13263B),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.network(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE9nfuUHODaRVxxYt52rm2NbDDOrCd-3_Z3w&s',
            height: 50,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[buildMenuItems(context)],
        ),
      ),
    );
  }
}
  /*
    final ImagePicker _picker = ImagePicker();

  
  Future<void> _pickAndUploadImage(ImageSource source) async {
    print('hello');
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final uploadedAvatarUrl = await ApiService().usersAvatarPost(imageFile);

      if (uploadedAvatarUrl != null) {
        setState(() {
          _avatarUrl = uploadedAvatarUrl;
        });
      }
    }
  }*/