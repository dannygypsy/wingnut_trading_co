import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


//
// Show an error dialog
//
Future errorDialog(BuildContext c, String? message) async {

  return showDialog(
      context: c,
      builder: (BuildContext context) {
        //ColorThemeProvider ctp = Provider.of<ColorThemeProvider>(context, listen: true);
        return AlertDialog(
          //backgroundColor: ctp.theme(context).dialogBackground,
          shape: const RoundedRectangleBorder(
              borderRadius:BorderRadius.all(Radius.circular(10.0))
          ),
          content: Builder(
            builder: (context) {
              return Stack(
                  clipBehavior: Clip.none, alignment: Alignment.center,
                  children: <Widget>[

                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 300,
                      ),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            const SizedBox(height:50),
                            Text(message ?? "No message."),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: -75,
                        child: Container(
                          width: 105.0,
                          height: 105.0,
                          decoration: const BoxDecoration(
                            //color: ctp.theme(context).dialogBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.exclamationmark_circle_fill, size: 100, color: Colors.red,),
                        )
                    )
                  ]
              );
            },
          ),
          actions: <Widget>[
            MaterialButton(
              //color: ctp.theme(context).buttonBackground,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        );

      }


  );

/*
  return showDialog<Null>(
      context: c,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Error'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(message ?? "Unknown Error"),
              ],
            ),
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        );
      }


  );

 */
}

Future successDialog(BuildContext c, String? message) async {

  return showDialog(
      context: c,
      builder: (BuildContext context) {
        //ColorThemeProvider ctp = Provider.of<ColorThemeProvider>(context, listen: true);
        return AlertDialog(
          //backgroundColor: ctp.theme(context).dialogBackground,
          shape: const RoundedRectangleBorder(
              borderRadius:BorderRadius.all(Radius.circular(10.0))
          ),
          content: Builder(
            builder: (context) {
              return Stack(
                  clipBehavior: Clip.none, alignment: Alignment.center,
                  children: <Widget>[

                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 300,
                      ),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            const SizedBox(height:50),
                            Text(message ?? "No message."),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: -75,
                        child: Container(
                          width: 105.0,
                          height: 105.0,
                          decoration: const BoxDecoration(
                            //color: ctp.theme(context).dialogBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.check_mark_circled_solid, size: 100, color: Colors.green,),
                        )
                    )
                  ]
              );
            },
          ),
          actions: <Widget>[
            MaterialButton(
              //color: ctp.theme(context).buttonBackground,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        );

      }


  );

}

//
// Show an ok dialog
//
Future<Null> okDialog(BuildContext c, String? title, String? message) async {


  return showDialog<Null>(
      context: c,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(title ?? "Title"),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(message ?? "No message."),
              ],
            ),
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text('OK'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        );
      }


  );
}

Future<Null> helpDialog(BuildContext c, String? message) async {

  return showDialog<Null>(
      context: c,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: ctp.theme(context).dialogBackground,
          shape: RoundedRectangleBorder(
              borderRadius:BorderRadius.all(Radius.circular(10.0))
          ),
          content: Builder(
            builder: (context) {
              return Stack(
                  clipBehavior: Clip.none, alignment: Alignment.center,
                  children: <Widget>[

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                      ),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            SizedBox(height:50),
                            Text(message ?? "No message."),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: -75,
                        child: Container(
                          width: 105.0,
                          height: 105.0,
                          decoration: new BoxDecoration(
                            //color: ctp.theme(context).dialogBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.info_circle_fill, size: 100),
                        )
                    )
                  ]
              );
            },
          ),
          actions: <Widget>[
            MaterialButton(
              //color: ctp.theme(context).buttonBackground,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        );

      }


  );
}


Future<Null> messageDialog(BuildContext c, String? message) async {

  return showDialog<Null>(
      context: c,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: ctp.theme(context).dialogBackground,
          shape: RoundedRectangleBorder(
              borderRadius:BorderRadius.all(Radius.circular(10.0))
          ),
          content: Builder(
            builder: (context) {
              return Stack(
                  clipBehavior: Clip.none, alignment: Alignment.center,
                  children: <Widget>[

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                      ),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            SizedBox(height:50),
                            Text(message ?? "No message."),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: -75,
                        child: Container(
                          width: 105.0,
                          height: 105.0,
                          decoration: new BoxDecoration(
                            //color: ctp.theme(context).dialogBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.doc_fill, size: 100),
                        )
                    )
                  ]
              );
            },
          ),
          actions: <Widget>[
            MaterialButton(
              //color: ctp.theme(context).buttonBackground,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        );

      }


  );
}


//
// Show a 'loading' style dialog
//
Future<Null> waitDialog(BuildContext c, String? message) async {

  showDialog(
      context: c,
      builder: (BuildContext context) {
        return new Dialog(
          child: new Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message ?? "No message."),
                ],
              ),
            ),

          ),
        );
      }


  );

}

Future<bool?> confirmDialog({required BuildContext c, String? message, String? cancel, String? ok}) async {

  return showDialog<bool>(
      context: c,
      builder: (BuildContext context) {

        //ColorThemeProvider ctp = Provider.of<ColorThemeProvider>(context, listen: true);

        return AlertDialog(
          // backgroundColor: ctp.theme(context).dialogBackground,
          shape: RoundedRectangleBorder(
              borderRadius:BorderRadius.all(Radius.circular(10.0))
          ),
          content: Builder(
            builder: (context) {
              return Stack(
                  clipBehavior: Clip.none, alignment: Alignment.center,
                  children: <Widget>[

                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                      ),
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            SizedBox(height:50),
                            Text(message ?? "No message."),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: -75,
                        child: Container(
                          width: 105.0,
                          height: 105.0,
                          decoration: new BoxDecoration(
                            //color: ctp.theme(context).dialogBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.question_circle_fill, size: 100),
                        )
                    )
                  ]
              );
            },
          ),
          actions: <Widget>[
            MaterialButton(
              //color: ctp.theme(context).buttonBackground,
              child: Text(cancel?.toUpperCase()?? "CANCEL"),
              onPressed: () {
                Navigator.of(c).pop(false);
              },
            ),
            MaterialButton(
              //color: ctp.theme(context).buttonBackground,
              child: Text(ok?.toUpperCase()?? "OK"),
              onPressed: () {
                Navigator.of(c).pop(true);
              },
            ),
          ],
        );

        /*

        return new AlertDialog(
            content: new Text(message ?? "No message."),
            actions: <Widget>[
              new TextButton(
                  child: new Text(cancel?.toUpperCase()?? "CANCEL"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    //return false;
                  }
              ),
              new TextButton(
                  child: new Text(ok?.toUpperCase()?? "OK"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    //return true;
                  }
              )
            ]
        );

         */
      }


  );


}