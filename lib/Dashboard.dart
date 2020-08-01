import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'CircleProgress.dart';
import 'main.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final databaseReference = FirebaseDatabase.instance.reference();

  AnimationController progressController;
  Animation<double> tempAnimation;
  Animation<double> humidityAnimation;

  @override
  void initState() {
    super.initState();

    databaseReference
        .child('device1')
        .once()
        .then((DataSnapshot snapshot) {
      double temp = snapshot.value['temp']['data'];
      double humidity = snapshot.value['humidity']['data'];

      isLoading = true;
      _DashboardInit(temp, humidity);
    });
  }

  _DashboardInit(double temp, double humid) {
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5000)); //5s

    tempAnimation =
    Tween<double>(begin: 0, end: temp).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    humidityAnimation =
    Tween<double>(begin: 0, end: humid).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        titleSpacing: 10.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text('Dashboard'),
            ),
            FlatButton(
              onPressed: handleLoginOutPopup,
              child: Text('Logout',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
              color: Colors.blue,

            )

          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
          child: isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CustomPaint(
                foregroundPainter:
                CircleProgress(tempAnimation.value, true),
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Temperature'),
                        Text(
                          '${tempAnimation.value.toInt()}',
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '°C',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomPaint(
                foregroundPainter:
                CircleProgress(humidityAnimation.value, false),
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Humidity'),
                        Text(
                          '${humidityAnimation.value.toInt()}',
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
              : Text(
            'Loading...',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          )),
    );
  }
  var alertStyle = AlertStyle(
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    titleStyle: TextStyle(
      color: Colors.red,
    ),
  );

  handleLoginOutPopup() {
    Alert(
      context: context,
      type: AlertType.info,
      style: alertStyle,
      title: "LogOut",
      desc: "Do you want to logout now?",
      buttons: [
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          color: Colors.blue,
        ),
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: handleSignOut,
          color: Colors.blue,
        )
      ],
    ).show();
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
            (Route<dynamic> route) => false);
  }
}