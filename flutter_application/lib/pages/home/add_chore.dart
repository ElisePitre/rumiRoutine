/* Placeholder: Just to test that the button on the home screen works accordongly*/
import 'package:flutter/material.dart';

class AddChoreScreen extends StatelessWidget {
  const AddChoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Chore'),
      ),
      body: const Center(
        child: Text(
          'This is the Add Chore Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}