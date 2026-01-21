import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:warungku_mobile/providers/auth_provider.dart';
import 'package:warungku_mobile/screens/edit_profile_screen.dart';
import 'package:warungku_mobile/screens/order_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // In a real app, you would upload the image to a server and get a URL.
      // For this example, we'll just use the local file path as a "URL".
      authProvider.updateProfileImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          ImageProvider<Object> backgroundImage;
          if (authProvider.userImageUrl != null && authProvider.userImageUrl!.startsWith('http')) {
            backgroundImage = NetworkImage(authProvider.userImageUrl!);
          } else if (authProvider.userImageUrl != null) {
            backgroundImage = FileImage(File(authProvider.userImageUrl!));
          } else {
            backgroundImage = NetworkImage('https://www.pngitem.com/pimgs/m/150-1503941_user-profile-default-image-png-clipart-png-download.png');
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                floating: false,
                backgroundColor: Theme.of(context).primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    authProvider.userName ?? 'Guest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://cdn.shopify.com/s/files/1/0070/7032/articles/Header_7512ee53-c680-44d7-abc2-21ef61095558.png?v=1764713881',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: backgroundImage,
                              child: authProvider.userImageUrl == null
                                  ? Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                      color: Colors.white.withOpacity(0.7),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.userEmail ?? '',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileMenu(context),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuCard(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profil',
            onTap: () {
              Navigator.of(context).pushNamed(EditProfileScreen.routeName);
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.history,
            title: 'Riwayat Pesanan',
            onTap: () {
              Navigator.of(context).pushNamed(OrderScreen.routeName);
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.exit_to_app,
            title: 'Logout',
            textColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      child: const Text('Tidak'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Ya'),
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Close dialog
                        Provider.of<AuthProvider>(context, listen: false)
                            .logout();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      Color? textColor}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title,
            style:
                TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}