import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signalr_client/signalr_client.dart';

// Esta classe permite acesso ao LocalHost com certificados HTTPS inválidos
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SignalR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter SignalR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = new TextEditingController();
  final hubConnection =
      HubConnectionBuilder().withUrl("https://10.0.2.2:5001/chatHub").build();
  final List<String> messages = new List<String>();

  @override
  void initState() {
    super.initState();

    hubConnection.onclose((_) {
      print("Conexão perdida");
    });

    hubConnection.on("ReceiveMessage", onReceiveMessage);

    startConnection();
  }

  void onReceiveMessage(List<Object> result) {
    setState(() {
      messages.add("${result[0]} diz: ${result[1]}");
    });
  }

  void startConnection() async {
    await hubConnection.start();
  }

  void sendMessage() async {
    await hubConnection.invoke("SendMessage",
        args: <Object>["Flutter", controller.text]).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (ctx, i) {
            return Text(messages[i]);
          },
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.all(20),
        height: 90,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: "Mensagem..."),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          sendMessage();
        },
      ),
    );
  }
}
