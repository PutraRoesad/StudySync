import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:device_preview/device_preview.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarView _calendarView = CalendarView.month;
  final CalendarController _calendarController = CalendarController();
  List<Appointment> _appointments = <Appointment>[];

  @override
  void initState() {
    super.initState();
    _initializeSupabaseAndFetchAssignments();
  }

  Future<void> _initializeSupabaseAndFetchAssignments() async {
    const supabaseUrl = 'https://ypprpszogomrmpxgogvy.supabase.co';
    const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwcHJwc3pvZ29tcm1weGdvZ3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0NzQ3NjcsImV4cCI6MjA1OTA1MDc2N30.4u1kMqYCPOsJ2-iy1wNOKyYoB3lAlRG7itmoL6TQCOM';

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      await _fetchAssignments();
    } catch (e) {
      print('Error initializing Supabase or fetching assignments: $e');
    }
  }

  Future<void> _fetchAssignments() async {
    try {
      final response = await Supabase.instance.client
          .from('assignments')
          .select('*')
          .order('due_date', ascending: true);

      final List<dynamic> assignmentsData = response as List<dynamic>;

      setState(() {
        _appointments = assignmentsData.map((data) {
          final String subject = data['subject'] as String;
          final String description = data['description'] as String;
          final String dueDateString = data['due_date'] as String;
          final DateTime dueDateTime = DateTime.parse(dueDateString);

          return Appointment(
            startTime: dueDateTime,
            endTime: dueDateTime.add(const Duration(hours: 1)),
            subject: subject,
            notes: description,
            isAllDay: false,
          );
        }).toList();
      });
    } catch (e) {
      print('Error fetching assignments: $e');
    }
  }

  void _toggleCalendarView() {
    setState(() {
      if (_calendarView == CalendarView.month) {
        _calendarView = CalendarView.week;
      } else {
        _calendarView = CalendarView.month;
      }
      _calendarController.view = _calendarView;
    });
  }

  void _addAppointment(String subject, String description, DateTime deadline) async {
    setState(() {
      _appointments.add(Appointment(
        startTime: deadline,
        endTime: deadline.add(const Duration(hours: 1)),
        subject: subject,
        notes: description,
        isAllDay: false,
      ));
    });
  }

  void _showAddAssignmentDialog(BuildContext context) {
    final TextEditingController _subjectController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _deadlineController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Assignment Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline (yyyy-MM-dd HH:mm)',
                  hintText: 'e.g., 2025-12-31 14:30',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final DateTime finalDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      _deadlineController.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _subjectController.dispose();
                _descriptionController.dispose();
                _deadlineController.dispose();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final deadline = DateFormat('yyyy-MM-dd HH:mm').parse(_deadlineController.text);
                  _addAppointment(_subjectController.text, _descriptionController.text, deadline);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid date format. Please use yyyy-MM-dd HH:mm')),
                  );
                } finally {
                  _subjectController.dispose();
                  _descriptionController.dispose();
                  _deadlineController.dispose();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
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
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  'Calendar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    fontFamily: 'custom',
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: _toggleCalendarView,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0x99FFB20F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showAddAssignmentDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0x99FFB20F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              view: _calendarView,
              controller: _calendarController,
              dataSource: AppointmentDataSource(_appointments),
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
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/settings.png', width: 48, height: 48),
                    const Text('Settings',
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
                    const Text('Profile',
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

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}