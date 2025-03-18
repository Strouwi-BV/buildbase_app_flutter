import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HeaderBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showProfile;
  const HeaderBar({Key? key, this.showProfile = true}) : super(key: key);

  @override
  State<HeaderBar> createState() => _HeaderBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderBarState extends State<HeaderBar> {
  final _secureStorage = const FlutterSecureStorage();
  String? _profileImageUrl;
  String _userName = 'User Name';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await _loadUserName();
    await _loadProfileImage();
  }

  Future<void> _loadUserName() async {
    final firstName = await ApiService().getUserFirstName();
    final lastName = await ApiService().getUserLastName();
    setState(() {
      _userName =
          (firstName != null && lastName != null)
              ? '$firstName $lastName'
              : 'User Name';
    });
  }

  Future<void> _loadProfileImage() async {
    String? storedAvatar = await _secureStorage.read(key: 'avatarUrl');
    print('storedAvatar: $storedAvatar');
    if (storedAvatar != null) {
      setState(() {
        _profileImageUrl = storedAvatar;
      });
      return;
    }

    final avatarUrl = await ApiService().usersAvatarComplete();
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await _secureStorage.write(key: 'avatarUrl', value: avatarUrl);
      setState(() {
        _profileImageUrl = avatarUrl;
      });
    }
  }

  Future<void> _updateProfileImage() async {
    final newAvatarUrl = await ApiService().usersAvatarComplete();
    if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
      await _secureStorage.write(key: 'avatarUrl', value: newAvatarUrl);
      setState(() {
        _profileImageUrl = newAvatarUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xff13263B),
      iconTheme: const IconThemeData(color: Colors.white),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              String currentRoute = GoRouterState.of(context).matchedLocation;
              GoRouter.of(context).push('/menu', extra: currentRoute);
            },
          );
        },
      ),
      centerTitle: false,
      actions:
          widget.showProfile
              ? [
                Row(
                  children: [
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
                children: [
                  _buildProfileAvatar(),
                  const SizedBox(width: 4),
                  FutureBuilder<String?>(
                    future: ApiService().getUserEmail(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Laden...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      );
                    },
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
          _userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Future<void> _onMenuSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        GoRouter.of(context).go('/profile/1');
        break;
      case 1:
        GoRouter.of(
          context,
        ).push('/change-image').then((_) => _updateProfileImage());
        break;
      case 2:
        await ApiService().logout();
        GoRouter.of(context).push('/log-in');
        break;
    }
  }
}
