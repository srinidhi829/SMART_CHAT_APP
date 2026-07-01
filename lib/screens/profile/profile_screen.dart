import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'dart:io';
import '../../services/storage_service.dart';
import 'package:intl/intl.dart';
import '../settings/settings_screen.dart';
import '../home/home_screen.dart';
import '../group/group_screen.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

final FirebaseAuth auth = FirebaseAuth.instance;

final FirebaseFirestore firestore =
FirebaseFirestore.instance;
final StorageService storageService = StorageService();

File? profileImage;
Future<void> uploadImage() async {

  // Step 1: Pick an image from the gallery
  final image = await storageService.pickImage();

  // Step 2: If the user cancels, stop here
  if (image == null) return;

  // Step 3: Store the selected image locally
  setState(() {
    profileImage = image;
  });

  // Step 4: Get the current user's UID
  final uid = auth.currentUser!.uid;

  // Step 5: Upload the image to Firebase Storage
  final imageUrl =
  await storageService.uploadProfileImage(
    uid: uid,
    image: image,
  );

  // Step 6: Save the image URL in Firestore
  await firestore
      .collection("users")
      .doc(uid)
      .update({
    "profileImage": imageUrl,
  });

  // Step 7: Check if this widget is still mounted
  if (!mounted) return;

  // Step 8: Show a success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Profile picture updated successfully!",
      ),
    ),
  );
}
String formatLastSeen(dynamic timestamp, bool isOnline) {
  if (isOnline) {
    return "Online";
  }

  if (timestamp == null) {
    return "Offline";
  }

  final DateTime date =
  (timestamp as Timestamp).toDate();

  return "Last seen ${DateFormat("dd MMM yyyy, hh:mm a").format(date)}";
}
@override
Widget build(BuildContext context) {

final uid = auth.currentUser!.uid;

return Scaffold(
  bottomNavigationBar: NavigationBar(
    selectedIndex: 2,

    destinations: const [

      NavigationDestination(
        icon: Icon(Icons.chat),
        label: "Chats",
      ),

      NavigationDestination(
        icon: Icon(Icons.groups),
        label: "Groups",
      ),

      NavigationDestination(
        icon: Icon(Icons.person),
        label: "Profile",
      ),

    ],

    onDestinationSelected: (index) {

      switch (index) {

        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
          break;

        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const GroupsScreen(),
            ),
          );
          break;

        case 2:
          break;
      }
    },
  ),
  appBar: AppBar(
    title: const Text("Profile"),

    actions: [

      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          );
        },
      ),

    ],
  ),

body: StreamBuilder<DocumentSnapshot>(

stream: firestore
.collection("users")
.doc(uid)
.snapshots(),

builder: (context, snapshot) {

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
!snapshot.data!.exists) {
return const Center(
child: Text("User not found"),
);
}

final user =
snapshot.data!.data() as Map<String, dynamic>;

return SingleChildScrollView(

padding: const EdgeInsets.all(20),

child: Column(

children: [CircleAvatar(
radius: 60,
backgroundColor: Colors.blue.shade100,
child: const Icon(
Icons.person,
size: 70,
color: Colors.blue,
),
),

const SizedBox(height: 20),

Text(
user["name"] ?? "",
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

Text(
user["email"] ?? "",
style: const TextStyle(
color: Colors.grey,
fontSize: 16,
),
),

const SizedBox(height: 30),

Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: ListTile(
leading: const Icon(Icons.phone),
title: const Text("Phone"),
subtitle: Text(user["phone"] ?? ""),
),
),

const SizedBox(height: 15),

Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: ListTile(
leading: const Icon(Icons.info_outline),
title: const Text("About"),
subtitle: Text(
user["about"] ??
"Hey there! I'm using Smart Chat.",
),
),
),

const SizedBox(height: 15),

Card(
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: ListTile(
leading: Icon(
user["isOnline"] == true
? Icons.circle
: Icons.circle_outlined,
color: user["isOnline"] == true
? Colors.green
: Colors.grey,
),
title: const Text("Status"),
  subtitle: Text(
    formatLastSeen(
      user["lastSeen"],
      user["isOnline"] ?? false,
    ),
  ),
),
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          user: user,
        ),
      ),
    );
  },
icon: const Icon(Icons.edit),
label: const Text("Edit Profile"),
),
),

const SizedBox(height: 15),

SizedBox(
width: double.infinity,
height: 50,
child: OutlinedButton.icon(
onPressed: () {
// TODO:
// Upload Profile Picture
},
icon: const Icon(Icons.camera_alt),
label: const Text("Change Profile Picture"),
),
),const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton.icon(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
onPressed: () async {
await auth.signOut();

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
"/login",
(route) => false,
);
},
icon: const Icon(Icons.logout),
label: const Text("Logout"),
),
),

const SizedBox(height: 30),              ],
),
);
},
),
);
}

}