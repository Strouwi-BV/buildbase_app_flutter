import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/screens/change_image_screen.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const HeaderBar({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xff13263B),
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          GoRouter.of(context).go('/menu'); // Navigeer naar het menu
        },
      ),
      centerTitle: false,
      actions: [
        Row(
          children: [
            Text(
              userName,
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
      ],
      elevation: 4,
      shadowColor: Colors.black45,
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.grey,
          ),
        ],
      ),
      onSelected: (item) => _onMenuSelected(context, item),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('tom.peeters@strouwi.be',
                  style: TextStyle(color: Colors.grey)),
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

  void _onMenuSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.of(context).pushNamed('/profile/1');
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ChangeImageScreen()),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out')),
        );
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
