import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'notessubpage.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const notefirst(),
      theme: ThemeData(fontFamily: 'custom'),
    );
  }
}

class Subject {
  String name;
  List<String> notes;
  Subject({required this.name, this.notes = const []});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(name: json['name']);
  }
}

class notefirst extends StatefulWidget {
  const notefirst({super.key});

  @override
  _notefirstState createState() => _notefirstState();
}

class _notefirstState extends State<notefirst> {
  final TextEditingController _subjectNameController = TextEditingController();
  List<Subject> _subjects = [];
  final String _baseUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubjects() async {
    final url = Uri.parse('$_baseUrl/subjects');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  Future<List<String>> _fetchNotesForSubjectPreview(String subjectName) async {
    final url = Uri.parse('$_baseUrl/notes?subject_name=$subjectName');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> notesJson = json.decode(response.body);
        return notesJson.map((json) => json['notename'] as String).toList();
      } else {
        print('Failed to fetch notes for preview: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notes for preview: $e');
      return [];
    }
  }

  Future<void> _addSubjectToBackend(String subjectName) async {
    final url = Uri.parse('$_baseUrl/subjects');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': subjectName}),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  Future<void> _deleteSubject(String subjectName) async {
    final url = Uri.parse('$_baseUrl/subjects/$subjectName');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Subject "$subjectName" deleted successfully!');
        _fetchSubjects();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subject "$subjectName" deleted successfully!'),
          ),
        );
      } else if (response.statusCode == 404) {
        print('Subject not found: $subjectName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject "$subjectName" not found.')),
        );
      } else if (response.statusCode == 400 &&
          response.body.contains("foreign key constraint")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot delete subject "$subjectName" because it has associated notes. Delete notes first.',
            ),
          ),
        );
      } else {
        print('Failed to delete subject: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete subject: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error deleting subject: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  void _confirmDeleteSubject(String subjectName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: Text(
            'Are you sure you want to delete the subject "$subjectName"? This will also delete all associated notes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSubject(subjectName);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
            controller: _subjectNameController,
            decoration: const InputDecoration(hintText: 'Enter subject name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _subjectNameController.clear();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (newSubjectName.isNotEmpty) {
                  await _addSubjectToBackend(newSubjectName);
                }
                Navigator.of(context).pop();
                _subjectNameController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey(subject.name),
        title: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => noteSub(subjectName: subject.name),
              ),
            );
          },
          child: Align(
            alignment: Alignment.centerLeft,
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
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
        children: <Widget>[
          FutureBuilder<List<String>>(
            future: _fetchNotesForSubjectPreview(subject.name),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error loading notes: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No notes available for this subject.'),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      snapshot.data!
                          .map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(
                                left: 45,
                                bottom: 8,
                                right: 16,
                              ),
                              child: Text(
                                '• $note',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            height: 1,
            color: Colors.grey.withOpacity(0.3),
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
        title: const Text(
          'Your Subjects',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            fontFamily: 'custom',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteSubjectSelectionDialog();
            },
          ),
        ],
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
                      Image.asset(
                        'assets/image/logo2.png',
                        width: 180,
                        height: 80,
                      ),
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
                  "SUBJECTS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'custom',
                  ),
                ),
                TextButton(
                  onPressed: _addSubject,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
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
            child:
                _subjects.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Column(
                        children:
                            _subjects
                                .map((subject) => _buildSubjectCard(subject))
                                .toList(),
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
                      style: TextStyle(fontFamily: 'custom', fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/image/settings.png',
                      width: 48,
                      height: 48,
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(fontFamily: 'custom', fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/image/account_circle.png',
                      width: 48,
                      height: 48,
                    ),
                    const Text(
                      'Profile',
                      style: TextStyle(fontFamily: 'custom', fontSize: 16),
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

  void _showDeleteSubjectSelectionDialog() {
    String? subjectToDelete;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: DropdownButtonFormField<String>(
            hint: const Text('Select a subject to delete'),
            value: subjectToDelete,
            onChanged: (String? newValue) {
              if (mounted) {
                setState(() {
                  subjectToDelete = newValue;
                });
              }
            },
            items:
                _subjects.map<DropdownMenuItem<String>>((Subject subject) {
                  return DropdownMenuItem<String>(
                    value: subject.name,
                    child: Text(subject.name),
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (subjectToDelete != null && subjectToDelete!.isNotEmpty) {
                  Navigator.pop(context);
                  _confirmDeleteSubject(subjectToDelete!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a subject to delete.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
