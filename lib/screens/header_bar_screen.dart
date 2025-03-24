import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:buildbase_app_flutter/service/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showProfile;
  const HeaderBar({Key? key, this.showProfile = true}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
          showProfile
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
                  const SizedBox(height: 4),
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
    const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    return FutureBuilder<String?>(
      future: _secureStorage.read(key: 'avatarUrl').then((storedAvatar) async {
        if (storedAvatar != null) {
          print('pijl');
          return storedAvatar;
        }
        return null;
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          );
        }

        final avatarUrl = snapshot.data;
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          return CircleAvatar(backgroundImage: NetworkImage(avatarUrl));
        } else {
          return CircleAvatar(
            backgroundColor: Colors.blue,
            child: FutureBuilder<String?>(
              future: _getUserInitials(),
              builder: (context, initialsSnapshot) {
                return Text(
                  initialsSnapshot.data ?? '?',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<String> _getUserInitials() async {
    final firstName = await ApiService().getUserFirstName();
    final lastName = await ApiService().getUserLastName();
    if (firstName != null && lastName != null) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return '?';
  }

  Future<void> _onMenuSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        GoRouter.of(context).go('/profile/1');
        break;
      case 1:
        GoRouter.of(context).push('/change-image');
        break;
      case 2:
        await ApiService().logout();
        GoRouter.of(context).push('/log-in');
        break;
    }
  }
}
