import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  //Remove this method to stop OneSignal Debugging 
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

OneSignal.initialize("75e1e2cf-0b57-49d3-b507-e456e996f447");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
OneSignal.Notifications.requestPermission(true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: WebViewApp(),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp>
    with SingleTickerProviderStateMixin {
  late WebViewController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);

    // Considerar iniciar la animación aquí si desea que comience inmediatamente
    // O puede activarla en onPageFinished para esperar a que el contenido de WebView cargue
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: WebView(
              initialUrl: 'https://porteriacero.es/',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              onPageFinished: (String url) {
                if (_isLoading) {
                  _animationController.forward().then((value) => setState(() {
                        _isLoading = false;
                      }));
                }
              },
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: FadeTransition(
                opacity: _animation,
                child: Image.network(
                  'https://porteriacero.es/wp-content/uploads/2024/03/sPLASH-PORTERIACERO.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
