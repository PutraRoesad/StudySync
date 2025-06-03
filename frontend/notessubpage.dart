import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:main/login.dart';
import 'notesfinalpage.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const noteSub(subjectName: "Sample Subject"),
      theme: ThemeData(fontFamily: 'custom'),
    );
  }
}

class Note {
  String title;
  String createdDate;
  String subjectName;

  Note({
    required this.title,
    required this.createdDate,
    required this.subjectName,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['notename'],
      createdDate: json['created_at'],
      subjectName: json['subject_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notename': title,
      'created_at': createdDate,
      'notecontents': '',
      'subject_name': subjectName,
    };
  }
}

class noteSub extends StatefulWidget {
  final String subjectName;

  const noteSub({super.key, required this.subjectName});

  @override
  _noteSubState createState() => _noteSubState();
}

class _noteSubState extends State<noteSub> {
  List<Note> _notes = [];
  bool _isLoading = true;

  final String _baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    _fetchNotesForSubject();
  }

  Future<void> _fetchNotesForSubject() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse(
        '$_baseUrl/notes?subject_name=${widget.subjectName}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> notesJson = json.decode(response.body);
        setState(() {
          _notes = notesJson.map((json) => Note.fromJson(json)).toList();
        });
      } else {
        print('Failed to load notes: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notes from server: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching notes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Could not connect to the server: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNoteToBackend(String newNoteTitle) async {
    final newNote = Note(
      title: newNoteTitle,
      createdDate:
          DateTime.now().day.toString().padLeft(2, '0') +
          '/' +
          DateTime.now().month.toString().padLeft(2, '0') +
          '/' +
          DateTime.now().year.toString(),
      subjectName: widget.subjectName,
    );

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newNote.toJson()),
      );

      if (response.statusCode == 200) {
        print('Note added successfully to backend');
        _fetchNotesForSubject();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully!')),
        );
      } else {
        print('Failed to add note. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add note: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error sending note to backend: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  Future<void> _deleteNoteFromBackend(
    String noteTitle,
    String subjectName,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/notes/$noteTitle?subject_name=$subjectName',
      );
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Note deleted successfully from backend');
        _fetchNotesForSubject();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted successfully!')),
        );
      } else if (response.statusCode == 404) {
        print('Note not found for deletion: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note not found: ${response.body}')),
        );
      } else {
        print('Failed to delete note. Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete note: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error deleting note from backend: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newNoteTitle = '';
        return AlertDialog(
          title: const Text('Add New Note'),
          content: TextField(
            onChanged: (value) {
              newNoteTitle = value;
            },
            decoration: const InputDecoration(hintText: 'Enter note title'),
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
                if (newNoteTitle.isNotEmpty) {
                  await _addNoteToBackend(newNoteTitle);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteItem(Note note) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => noteFinal(
                  noteTitle: note.title,
                  subjectName: note.subjectName,
                ),
          ),
        );
      },
      child: Dismissible(
        key: Key(note.title + note.subjectName),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Deletion"),
                content: Text(
                  "Are you sure you want to delete '${note.title}'?",
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Delete"),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) {
          _deleteNoteFromBackend(note.title, note.subjectName);
        },
        child: Container(
          margin: const EdgeInsets.only(left: 45, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'custom',
                ),
              ),
              Text(
                "CREATED: ${note.createdDate}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'custom',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                height: 1,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subjectName,
          style: const TextStyle(fontFamily: 'custom'),
        ),
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
              padding: const EdgeInsets.only(left: 16, right: 16),
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
                Text(
                  widget.subjectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'custom',
                  ),
                ),
                TextButton(
                  onPressed: _addNote,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0x99FFB20F),
                  ),
                  child: const Text(
                    'Add Notes',
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _notes.isEmpty
                    ? Center(
                      child: Text(
                        'No notes found for ${widget.subjectName}. Add some!',
                      ),
                    )
                    : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return _buildNoteItem(note);
                      },
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
}
