import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msal_flutter/msal_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _authority =
      _authority;
  static const String _redirectUri = "https://login.microsoftonline.com/common/oauth2/nativeclient";
  static const String _clientId = "024dbb9f-52d5-4d2c-8b94-08f9bc4c1d7a";
  String _output = 'NONE';

  PublicClientApplication? pca;

  Future<void> _acquireToken() async {
    print("called acquiretoken");
    //create the PCA if not already created
    if (pca == null) {
      print("creating pca...");
      pca = await PublicClientApplication.createPublicClientApplication(
          _clientId,
          authority: _authority,
          iosRedirectUri: _redirectUri);
    }

    print("pca created");

    String res;
    try {
      res = await pca!.acquireToken(
          ["https://msalfluttertest.onmicrosoft.com/msaltesterapi/All"]);
      print(res);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token. Unspecified reason";
    }

    setState(() {
      _output = res;
    });
  }

  Future<void> _acquireTokenSilently() async {
    if (pca == null) {
      print("initializing pca");
      pca = await PublicClientApplication.createPublicClientApplication(
          _clientId,
          redirectUri: _redirectUri,
          authority: _authority);
    }

    String res;
    try {
      res = await pca!.acquireTokenSilent(
          ["https://msalfluttertest.onmicrosoft.com/msaltesterapi/All"]);
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token silently!";
    }

    print("Got token");
    print(res);

    setState(() {
      _output = res;
    });
  }

  Future _logout() async {
    print("called logout");
    if (pca == null) {
      pca = await PublicClientApplication.createPublicClientApplication(
          _clientId,
          authority: _authority);
    }

    print("pca is not null");
    String res;
    try {
      await pca!.logout();
      res = "Account removed";
    } on MsalException {
      res = "Error signing out";
    } on PlatformException catch (e) {
      res = "some other exception ${e.toString()}";
    }

    print("setting state");
    setState(() {
      _output = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _acquireToken,
                child: Text('AcquireToken()'),
              ),
              ElevatedButton(
                  onPressed: _acquireTokenSilently,
                  child: Text('AcquireTokenSilently()')),
              ElevatedButton(onPressed: _logout, child: Text('Logout')),
              Text(_output),
            ],
          ),
        ),
      ),
    );
  }
}