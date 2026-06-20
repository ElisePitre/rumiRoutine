import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shell/app_shell.dart';
import '../../services/firestore_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String householdCode = '';
  //String uid = 'uid';

  Future<void> _showErrorDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login here',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 42, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 25, 
                        //fontWeight: FontWeight.bold,
                        color: Colors.grey
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 60, 4, 6),
                    child:TextFormField(
                      onChanged: (value) => email = value,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 18),
                    child: TextFormField(
                      onChanged: (value) => password = value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      obscureText: true,
                    ),
                    ),
                    //SizedBox(
                      //width: 15,
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              fixedSize: Size(100,45),
                              textStyle: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () async {
                              final trimmedEmail = email.trim();
                              final trimmedPassword = password.trim();

                              if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
                                await _showErrorDialog(
                                  'Missing Fields',
                                  'Please enter both email and password.',
                                );
                                return;
                              }

                              final result =
                                  await FirestoreService().login(trimmedEmail, trimmedPassword);
                              if (result != 'OK') {
                                await _showErrorDialog('Login Failed', result);
                                return;
                              }

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AppShell(),
                                ),
                              );
                            },
                            child: const Text('Login'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Don\'t have an account? \nSign up ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'here',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => getSignUpUI(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // textAlign: TextAlign.center,
                                // style: TextStyle(
                                //   color: Colors.grey
                                // ),
                              ),
                            ),
                            
                      ],
                      ),
                    ),
                    //),

                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
  Widget getSignUpUI() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign up here',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 42, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 18, 4, 18),
                    child: TextFormField(
                      onChanged: (value) => name = value,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 18),
                    child: TextFormField(
                      onChanged: (value) => email = value,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 18),
                    child: TextFormField(
                      onChanged: (value) => password = value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      obscureText: true,
                    ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 22),
                    child: TextFormField(
                      onChanged: (value) => confirmPassword = value,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      obscureText: true,
                    ),
                    ),
                    // Padding(
                    // padding: const EdgeInsets.only(bottom: 22),
                    // child: FilledButton(
                    //   style: FilledButton.styleFrom(
                    //     backgroundColor: Colors.black,
                    //     foregroundColor: Colors.white,
                    //     fixedSize: Size(230,45),
                    //   ),
                    //   onPressed: () {
                    //     Navigator.of(context).pushReplacement(
                    //       MaterialPageRoute<void>(
                    //         builder: (_) => const AppShell(),
                    //       ),
                    //     );
                    //   },
                    //   child: const Text('Create a New Household'), //TODO: where to go after new household??
                    //   ),
                    // ),
                    const Text(
                      textAlign: TextAlign.center,
                        'Enter a code to join an existing household, or one will be assigned to you',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.fromLTRB(60, 6, 60, 22),
                    child: TextFormField(
                      onChanged: (value) => householdCode = value,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Household Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    ),
                    Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        fixedSize: Size(230,45),
                        textStyle: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                            await _showErrorDialog(
                              'Missing Fields',
                              'Please fill in all fields.',
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            await _showErrorDialog(
                              'Password Mismatch',
                              'Passwords do not match.',
                            );
                            return;
                          }

                          final firestore = FirestoreService();
                          final joiningExistingHousehold = householdCode.isNotEmpty;

                          await firestore.signUp(
                            email,
                            password,
                            name,
                            joiningExistingHousehold ? householdCode : '',
                          );

                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser == null) {
                            throw StateError('Signed in user was not available after sign up.');
                          }

                          if (!joiningExistingHousehold) {
                            householdCode = await firestore.createHousehold(name);
                            await firestore.updateUserHouseholdId(
                              currentUser.uid,
                              householdCode,
                            );
                          }

                          await firestore.addMemberToHousehold(
                            householdCode,
                            currentUser.uid,
                          );

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const AppShell(),
                            ),
                          );
                        } catch (e) {
                          await _showErrorDialog(
                            'Sign Up Failed',
                            e.toString(),
                          );
                        }
                      },
                      child: const Text('Sign Up'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Already have an account? \nLogin ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: 'here',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => build(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                    padding: const EdgeInsets.fromLTRB(4, 60, 4, 6),
                    )
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
