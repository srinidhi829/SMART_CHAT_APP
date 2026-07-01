import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

final formKey = GlobalKey<FormState>();

late TextEditingController nameController;
late TextEditingController phoneController;
late TextEditingController aboutController;

final FirebaseFirestore firestore =
FirebaseFirestore.instance;

@override
void initState() {
super.initState();

nameController =
TextEditingController(text: widget.user["name"]);

phoneController =
TextEditingController(text: widget.user["phone"]);

aboutController =
TextEditingController(text: widget.user["about"]);
}  Future<void> updateProfile() async {
if (!formKey.currentState!.validate()) return;

await firestore
.collection("users")
.doc(widget.user["uid"])
.update({
"name": nameController.text.trim(),
"phone": phoneController.text.trim(),
"about": aboutController.text.trim(),
});

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Profile Updated Successfully"),
),
);

Navigator.pop(context);
}

@override
void dispose() {
nameController.dispose();
phoneController.dispose();
aboutController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Edit Profile"),
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Form(
key: formKey,

child: Column(
children: [

TextFormField(
controller: nameController,
decoration: const InputDecoration(
labelText: "Full Name",
prefixIcon: Icon(Icons.person),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Enter your name";
}
return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: phoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: "Phone Number",
prefixIcon: Icon(Icons.phone),
),
validator: (value) {
if (value == null || value.length != 10) {
return "Enter a valid phone number";
}
return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: aboutController,
maxLines: 3,
decoration: const InputDecoration(
labelText: "About",
prefixIcon: Icon(Icons.info_outline),
),
),

const SizedBox(height: 30),SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton.icon(
      onPressed: updateProfile,
      icon: const Icon(Icons.save),
      label: const Text(
        "Save Changes",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  ),

],
),
),
),
);
}
}