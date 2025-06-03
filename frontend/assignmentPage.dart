import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:main/addtaskPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://ypprpszogomrmpxgogvy.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM",
  );

  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const AssignmentPage());
  }
}

class AssignmentPage extends StatefulWidget {
  const AssignmentPage({super.key});

  @override
  _AssignmentPageState createState() => _AssignmentPageState();
}

class _AssignmentPageState extends State<AssignmentPage> {
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('assignments')
          .select()
          .order('due_date', ascending: true)
          .limit(100)
          .then((response) => response.cast<Map<String, dynamic>>());

      setState(() {
        _assignments = data;
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _errorMessage = 'Supabase error: ${e.message}';
        _isLoading = false;
      });
      debugPrint('Supabase Error: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching assignments: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching assignments: $e');
    }
  }

  Future<void> _deleteAssignment(int id) async {
    try {
      await Supabase.instance.client.from('assignments').delete().eq('id', id);
      _fetchAssignments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment deleted successfully!')),
      );
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete assignment: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  String _formatDueDate(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _getCollaboratorsText(dynamic collaboratorsData) {
    if (collaboratorsData == null) {
      return '';
    }
    if (collaboratorsData is String) {
      if (collaboratorsData.isEmpty) {
        return '';
      }
      try {
        final decoded = json.decode(collaboratorsData);
        if (decoded is List) {
          return decoded.join(', ');
        }
      } catch (e) {
        return collaboratorsData;
      }
    }
    if (collaboratorsData is List) {
      return collaboratorsData.join(', ');
    }
    return collaboratorsData.toString();
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
          'Assignments',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'custom'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                  'Assignment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'custom',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTaskPage(),
                      ),
                    );
                    _fetchAssignments();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0x99FFB20F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Add Task',
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
                    : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _assignments.isEmpty
                    ? const Center(
                      child: Text('No assignments found. Add a new task!'),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = _assignments[index];
                        final collaboratorsText = _getCollaboratorsText(
                          assignment['collaborators'],
                        );

                        return Dismissible(
                          key: Key(assignment['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Deletion"),
                                  content: Text(
                                    "Are you sure you want to delete this assignment?",
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            _deleteAssignment(assignment['id']);
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/image/book.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          assignment['subject'] ?? 'No Subject',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            fontFamily: 'custom',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          assignment['description'] ??
                                              'No Description',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'custom',
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Due: ${_formatDueDate(assignment['due_date'])}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'custom',
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        if (collaboratorsText.isNotEmpty)
                                          Text(
                                            'Collaborators: $collaboratorsText',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'custom',
                                              color: Colors.purple,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image(
                      image: AssetImage('assets/image/home.png'),
                      width: 48,
                      height: 48,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(fontFamily: 'custom', fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image(
                      image: AssetImage('assets/image/settings.png'),
                      width: 48,
                      height: 48,
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(fontFamily: 'custom', fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image(
                      image: AssetImage('assets/image/account_circle.png'),
                      width: 48,
                      height: 48,
                    ),
                    Text(
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
