import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const noteFinal(
        noteTitle: "Default Note Title",
        subjectName: "Default Subject",
      ),
      theme: ThemeData(fontFamily: 'custom'),
    );
  }
}

class noteFinal extends StatefulWidget {
  final String noteTitle;
  final String subjectName;

  const noteFinal({
    super.key,
    required this.noteTitle,
    required this.subjectName,
  });

  @override
  _noteFinalState createState() => _noteFinalState();
}

class _noteFinalState extends State<noteFinal> {
  final TextEditingController _noteContentController = TextEditingController();
  final String _baseUrl = "http://127.0.0.1:8000";
  bool _isLoading = true;
  String _initialNoteContent = '';

  @override
  void initState() {
    super.initState();
    _fetchNoteContent();
  }

  @override
  void dispose() {
    _noteContentController.dispose();
    super.dispose();
  }

  Future<void> _fetchNoteContent() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notes?subject_name=${widget.subjectName}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> notesJson = json.decode(response.body);
        final note = notesJson.firstWhere(
          (n) =>
              n['notename'] == widget.noteTitle &&
              n['subject_name'] == widget.subjectName,
          orElse: () => null,
        );

        if (note != null) {
          setState(() {
            _initialNoteContent = note['notecontents'] ?? '';
            _noteContentController.text = _initialNoteContent;
          });
        } else {
          print(
            'Note not found for title: ${widget.noteTitle} and subject: ${widget.subjectName}',
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note not found.')));
        }
      } else {
        print('Failed to load notes: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notes from server: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching note content: $e');
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

  Future<void> _saveNoteContent() async {
    final String updatedContent = _noteContentController.text;
    if (updatedContent == _initialNoteContent) {
      print('Note content not changed. No save needed.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note content not changed.')),
      );
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notes/${widget.noteTitle}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject_name': widget.subjectName,
          'notecontents': updatedContent,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _initialNoteContent = updatedContent;
        });
        print('Note content saved successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully!')),
        );
      } else {
        print(
          'Failed to save note content. Status Code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error saving note content to backend: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _saveNoteContent();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNoteContent),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          widget.noteTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            fontFamily: 'custom',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _noteContentController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Start writing your notes here...',
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
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
