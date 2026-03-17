/* Placeholder: Just to test that the chores on the home screen work accordongly*/
import 'package:flutter/material.dart';

class EditChoreScreen extends StatelessWidget {
  const EditChoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Chore'),
      ),
      body: const Center(
        child: Text(
          'This is the Edit Chore Screen',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}