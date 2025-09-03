import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusGuardian (JU Wisdom – Mentorship & Knowledge Hub)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'JUWise'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // body:Container(
      //   alignment: Alignment.center,
      //   child: Text("Welcome JU Wisdom-Mentorship and Knowledge Hub ",
      //   style: TextStyle(
      //     fontSize: 21,
      //     fontWeight: FontWeight.bold
      //   ),
      //   ),
      //  
      // ),
      body: Center(
        child: Container(
          child: Card(

            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text("Welcome to the JuWise ",
              style: TextStyle(
                height: 5,
                wordSpacing: 5,
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: Colors.blue
              ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){},
        child: Icon(Icons.chat),
      ),
    );
  }
}
