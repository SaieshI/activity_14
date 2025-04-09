import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();

    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    messaging.getToken().then((value) {
      print('FCM Token: $value');
    });

    FirebaseInstallations.instance.getId().then((installationID) {
      print('Installation ID: $installationID');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      print(event.data);
      String type = event.data['notificationType'] ?? 'regular';
      Color? backgroundColor;
      String textTitle;
      if (type == 'important') {
        backgroundColor = Colors.red;
        textTitle = 'Importnat Notification';
      } else {
        backgroundColor = Colors.blue;
        textTitle = 'Regular Notification';
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: Text(textTitle),
            content: Text(event.notification!.body!),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Cloud Messaging Tutorial'),
            SizedBox(height: 20),
            ...notifications.map((message) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message, style: TextStyle(fontSize: 16)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
