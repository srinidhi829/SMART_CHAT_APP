import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final _formKey = GlobalKey<FormState>();

final TextEditingController emailController =
TextEditingController();


final TextEditingController passwordController =
TextEditingController();
final AuthService authService = AuthService();

bool hidePassword = true;

bool rememberMe = false;

bool isLoading = false;

@override
void dispose() {
emailController.dispose();
passwordController.dispose();
super.dispose();
}

//---------------------------------------
// Firebase Login
//---------------------------------------

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "Login failed");
    }

    setState(() {
      isLoading = false;
    });
  }

//---------------------------------------

void loginButton() {
if (_formKey.currentState!.validate()) {
loginUser();
}
}

//---------------------------------------



//---------------------------------------

void showSnackBar(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
),
);
}

//---------------------------------------

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
crossAxisAlignment:
CrossAxisAlignment.start,

children: [

const SizedBox(height: 20),

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
"Welcome Back 👋",

style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

const Text(
"Login to continue chatting",

style: TextStyle(
color: Colors.grey,
fontSize: 16,
),
),

const SizedBox(height: 40),
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
return "Minimum 6 characters";
}

return null;
},
),

const SizedBox(height: 15),

Row(
children: [

Checkbox(
value: rememberMe,
onChanged: (value) {
setState(() {
rememberMe = value!;
});
},
),

const Text(
"Remember Me",
),

const Spacer(),

TextButton(
onPressed: () {
Navigator.pushNamed(
context,
"/forgot",
);
},
child: const Text(
"Forgot Password?",
),
),
],
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: isLoading
? null
: loginButton,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
),
child: isLoading
? const SizedBox(
width: 25,
height: 25,
child:
CircularProgressIndicator(
color: Colors.white,
),
)
: const Text(
"LOGIN",
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
  ),
),
),
),



const SizedBox(height: 35),

Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [

const Text(
"Don't have an account?",
),

TextButton(
onPressed: () {
Navigator.pushReplacementNamed(
context,
"/register",
);
},
child: const Text(
"Register",
),
),
],
),
  ],
),
),
),
),
);
}
}