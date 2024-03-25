import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize("75e1e2cf-0b57-49d3-b507-e456e996f447");
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

class _WebViewAppState extends State<WebViewApp> with SingleTickerProviderStateMixin {
  late WebViewController _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  final cookieManager = WebviewCookieManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _syncCookies();
  }

  Future<void> _syncCookies() async {
    // Sincroniza las cookies antes de cargar la página
    await cookieManager.getCookies('https://porteriacero.es/');
    // Puedes añadir aquí más lógica de sincronización de cookies si es necesario
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
            padding: const EdgeInsets.only(top: 40.0),
            child: WebView(
              initialUrl: 'https://porteriacero.es/',
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              onWebViewCreated: (WebViewController webViewController) {
                _controller = webViewController;
              },
              onPageFinished: (String url) async {
                if (_isLoading) {
                  _animationController.forward().then((value) => setState(() {
                        _isLoading = false;
                      }));
                  // Guarda las cookies después de que la página se carga
                  await cookieManager.getCookies(url);
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
      floatingActionButton: !_isLoading ? Padding(
        padding: const EdgeInsets.only(left: 25.0, bottom: 15.0), // Agrega un margen a la izquierda y abajo
        child: Align(
          alignment: Alignment.bottomLeft, // Alinea el botón a la izquierda
          child: SizedBox(
            height: 40.0, // Establece la altura del botón
            width: 40.0, // Establece el ancho del botón
            child: FloatingActionButton(
              onPressed: () {
                // Acción al presionar el botón flotante
              },
              backgroundColor: Colors.black, // Cambia el color de fondo a negro
              foregroundColor: Colors.white, // Cambia el color del icono a blanco
              child: const Icon(Icons.notifications), // Icono de notificaciones
              shape: CircleBorder(), // Hace que el botón sea totalmente redondo
            ),
          ),
        ),
      ) : null,
    );
  }
}