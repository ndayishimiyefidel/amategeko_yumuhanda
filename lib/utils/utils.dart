import 'package:flutter/material.dart';

import '../enume/user_state.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

class Utils {
  static ShowSnackBar(String? text) {
    if (text == null) return;
    final snackBar = SnackBar(content: Text(text), backgroundColor: Colors.red);
    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }


  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.offLine:
        return 0;
      case UserState.onLine:
        return 1;
      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.offLine;
      case 1:
        return UserState.onLine;
      default:
        return UserState.waiting;
    }
  }

}
