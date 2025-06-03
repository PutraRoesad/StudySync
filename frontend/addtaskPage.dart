import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:main/assignmentPage.dart'; 

void main() {
  runApp(
    DevicePreview(
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AddTaskPage(), 
    );
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _descriptionNameController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _dueTimeController = TextEditingController(); 
  final TextEditingController _collaboratorController = TextEditingController();

  Future<void> _addAssignment() async {
    final url = Uri.parse('http://127.0.0.1:8000/assignments');

    String fullDueDate = '';
    if (_dueDateController.text.isNotEmpty && _dueTimeController.text.isNotEmpty) {
      fullDueDate = '${_dueDateController.text}T${_dueTimeController.text}:00'; 
    } else if (_dueDateController.text.isNotEmpty) {
      fullDueDate = _dueDateController.text; 
    }


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subject': _subjectNameController.text,
          'description': _descriptionNameController.text,
          'due_date': fullDueDate, 
          'collaborators': _collaboratorController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment added successfully!')),
          );
        }
        _subjectNameController.clear();
        _descriptionNameController.clear();
        _dueDateController.clear();
        _dueTimeController.clear(); 
        _collaboratorController.clear();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AssignmentPage()),
          );
        }
      } else {
        String errorMessage = 'Failed to add assignment.';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['detail'] ?? errorMessage;
        } catch (e) {
          debugPrint('Error parsing error response: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMessage (Status: ${response.statusCode})')),
          );
        }
        debugPrint('Server response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during assignment submission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please check your network and try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _descriptionNameController.dispose();
    _dueDateController.dispose();
    _dueTimeController.dispose();
    _collaboratorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add New Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'custom',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset('assets/image/logo2.png', width: 180, height: 80),
                              Image.asset('assets/image/account_circle.png'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'Subject',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subjectNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'Enter the subject',
                      hintStyle: const TextStyle(fontFamily: 'custom'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionNameController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'Enter assignment description',
                      hintStyle: const TextStyle(fontFamily: 'custom'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Due Date',
                    style: TextStyle(fontSize: 16, fontFamily: 'custom'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dueDateController,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        _dueDateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'YYYY-MM-DD',
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Due Time', 
                    style: TextStyle(fontSize: 16, fontFamily: 'custom'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dueTimeController,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        _dueTimeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'HH:MM',
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add Collaborators',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _collaboratorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: 'Enter collaborators email(s) (comma-separated)',
                      hintStyle: const TextStyle(fontFamily: 'custom'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _addAssignment,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16),
                        backgroundColor: const Color(0x99FFB20F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'New Task',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'custom',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset('assets/image/home.png', width: 48, height: 48),
                    const Text('Home',
                    style: TextStyle(
                      fontFamily: 'custom',
                      fontSize: 16,
                    ),),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/settings.png', width: 48, height: 48),
                    const Text('Settings',
                    style: TextStyle(
                      fontFamily: 'custom',
                      fontSize: 16,
                    ),)
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/account_circle.png', width: 48, height: 48),
                    const Text('Profile',
                    style: TextStyle(
                      fontFamily: 'custom',
                      fontSize: 16,
                    ),)
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
