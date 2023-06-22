import 'package:ring_sorting_flutter/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';

class HomeViewModel extends BaseViewModel {
  final log = getLogger('HomeViewModel');

  // final _snackBarService = locator<SnackbarService>();
  final _navigationService = locator<NavigationService>();

  void openInControlView() {
    _navigationService.navigateTo(Routes.controlView);
  }

  void openAutomaticView() {
    _navigationService.navigateTo(Routes.automaticView);
  }

  void openTrainView() {
    _navigationService.navigateTo(Routes.trainView);
  }

  void openFaceTestView() {
    // _navigationService.navigateTo(Routes.faceTest);
  }
}
