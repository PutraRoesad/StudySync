import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:main/landingpage.dart';
import 'package:main/signupPage.dart';
import 'forgotPasswordPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(
    DevicePreview(
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  bool _obscureText = true; 
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();

  Future<void> _login() async {
    final url = Uri.parse('http://127.0.0.1:8000/login'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _userEmail.text,
          'password': _userPassword.text,
        }),
      );

      if (response.statusCode == 200) {
        
        print('Login successful');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Landingpage()),
        );
      } else {
        
        print('Login failed: ${response.body}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Error during Login: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/image/logo1.png'),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  width: 160,
                  child: Text(
                    'Welcome back, to StudySync',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'custom',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _userEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(fontFamily: 'custom'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Password',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _userPassword,
                          obscureText: _obscureText, 
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(fontFamily: 'custom'),
                            suffixIcon: IconButton( 
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          value: _isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isChecked = newValue!;
                            });
                          },
                        ),
                        Text('Remember Me', style: TextStyle(fontFamily: 'custom',)),
                      ],
                    ),
                    GestureDetector(
                      onTap: (){
                        print('Forgot Password Clicked');
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => forgotPasswordPage()),
                        );
                      },
                      child: Text('Forgot Password?', style: TextStyle(fontFamily: 'custom',),),
                    ),
                  ],
                ),
                
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    margin: EdgeInsets.only(top: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _login,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(top: 24, bottom: 24, left: 128, right: 128),
                            backgroundColor: Color(0x99FFB20F),
                          ),
                          child: Text(
                            'LOG IN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: 'custom',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),  
              ],
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      height: 1,
                      width: 110,
                      color: Colors.grey,
                    ),
                    Text('or continue with', style: TextStyle(fontFamily: 'custom'),),
                    Container(
                      margin: EdgeInsets.only(left: 16),
                      height: 1,
                      width: 110,
                      color: Colors.grey,
                    ),
                  ],
                ),
                
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 90,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                      ),
                      Container(
                        width: 90,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                      ),
                      Container(
                        width: 90,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        )
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to StudySync? '),
                        GestureDetector(
                          onTap: (){
                            print('Sign Up Clicked ');
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => signupPage()),
                            );
                          },
                          child: Text('Sign Up', style: TextStyle(fontFamily: 'custom',color: Color(0xFFFFAD00),),),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}