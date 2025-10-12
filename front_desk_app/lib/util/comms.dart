import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:front_desk_app/model/values.dart';


class CallResults {
  bool success = false;
  String? message = "";
  Object? data;
}

Future<CallResults> remoteGet(String script, Map<String, String> args) async {

  CallResults results = CallResults();

  Response response;
  Dio dio = Dio();
  if (Values.authToken != null)
    dio.options.headers = {'Authorization' : Values.authToken};

  var uri = Uri.http(Values.restAPIHost, "${Values.scriptFolder}/$script");
  if (Values.useSSL) {
    uri = Uri.https(Values.restAPIHost, "${Values.scriptFolder}/$script");
  }
  //var uri = Uri.https(Values.restAPIHost, "${Values.scriptFolder}/$script");

  //print("GET...${uri2.toString()}");

  bool _success;
  try {
    debugPrint("Loading...${uri.toString()}");

    //await dio.post("/test", data: {"id": 12, "name": "wendu"});
    response = await dio.get(uri.toString(), queryParameters: args);
    if (response.statusCode == HttpStatus.ok) {
      debugPrint("Result:${response.data.toString()}");
      _success = response.data['success'];
      results.message = response.data['message'];

      if (_success == true) {
        results.success = true;
        results.data = response.data;
        return results;
      } else {
        results.success = false;
      }

    } else {
      results.success = false;
      results.message = "An internal error occurred at our server. Please report this error.";
    }
  } catch (exception) {
    debugPrint("COMMS EXCEPTION: $exception");
    results.success = false;
    results.message = "A communications error occurred. Is your device online?";
  }

  return results;
}

Future<CallResults> remotePost(String script, Map<String, String> args) async {

  CallResults results = CallResults();

  Response response;
  Dio dio = new Dio();
  if (Values.authToken != null)
    dio.options.headers = {'Authorization' : Values.authToken};

  var uri = new Uri.https(Values.restAPIHost, script);

  bool _success;
  try {
    debugPrint("Loading...${uri.toString()}");
    response = await dio.post(uri.toString(), queryParameters: args);
    if (response.statusCode == HttpStatus.ok) {
      //debugPrint("Result:${response.data.toString()}");
      _success = response.data['success'];
      results.message = response.data['message'];

      //Is there an auth token?
      if (response.headers.value("auth-token") != null) {
        debugPrint("Got an auth token here...${response.headers.value("auth-token")}");
        Values.authToken = response.headers.value("auth-token");
      }

      if (_success == true) {
        results.success = true;
        results.data = response.data;
        return results;
      } else {
        results.success = false;
      }

    } else {
      results.success = false;
      results.message = "An internal error occurred at our server. Please report this error.";
    }
  } catch (exception) {
    debugPrint("COMMS EXCEPTION: $exception");
    results.success = false;
    results.message = "A communications error occurred. Is your device online?";
  }

  return results;
}

Future<CallResults> remotePut(String script, Map<String, String> args) async {

  CallResults results = CallResults();

  Response response;
  Dio dio = new Dio();
  if (Values.authToken != null)
    dio.options.headers = {'Authorization' : Values.authToken};

  var uri = new Uri.https(Values.restAPIHost, script);

  //print("GET...${uri2.toString()}");

  try {
    debugPrint("Loading...${uri.toString()}");

    //await dio.post("/test", data: {"id": 12, "name": "wendu"});
    response = await dio.put(uri.toString(), queryParameters: args);

    if (response.statusCode == HttpStatus.ok) {
      debugPrint("Result:${response.data.toString()}");
      results.success = true;
      results.data = response.data;
    } else {
      results.message = "An internal error occurred at our server. Please report this error.";
    }
  } catch (exception) {
    debugPrint("COMMS EXCEPTION: $exception");
    results.message = "A communications error occurred. Is your device online?";
  }

  return results;
}

Future<CallResults> remotePatch(String script, Map<String, Object> args) async {

  CallResults results = CallResults();

  Response response;
  Dio dio = new Dio();
  if (Values.authToken != null)
    dio.options.headers = {'Authorization' : Values.authToken};

  var uri = new Uri.https(Values.restAPIHost, script);

  //print("GET...${uri2.toString()}");

  bool _success;
  String? _msg;
  try {
    debugPrint("Loading...${uri.toString()}");

    //await dio.post("/test", data: {"id": 12, "name": "wendu"});
    response = await dio.patch(uri.toString(), queryParameters: args);
    if (response.statusCode == HttpStatus.ok) {
      debugPrint("Result:${response.data.toString()}");
      results.success = true;
      results.data = response.data;
    } else {
      results.message = "An internal error occurred at our server. Please report this error.";
    }
  } catch (exception) {
    debugPrint("COMMS EXCEPTION: $exception");
    results.message = "A communications error occurred. Is your device online?";
  }

  return results;
}

Future<CallResults> remoteDelete(String script, Map<String, Object> args) async {

  CallResults results = CallResults();

  Response response;
  Dio dio = new Dio();
  if (Values.authToken != null)
    dio.options.headers = {'Authorization' : Values.authToken};

  var uri = new Uri.https(Values.restAPIHost, script);

  //print("GET...${uri2.toString()}");

  bool _success;
  String? _msg;
  try {
    debugPrint("Loading...${uri.toString()}");

    //await dio.post("/test", data: {"id": 12, "name": "wendu"});
    response = await dio.delete(uri.toString(), queryParameters: args);
    if (response.statusCode == HttpStatus.ok) {
      debugPrint("Result:${response.data.toString()}");
      results.success = true;
      results.data = response.data;
    } else {
      results.message = "An internal error occurred at our server. Please report this error.";
    }
  } catch (exception) {
    debugPrint("COMMS EXCEPTION: $exception");
    results.message = "A communications error occurred. Is your device online?";
  }

  return results;
}


num asNum(var v) {
  num n;

  if (v == null)
    return 0;

  try {
    n = v as num;
  } catch (exception) {
    try {
      n = num.parse(v);

    } catch (Exception) {
      debugPrint("Warning: $v is not a number.");
      n = 0;
    }

  }

  return n;
}

int asInt(var v) {

  int i;

  if (v == null)
    return 0;

  try {
    i = v as int;
  } catch (exception) {
    try {
      i = int.parse(v);

    } catch (Exception) {
      debugPrint("Warning: $v is not an int.");
      i = 0;
    }

  }

  return i;
}

double asDouble(var v) {

  double d;

  if (v == null)
    return 0.0;

  try {
    d = v as double;
  } catch (exception) {
    try {
      d = double.parse("$v");

    } catch (Exception) {

      try {
        d = int.parse(v).truncateToDouble();

      } catch (Exception) {
        debugPrint("Warning: $v is not a double.");
        d = 0;
      }
    }
  }

  return d;
}

String? asString(var v) {

  if ((v == null) || (v == "null"))
    return null;

  String? s;

  try {
    s = v.toString();
  } catch (exception) {
    debugPrint("Warning: $v is not a string.");
    s = null;
  }

  if (s?.length == 0)
    s = null;

  return s;
}

bool asBool(var v) {

  //debugPrint("it's ${v.runtimeType}");
  if ((v == null) || (v == "null"))
    return false;
  bool b;

  try {
    if (v is bool)
      b = v;
    else if (v is String) {
      //debugPrint("String");
      b = v == "1";
    } else if (v is num) {
      b = v == 1;
    } else
      b = false;
  } catch (exception) {
    if (v == "1")
      b = true;
    else
      b = false;
    //print("Warning: $v is not a bool.");
    //b = false;
  }

  return b;
}