import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:main/login.dart';

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
      home: noteFinal(noteTitle: "Default Note Title"),
    );
  }
}

class noteFinal extends StatefulWidget {
  final String noteTitle;

  const noteFinal({super.key, required this.noteTitle});

  @override
  _noteFinalState createState() => _noteFinalState();
}

class _noteFinalState extends State<noteFinal> {

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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset('assets/image/logo2.png', width: 180, height: 80,),
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
                        Text(widget.noteTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            fontFamily: 'custom',
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    child:
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
                        ),
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Image.asset('assets/image/home.png', width: 48, height: 48),
                    Text('Home',
                      style: TextStyle(
                        fontFamily: 'custom',
                        fontSize: 16,
                      ),),
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/settings.png', width: 48, height: 48),
                    Text('Settings',
                      style: TextStyle(
                        fontFamily: 'custom',
                        fontSize: 16,
                      ),)
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/account_circle.png', width: 48, height: 48),
                    Text('Profile',
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