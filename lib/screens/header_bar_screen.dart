import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';

class HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;
  final bool showProfile;

  const HeaderBar({Key? key, required this.userName, this.showProfile = true})
    : super(key: key);

  @override
  State<HeaderBar> createState() => _HeaderBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderBarState extends State<HeaderBar> {
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final avatarUrl = await ApiService().usersAvatarComplete();
    setState(() {
      _profileImageUrl = avatarUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xff13263B),
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          GoRouter.of(context).go('/menu');
        },
      ),
      centerTitle: false,
      actions:
          widget.showProfile
              ? [
                Row(
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildProfileMenu(context),
                  ],
                ),
              ]
              : null,
      elevation: 4,
      shadowColor: Colors.black45,
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Row(
        children: [
          _buildProfileAvatar(),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
      onSelected: (item) => _onMenuSelected(context, item),
      itemBuilder:
          (context) => [
            PopupMenuItem<int>(
              value: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(width: 8),
                      Text(
                        widget.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'tom.peeters@strouwi.be',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Icon(Icons.edit, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('WIJZIG AFBEELDING'),
                ],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('AFMELDEN'),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildProfileAvatar() {
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(_profileImageUrl!));
    } else {
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          widget.userName
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }
}

void _onMenuSelected(BuildContext context, int item) {
  switch (item) {
    case 0:
      Navigator.of(context).pushNamed('/profile/1');
      break;
    case 2:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out')));
      break;
  }
}
/*void _onMenuSelected(BuildContext context, int item) {
  switch (item) {
    case 0:
      Navigator.of(context).pushNamed('/profile/1');
      break;
    case 1:
      _updateProfileImage();
      break;
    case 2:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out')),
      );
      break;
  }
}

void _updateProfileImage() async {
  await _loadProfileImage(); // Profielfoto opnieuw ophalen van de server
}*/

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
          onPressed: () => Navigator.pop(context),
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
                  Navigator.pop(context);
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
