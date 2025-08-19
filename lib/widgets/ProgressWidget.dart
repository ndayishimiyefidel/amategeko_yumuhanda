import 'package:flutter/material.dart';

import '../utils/constants.dart';

oldcircularprogress() {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 12.0),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
    ),
  );
}

circularprogress() {
  return const SizedBox(
    height: 20.0,
    width: 20.0,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
  );
}
