import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
final _formKey = GlobalKey<FormState>();

final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController =
TextEditingController();
final AuthService authService = AuthService();
final FirestoreService firestoreService = FirestoreService();

bool hidePassword = true;
bool hideConfirmPassword = true;
bool acceptTerms = false;
bool isLoading = false;

@override
void dispose() {
nameController.dispose();
emailController.dispose();
phoneController.dispose();
passwordController.dispose();
confirmPasswordController.dispose();
super.dispose();
}

//------------------------------------
// Firebase Register
//------------------------------------

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    try {
      final credential = await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await firestoreService.saveUser(
        uid: credential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (!mounted) return;

      showSnackBar("Registration Successful");

      Navigator.pushReplacementNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "Registration failed");
    } catch (e) {
      showSnackBar(e.toString());
    }

    setState(() => isLoading = false);
  }

//------------------------------------

void registerButton() {
if (!_formKey.currentState!.validate()) return;

if (!acceptTerms) {
showSnackBar("Please accept Terms & Conditions");
return;
}

registerUser();
}

//------------------------------------

void showSnackBar(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
}

//------------------------------------

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xffF5F7FA),

appBar: AppBar(
elevation: 0,
backgroundColor: Colors.transparent,
),

body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(25),

child: Form(
key: _formKey,

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [

const Hero(
tag: "logo",
child: Icon(
Icons.chat_rounded,
size: 90,
color: Colors.blue,
),
),

const SizedBox(height: 20),

const Text(
"Create Account",
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
"Let's get started",
style: TextStyle(
color: Colors.grey,
fontSize: 16,
),
),

const SizedBox(height: 35),
TextFormField(
controller: nameController,
decoration: InputDecoration(
labelText: "Full Name",
prefixIcon: const Icon(Icons.person_outline),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Enter your full name";
}
if (value.trim().length < 3) {
return "Name must be at least 3 characters";
}
return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
decoration: InputDecoration(
labelText: "Email",
prefixIcon: const Icon(Icons.email_outlined),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return "Enter your email";
}

if (!RegExp(
r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
).hasMatch(value)) {
return "Enter a valid email";
}

return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: phoneController,
keyboardType: TextInputType.phone,
decoration: InputDecoration(
labelText: "Phone Number",
prefixIcon: const Icon(Icons.phone_outlined),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return "Enter your phone number";
}

if (value.length != 10) {
return "Enter a valid 10-digit phone number";
}

return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: passwordController,
obscureText: hidePassword,
decoration: InputDecoration(
labelText: "Password",
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(
icon: Icon(
hidePassword
? Icons.visibility_off
: Icons.visibility,
),
onPressed: () {
setState(() {
hidePassword = !hidePassword;
});
},
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
),
),
validator: (value) {
if (value == null || value.isEmpty) {
return "Enter password";
}

if (value.length < 6) {
return "Password must be at least 6 characters";
}

return null;
},
),

const SizedBox(height: 20),

TextFormField(
controller: confirmPasswordController,
obscureText: hideConfirmPassword,
decoration: InputDecoration(
labelText: "Confirm Password",
prefixIcon: const Icon(Icons.lock_reset),
suffixIcon: IconButton(
icon: Icon(
hideConfirmPassword
? Icons.visibility_off
: Icons.visibility,
),
onPressed: () {
setState(() {
hideConfirmPassword = !hideConfirmPassword;
});
},
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
),
),
validator: (value) {
if (value != passwordController.text) {
return "Passwords do not match";
}

return null;
},
),

const SizedBox(height: 20),
  Row(
    children: [
      Checkbox(
        value: acceptTerms,
        onChanged: (value) {
          setState(() {
            acceptTerms = value ?? false;
          });
        },
      ),
      const Expanded(
        child: Text(
          "I agree to the Terms & Conditions",
        ),
      ),
    ],
  ),

  const SizedBox(height: 20),

  SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      onPressed: isLoading ? null : registerButton,
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text(
        "CREATE ACCOUNT",
      ),
    ),
  ),

  const SizedBox(height: 20),

  SizedBox(
    width: double.infinity,
    height: 55,
    child: OutlinedButton(
      onPressed: () {
        // TODO Google Sign In
      },
      child: const Text(
        "Continue with Google",
      ),
    ),
  ),

  const SizedBox(height: 20),

  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text(
        "Already have an account?",
      ),
      TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(
            context,
            "/login",
          );
        },
        child: const Text(
          "Login",
        ),
      ),
    ],
  ),

  const SizedBox(height: 20),
],
),
),
),
),
);
}
}
