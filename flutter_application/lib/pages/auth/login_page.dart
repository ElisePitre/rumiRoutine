import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../shell/app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                          onPressed: () {
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
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const AppShell(), //TODO: where to go after sign up??
                          ),
                        );
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
