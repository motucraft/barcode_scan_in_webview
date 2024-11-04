import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Barcode Scan in WebView',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Barcode Scan in WebView'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _WebViewScreen(
                      title: '@zxing/library',
                      uri: WebUri('https://zxing-js.github.io/library/'),
                    ),
                  ));
                },
                child: Text(
                  '@zxing/library',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _WebViewScreen(
                      title: '@ericblade/quagga2',
                      uri: WebUri(
                        'https://serratus.github.io/quaggaJS/examples/live_w_locator.html',
                      ),
                    ),
                  ));
                },
                child: Text(
                  '@ericblade/quagga2',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _WebViewScreen(
                      title: 'html5-qrcode',
                      uri: WebUri(
                        'https://blog.minhazav.dev/research/html5-qrcode',
                      ),
                    ),
                  ));
                },
                child: Text(
                  'html5-qrcode',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebViewScreen extends HookWidget {
  final String title;
  final WebUri uri;

  const _WebViewScreen({
    required this.title,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) {
    final webViewController = useState<InAppWebViewController?>(null);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(child: Text(title)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(
                  isInspectable: kDebugMode,
                ),
                initialUrlRequest: URLRequest(url: uri),
                onWebViewCreated: (controller) {
                  webViewController.value = controller;
                },
                onPermissionRequest: _onPermissionRequest,
              ),
            ),
            _NavigationControls(webViewController: webViewController.value),
          ],
        ),
      ),
    );
  }
}

class _NavigationControls extends StatelessWidget {
  final InAppWebViewController? webViewController;

  const _NavigationControls({required this.webViewController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () async {
              if (webViewController == null) return;

              if (await webViewController!.canGoBack()) {
                await webViewController!.goBack();
              }
            },
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () async {
              if (webViewController == null) return;

              if (await webViewController!.canGoForward()) {
                await webViewController!.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<PermissionResponse?> _onPermissionRequest(
    InAppWebViewController controller,
    PermissionRequest permissionRequest) async {
  try {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }
    return PermissionResponse(
      action: PermissionResponseAction.GRANT,
      resources: [PermissionResourceType.CAMERA],
    );
  } catch (e) {
    return PermissionResponse(
      action: PermissionResponseAction.PROMPT,
      resources: [PermissionResourceType.CAMERA],
    );
  }
}
