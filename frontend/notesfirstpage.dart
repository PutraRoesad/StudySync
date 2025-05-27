import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'notessubpage.dart';

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
      home: const notefirst(),
      theme: ThemeData(
        fontFamily: 'custom',
      ),
    );
  }
}

class Subject {
  String name;
  List<String> notes;

  Subject({required this.name, this.notes = const []});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
    );
  }
}

class notefirst extends StatefulWidget {
  const notefirst({super.key});

  @override
  _notefirstState createState() => _notefirstState();
}

class _notefirstState extends State<notefirst> {
  final TextEditingController _subjectName = TextEditingController();
  List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final url = Uri.parse('http://127.0.0.1:8000/subjects');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _subjects = jsonList.map((json) => Subject.fromJson(json)).toList();
        });
        print('Subjects fetched successfully: ${_subjects.length}');
      } else {
        print('Failed to fetch subjects. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch subjects: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error fetching subjects from backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> _addSubjectToBackend(String subjectName) async {
    final url = Uri.parse('http://127.0.0.1:8000/subjects');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': subjectName,
        }),
      );

      if (response.statusCode == 200) {
        print('Subject added successfully to backend');
        _fetchSubjects();
      } else {
        print('Failed to add subject. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add subject: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error sending subject to backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  void _addSubject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newSubjectName = '';
        return AlertDialog(
          title: const Text('Add New Subject'),
          content: TextField(
            onChanged: (value) {
              newSubjectName = value;
            },
            controller: _subjectName,
            decoration: const InputDecoration(hintText: 'Enter subject name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (newSubjectName.isNotEmpty) {
                  await _addSubjectToBackend(newSubjectName);
                }
                Navigator.of(context).pop();
                _subjectName.clear();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => noteSub(subjectName: subject.name),
                    ),
                  );
                },
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'custom',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16),
          height: 1,
          color: Colors.grey,
        ),
        if (subject.notes.isNotEmpty)
          ...subject.notes.take(3).map((note) => _buildNoteItemPreview(note, 'Date N/A')).toList(),
      ],
    );
  }

  Widget _buildNoteItemPreview(String noteName, String createdDate) {
    return Container(
      margin: const EdgeInsets.only(left: 45, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            noteName,
            style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'custom'),
          ),
          Text(
            "CREATED: $createdDate",
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'custom'),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8),
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
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
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
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
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "NOTES",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'custom',
                  ),
                ),
                TextButton(
                  onPressed: _addSubject,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    backgroundColor: const Color(0x99FFB20F),
                  ),
                  child: const Text(
                    'Add Subject',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'custom',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _subjects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: _subjects.map((subject) => _buildSubjectCard(subject)).toList(),
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
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontFamily: 'custom',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/settings.png', width: 48, height: 48),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'custom',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/account_circle.png', width: 48, height: 48),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: 'custom',
                        fontSize: 16,
                      ),
                    ),
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