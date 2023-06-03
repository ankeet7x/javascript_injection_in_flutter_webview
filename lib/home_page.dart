import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController _controller;
  String? message;

  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("https://niravko.com"))
      ..addJavaScriptChannel("myChannel",
          onMessageReceived: (JavaScriptMessage message) {
        setMessage(message.message);
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectJavascript(_controller);
          },
        ),
      );

    super.initState();
  }

  setMessage(String javascriptMessage) {
    if (mounted) {
      setState(() {
        message = javascriptMessage;
      });
    }
  }

  _injectJavascript(WebViewController controller) async {
    controller.runJavaScript('''

  const items = Array.from(document.getElementsByClassName("Post_title__MJ8Hr __className_ff0aba"))

function getTitle(data){
    return data.textContent.trim();
}

const nameList = items.map(getTitle);

myChannel.postMessage(JSON.stringify(nameList));

''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: message == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Builder(
              builder: (context) {
                List<dynamic> items = jsonDecode(message!);
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index]),
                    );
                  },
                );
              },
            ),
    );
  }
}
