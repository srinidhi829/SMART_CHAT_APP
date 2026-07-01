import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: ListView(
        children: [

          // ==========================
          // EDIT PROFILE
          // ==========================
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    user: {
                      "uid": FirebaseAuth.instance.currentUser!.uid,
                      "name": "",
                      "phone": "",
                      "about": "",
                    },
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // ==========================
          // CHANGE PASSWORD
          // ==========================
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // ==========================
          // NOTIFICATIONS
          // ==========================
          SwitchListTile(
            value: notificationsEnabled,
            secondary: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? "Notifications Enabled"
                        : "Notifications Disabled",
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // ==========================
          // CLEAR CHAT HISTORY
          // ==========================
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Clear Chat History"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear Chats"),
                  content: const Text(
                    "This feature will be available in the next update.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          // ==========================
          // ABOUT
          // ==========================
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            subtitle: const Text("Smart Chat v1.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Smart Chat",
                applicationVersion: "1.0",
                applicationLegalese:
                "Developed using Flutter & Firebase",
              );
            },
          ),

          const Divider(),

          // ==========================
          // LOGOUT
          // ==========================
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {

              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text(
                    "Are you sure you want to logout?",
                  ),
                  actions: [

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text("Cancel"),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text("Logout"),
                    ),

                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                }
              }
            },
          ),

        ],
      ),
    );
  }
}