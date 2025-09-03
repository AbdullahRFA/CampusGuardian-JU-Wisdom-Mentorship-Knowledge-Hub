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
  var storeUserPrompt = 'Chat messages will appear here...';
  var userPrompt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.chat),
                          title: Text("Chat with AI"),
                        ),
                        const Divider(),
                        Expanded(
                          child: Center(
                            child: Text(
                              storeUserPrompt,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: userPrompt,
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    storeUserPrompt = userPrompt.text;
                                    userPrompt.clear();
                                  });
                                },
                                icon: const Icon(Icons.send, color: Colors.blue),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.chat),
      ),
      
    );
  }
}
