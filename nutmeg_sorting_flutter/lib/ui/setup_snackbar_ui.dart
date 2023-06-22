import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';

enum SnackbarType { success, error }

void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.success,
    config: SnackbarConfig(
      backgroundColor: Colors.green,
      // textColor: Colors.white,
      icon: const Icon(
        Icons.done_all,
        color: Colors.white,
      ),
      borderRadius: 1,
      // dismissDirection: SnackDismissDirection.HORIZONTAL,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.error,
    config: SnackbarConfig(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      icon: const Icon(
        Icons.warning,
        color: Colors.white,
      ),
      borderRadius: 1,
    ),
  );
}
