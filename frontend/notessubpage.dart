import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:main/login.dart';
import 'notesfinalpage.dart';

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
      home: const noteSub(subjectName: "Sample Subject"),
      theme: ThemeData(
        fontFamily: 'custom',
      ),
    );
  }
}

class Note {
  String title;
  String createdDate;

  Note({required this.title, required this.createdDate});
}

class noteSub extends StatefulWidget {
  final String subjectName;

  const noteSub({super.key, required this.subjectName});

  @override
  _noteSubState createState() => _noteSubState();
}

class _noteSubState extends State<noteSub> {
  final List<Note> _notes = [
    Note(title: 'Note 1', createdDate: '28/01/2025'),
    Note(title: 'Note 2', createdDate: '28/01/2025'),
  ];

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
              onPressed: () {
                if (newNoteTitle.isNotEmpty) {
                  setState(() {
                    _notes.add(
                      Note(
                        title: newNoteTitle,
                        createdDate: DateTime.now().day.toString().padLeft(2, '0') +
                            '/' +
                            DateTime.now().month.toString().padLeft(2, '0') +
                            '/' +
                            DateTime.now().year.toString(),
                      ),
                    );
                  });
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
          MaterialPageRoute(builder: (context) => noteFinal(noteTitle: note.title)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 45, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'custom'),
            ),
            Text(
              "CREATED: ${note.createdDate}",
              style: const TextStyle(fontSize: 14, color: Colors.grey, fontFamily: 'custom'),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8),
              height: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName, style: const TextStyle(fontFamily: 'custom')),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _notes.map((note) => _buildNoteItem(note)).toList(),
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