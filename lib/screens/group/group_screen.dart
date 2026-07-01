import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home_screen.dart';
import '../../services/group_service.dart';
import 'create_group_screen.dart';
import 'group_chat_screen.dart';
import '../chat/chats_screen.dart';
import '../profile/profile_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() =>
      _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {

final GroupService groupService =
GroupService();

@override
Widget build(BuildContext context) {
return Scaffold(

appBar: AppBar(
title: const Text("Groups"),
),

floatingActionButton:
FloatingActionButton(

child: const Icon(Icons.group_add),

onPressed: () {

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const CreateGroupScreen(),
),
);

},

),
  bottomNavigationBar: NavigationBar(
    selectedIndex: 1,

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

body: StreamBuilder<QuerySnapshot>(

stream: groupService.getGroups(),

builder: (context, snapshot) {

if (snapshot.connectionState ==
ConnectionState.waiting) {

return const Center(
child:
CircularProgressIndicator(),
);

}

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {

return const Center(
child: Text(
"No Groups Found",
),
);

}

final groups =
snapshot.data!.docs;

return ListView.builder(

itemCount: groups.length,

itemBuilder: (context, index) {

final group =
groups[index].data()
as Map<String, dynamic>;
return Card(
margin: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 6,
),

child: ListTile(

leading: CircleAvatar(
radius: 25,
backgroundColor: Colors.blue.shade100,

backgroundImage:
group["groupImage"] != null &&
group["groupImage"] != ""
? NetworkImage(
group["groupImage"],
)
: null,

child: group["groupImage"] == null ||
group["groupImage"] == ""
? const Icon(
Icons.groups,
color: Colors.blue,
)
: null,
),

title: Text(
group["groupName"] ?? "",
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 17,
),
),

subtitle: Text(
"${(group["members"] as List).length} Members",
),

trailing: const Icon(
Icons.arrow_forward_ios,
size: 18,
),

onTap: () {

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => GroupChatScreen(
groupId: group["groupId"],
groupName:
group["groupName"],
),
),
);

},

),
);
},
);
},
),
);
}
}