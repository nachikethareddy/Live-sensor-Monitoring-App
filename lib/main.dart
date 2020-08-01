import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livedata/Dashboard.dart';
import 'Dashboard.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Sensor Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Loginscreen(title: 'Live Sensor Data'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Loginscreen extends StatefulWidget {
  final String title;
  Loginscreen({Key key, this.title}) : super(key: key);

  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final FirebaseAuth firebaseAuth =FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: <String>['email']
  );
  GoogleSignInAccount _currentUser;

  @override
  void initState(){
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if(_currentUser != null){
        _handlefirebase();
      }
    });
    _googleSignIn.signInSilently();
  }
  _handlefirebase() async{
    GoogleSignInAuthentication googleAuth = await _currentUser.authentication;
    final AuthCredential credential =
        GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final FirebaseUser firebaseUser= (await firebaseAuth.signInWithCredential(credential)).user;

    if(firebaseUser!= null){
      print('Login');
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => new Dashboard()));
    }
  }
  Future<void> _handleSignIn() async{
    try {
      await _googleSignIn.signIn();
    }catch(error){
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(title: Text(widget.title),),
      body: Center(
        child: FlatButton(
          onPressed: _handleSignIn,
          child: Text('Google Sign in'),
          color: Colors.blue,

        ),
      ),
    );
  }

}
