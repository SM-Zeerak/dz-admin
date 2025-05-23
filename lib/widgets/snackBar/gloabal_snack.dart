import 'package:dz_admin_panel/core/color_cons.dart';
import 'package:dz_admin_panel/widgets/Text/customText.dart';
import 'package:flutter/material.dart';

class globalSnack {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: CustomText(
        text: message,
        color: ClrCons.whiteColor,
      ),
      duration: Duration(seconds: 3),
      backgroundColor: ClrCons.primaryClr,
    );

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
