import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:main/assignmentPage.dart';
import 'package:main/calendarFirst.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notesfirstpage.dart';
import 'package:main/addtaskPage.dart';
import 'package:intl/intl.dart';

void main() async {
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
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const HomePage(),
      theme: ThemeData(fontFamily: 'custom'),
    );
  }
}

class Assignment {
  final String id;
  final String subject;
  final String? description;
  final DateTime dueDate;
  // Removed final List<String>? collaborators; as it's not needed for display on this page.

  Assignment({
    required this.id,
    required this.subject,
    this.description,
    required this.dueDate,
    // this.collaborators, // Removed from constructor
  });

  String get formattedDueTime {
    return DateFormat.jm().format(dueDate);
  }

  factory Assignment.fromMap(Map<String, dynamic> data) {
    // No need to parse 'collaborators' if not used.
    // The previous parsing logic for collaborators is removed.

    return Assignment(
      id: data['id'].toString(),
      subject: data['subject'] as String,
      description: data['description'] as String?,
      dueDate: DateTime.parse(data['due_date'] as String),
      // collaborators: parsedCollaborators, // No longer assigned
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Assignment> _allAssignments = [];
  DateTime? _selectedDate;
  bool _isLoadingAssignments = true;
  String _assignmentsErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() {
      _isLoadingAssignments = true;
      _assignmentsErrorMessage = '';
      _allAssignments = [];
    });

    try {
      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('assignments')
          .select('id, subject, description, due_date')
          .order('due_date', ascending: true);

      setState(() {
        _allAssignments = data.map((item) => Assignment.fromMap(item)).toList();
        _isLoadingAssignments = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _assignmentsErrorMessage =
            'Supabase error fetching assignments: ${e.message}';
        _isLoadingAssignments = false;
      });
      debugPrint('Supabase Error (HomePage): ${e.message}');
    } catch (e) {
      setState(() {
        _assignmentsErrorMessage = 'An unexpected error occurred: $e';
        _isLoadingAssignments = false;
      });
      debugPrint('Error fetching assignments (HomePage): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 32),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WEEKLY OVERVIEW",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'custom',
                      color: Colors.black87,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          _isLoadingAssignments
                              ? const Center(child: CircularProgressIndicator())
                              : _assignmentsErrorMessage.isNotEmpty
                              ? Center(child: Text(_assignmentsErrorMessage))
                              : _buildWeeklyCalendar(),
                          if (_selectedDate != null)
                            _buildAssignmentsForSelectedDate(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "QUICK ACCESS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'custom',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildFeatureButton(
                    title: "Notes",
                    icon: Icons.book,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const notefirst(),
                        ),
                      );
                    },
                    color: const Color(0x99FFB20F),
                  ),
                  _buildFeatureButton(
                    title: "Assignments",
                    icon: Icons.assignment,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssignmentPage(),
                        ),
                      );
                      _fetchAssignments();
                    },
                    color: Colors.lightBlue.shade300,
                  ),
                  _buildFeatureButton(
                    title: "Calendar",
                    icon: Icons.calendar_today,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarPage(),
                        ),
                      );
                    },
                    color: Colors.lightGreen.shade300,
                  ),
                  const SizedBox(height: 30),
                  // Removed "DAILY MOTIVATION" Text
                  // Removed _buildMotivationCard calls
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

  Widget _buildFeatureButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'custom',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildMotivationCard function

  Widget _buildWeeklyCalendar() {
    final DateTime now = DateTime.now();
    final int currentWeekday = now.weekday;

    DateTime mondayOfThisWeek = now.subtract(
      Duration(days: currentWeekday - 1),
    );

    List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<Widget> dayWidgets = [];

    for (int i = 0; i < 7; i++) {
      DateTime day = mondayOfThisWeek.add(Duration(days: i));
      bool isToday =
          day.day == now.day && day.month == now.month && day.year == now.year;
      bool isSelected =
          _selectedDate != null &&
          _selectedDate!.day == day.day &&
          _selectedDate!.month == day.month &&
          _selectedDate!.year == day.year;

      bool hasAssignments = _allAssignments.any(
        (assignment) =>
            assignment.dueDate.year == day.year &&
            assignment.dueDate.month == day.month &&
            assignment.dueDate.day == day.day,
      );

      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: Column(
              children: [
                Text(
                  dayNames[i],
                  style: TextStyle(
                    fontFamily: 'custom',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isToday
                            ? const Color(0x99FFB20F)
                            : (isSelected
                                ? Colors.blue.shade100
                                : (hasAssignments
                                    ? Colors.orange.shade100
                                    : Colors.transparent)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontFamily: 'custom',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isToday
                              ? Colors.white
                              : (isSelected
                                  ? Colors.blue.shade900
                                  : (hasAssignments
                                      ? Colors.orange.shade900
                                      : Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildAssignmentsForSelectedDate() {
    if (_selectedDate == null) {
      return const SizedBox.shrink();
    }

    final List<Assignment> assignmentsOnSelectedDate =
        _allAssignments
            .where(
              (assignment) =>
                  assignment.dueDate.year == _selectedDate!.year &&
                  assignment.dueDate.month == _selectedDate!.month &&
                  assignment.dueDate.day == _selectedDate!.day,
            )
            .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assignmentsOnSelectedDate.isEmpty)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "No assignments due on this day.",
                style: TextStyle(
                  fontFamily: 'custom',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assignmentsOnSelectedDate.length,
              itemBuilder: (context, index) {
                final assignment = assignmentsOnSelectedDate[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            assignment.subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'custom',
                              color: Colors.blueAccent,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          assignment.formattedDueTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'custom',
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
