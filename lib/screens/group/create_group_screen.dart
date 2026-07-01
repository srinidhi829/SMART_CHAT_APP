import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() =>
      _CreateGroupScreenState();
}

class _CreateGroupScreenState
    extends State<CreateGroupScreen> {

final TextEditingController groupController =
TextEditingController();

final GroupService groupService =
GroupService();

final List<String> selectedMembers = [];

@override
void dispose() {
groupController.dispose();
super.dispose();
}

Future<void> createGroup() async {

if (groupController.text.trim().isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Enter group name",
),
),
);
return;
}

await groupService.createGroup(
groupName: groupController.text.trim(),
members: selectedMembers,
);

if (!mounted) return;

Navigator.pop(context);
}

@override
Widget build(BuildContext context) {
return Scaffold(

appBar: AppBar(
title: const Text("Create Group"),
),

floatingActionButton:
FloatingActionButton.extended(

onPressed: createGroup,

icon: const Icon(Icons.check),

label: const Text("Create"),

),

body: Column(

children: [

Padding(
padding: const EdgeInsets.all(15),

child: TextField(

controller: groupController,

decoration: const InputDecoration(

labelText: "Group Name",

border: OutlineInputBorder(),

),

),

),

const Divider(),

const Padding(

padding: EdgeInsets.all(12),

child: Align(

alignment: Alignment.centerLeft,

child: Text(

"Select Members",

style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),

),

),

),

Expanded(child: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
.collection("users")
.snapshots(),
builder: (context, snapshot) {

if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (!snapshot.hasData ||
snapshot.data!.docs.isEmpty) {
return const Center(
child: Text("No users found"),
);
}

final users = snapshot.data!.docs;

return ListView.builder(
itemCount: users.length,

itemBuilder: (context, index) {

final user =
users[index].data() as Map<String, dynamic>;

final uid = users[index].id;

return CheckboxListTile(

value: selectedMembers.contains(uid),

onChanged: (value) {

setState(() {

if (value == true) {

selectedMembers.add(uid);

} else {

selectedMembers.remove(uid);

}

});

},

secondary: CircleAvatar(

backgroundImage:
user["profileImage"] != null &&
user["profileImage"] != ""
? NetworkImage(
user["profileImage"],
)
: null,

child: user["profileImage"] == null ||
user["profileImage"] == ""
? const Icon(Icons.person)
: null,

),

title: Text(
user["name"] ?? "",
),

subtitle: Text(
user["email"] ?? "",
),

);

},

);

},

),          ),
],
),
);
}
}