import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    final data = await ApiSerive.fetchUserProfile(widget.userId);
    setState(() {
      userProfile = data;
      isLoading = false;
    });
  }

  // void updateUserProfile() async {
  //   final success = await ApiSerive.updateUserProfile(widget.userId, {
  //     "name": "Updated Name",
  //     "age": userProfile?['age'] ?? 25,
  //   });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated!")));
      fetchUserProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            context.go('/');
          }
        },
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : userProfile == null
                  ? Text("Failed to load profile")
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Name: ${userProfile!['name']}", style: TextStyle(fontSize: 20)),
                        Text("Age: ${userProfile!['age']}", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: updateUserProfile,
                          child: Text("Update Profile"),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

// class ProfileScreen extends StatelessWidget {
//   final Map<String, dynamic> userProfile;

//   ProfileScreen({required this.userProfile});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Profile"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => context.go('/'),
//         ),
//       ),
//       body: GestureDetector(
//         onHorizontalDragEnd: (details) {
//           if (details.primaryVelocity! > 0) {
//             context.go('/');
//           }
//         },
//         child: Center(
//           child: Text("Name: ${userProfile['name']}, Age: ${userProfile['age']}"),
//         ),
//       ),
//     );
//   }
// }