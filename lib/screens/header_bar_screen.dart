import 'package:flutter/material.dart';
import '/screens/change_image_screen.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const HeaderBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xff13263B), // Terug naar de originele kleur
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: <Widget>[
        _buildProfileMenu(context),
      ],
      elevation: 4, // Schaduw effect
      shadowColor: Colors.black45, // Kleur van de schaduw
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Row(
        children: const [
          Icon(Icons.account_circle),
          SizedBox(width: 4),
          Icon(
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
                children: const [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150'), // Placeholder image
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Tom Peeters',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
        // Navigate to profile screen
        Navigator.of(context).pushNamed('/profile/1');
        break;
      case 1:
        // Navigate to change image screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ChangeImageScreen()),
        );
        break;
      case 2:
        // Handle logout
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out')),
        );
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
