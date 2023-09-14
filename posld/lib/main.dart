import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController _controller;
  late String _initialUrl;
  late SharedPreferences _prefs;
  bool _isLoading = true;
  bool _isError = false;

  _MyAppState() {
    _initialUrl = 'https://posld.com';
  }

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _initialUrl = _prefs.getString('lastPageUrl') ?? _initialUrl;
    setState(() {});
  }

  Future<bool> _shouldShowSplashScreen() async {
    // Simulate loading data for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    return true;
  }

  Future<void> _refreshWebView() async {
    setState(() {
      _isLoading = true;
    });
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _shouldShowSplashScreen(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: _refreshWebView,
                child: Stack(
                  children: [
                    WebView(
                      initialUrl: _initialUrl,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller = webViewController;
                      },
                      onPageFinished: (String url) async {
                        if (_isError) {
                          _controller.loadUrl(_initialUrl);
                          _isError = false;
                        }
                        setState(() {
                          _isLoading = false;
                        });
                        await _saveLastPageUrl(url);
                      },
                      onWebResourceError: (WebResourceError error) {
                        print("Error: ${error.description}");
                        _isError = true;
                        setState(() {
                          _isLoading = true;
                        });
                      },
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                          child: Padding(
                          padding: const EdgeInsets.only(top: 244),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 55.5),
                                Image.asset(
                                  "assets/logo.jpg",
                                  width: 300,
                                ),
                                SizedBox(height: 50),
                                SpinKitFadingCircle(
                                  duration: Duration(seconds: 2),
                                  color: Color.fromARGB(255, 83, 60, 30),
                                  size: 24.0,
                                ),
                                Padding(
                                        padding: const EdgeInsets.only(top: 219),
                                        child: Text(
                                          "Version 1.0",
                                          style: GoogleFonts.poppins(
                                            color:  Color.fromARGB(195, 83, 60, 30),
                                            fontSize: 16,
                                      
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 193),
                    child: Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          "assets/logo.jpg",
                          width: 90,
                        ),
                      ),
                    ),
                  ),
                  
            Padding(
              padding: const EdgeInsets.only(top: 187),
              child: Text(
                "Version 1.0",
                style: GoogleFonts.poppins(
                  color:  Color.fromARGB(195, 83, 60, 30),
                  fontSize: 16,
            
                ),
              ),
            ),
                  // SizedBox(height: 16),
                  // CircularProgressIndicator(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _saveLastPageUrl(String url) async {
    await _prefs.setString('lastPageUrl', url);
  }
}
