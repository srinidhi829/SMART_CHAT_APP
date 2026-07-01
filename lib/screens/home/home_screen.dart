import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/user_status_service.dart';
import 'package:intl/intl.dart';
import '../group/group_screen.dart';
import '../chat/chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final UserStatusService statusService =
UserStatusService();
final TextEditingController searchController =
TextEditingController();


String searchText = "";

String formatLastSeen(dynamic timestamp, bool isOnline) {
  if (isOnline) return "Online";

  if (timestamp == null) {
    return "Offline";
  }

  final date = (timestamp as Timestamp).toDate();

  return "Last seen ${DateFormat("hh:mm a").format(date)}";
}
@override
void dispose() {

  statusService.setOffline();

  searchController.dispose();

  super.dispose();
}
@override
void initState() {
  super.initState();

  statusService.setOnline();
}

Future<void> logout() async {
  await statusService.setOffline();

  await auth.signOut();

if (!mounted) return;

Navigator.pushReplacementNamed(
context,
"/login",
);
}

@override
Widget build(BuildContext context) {
  return PopScope(
      canPop: false,
      child: Scaffold(

backgroundColor: const Color(0xffF5F7FA),

appBar: AppBar(
  automaticallyImplyLeading: false,

elevation: 0,

backgroundColor: Colors.white,

title: const Text(

"Smart Chat",
style: TextStyle(
color: Colors.black,
fontWeight: FontWeight.bold,
),
),

),

  floatingActionButton: FloatingActionButton(
    onPressed: () {
      searchController.clear();

      setState(() {
        searchText = "";
      });
    },
    child: const Icon(Icons.chat),
  ),

body: Column(

children: [

Padding(

padding: const EdgeInsets.all(15),

child: TextField(

controller: searchController,

onChanged: (value) {

setState(() {

searchText = value.toLowerCase();

});

},

decoration: InputDecoration(

hintText: "Search users...",

prefixIcon: const Icon(Icons.search),

border: OutlineInputBorder(

borderRadius:
BorderRadius.circular(15),

),

),

),

),

Expanded(child: StreamBuilder<QuerySnapshot>(
stream: firestore.collection("users").snapshots(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return const Center(
child: Text("Something went wrong"),
);
}

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {
return const Center(
child: Text(
"No users found",
style: TextStyle(fontSize: 18),
),
);
}

  final users = snapshot.data!.docs.where((doc) {

  final data =
  doc.data() as Map<String, dynamic>;

  final name =
  (data["name"] ?? "")
      .toString()
      .toLowerCase();

  final email =
  (data["email"] ?? "")
      .toString()
      .toLowerCase();

  return name.contains(searchText) ||
  email.contains(searchText);

  }).toList();

return ListView.builder(
itemCount: users.length,

itemBuilder: (context, index) {

final user =
users[index].data() as Map<String, dynamic>;

if (user["uid"] ==
auth.currentUser?.uid) {
return const SizedBox();
}

return Card(
margin: const EdgeInsets.symmetric(
horizontal: 15,
vertical: 8,
),

elevation: 2,

shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),

child: ListTile(

leading: Stack(
children: [

const CircleAvatar(
radius: 28,
child: Icon(
Icons.person,
size: 30,
),
),

Positioned(
bottom: 0,
right: 0,
child: Container(
height: 14,
width: 14,
decoration: BoxDecoration(
color: user["isOnline"] == true
? Colors.green
: Colors.grey,
shape: BoxShape.circle,
border: Border.all(
color: Colors.white,
width: 2,
),
),
),
),
],
),

title: Text(
user["name"] ?? "",
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),

  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        user["about"] ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      const SizedBox(height: 4),

      Text(
        formatLastSeen(
          user["lastSeen"],
          user["isOnline"] ?? false,
        ),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),

    ],
  ),

trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: user["uid"],
          receiverName: user["name"],
        ),
      ),
    );
  },

),
);
},
);
},
),          ),
],
),

        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,

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
              // Already on Home
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
                break;
            }
          },
        ),
      ),
);
}
}