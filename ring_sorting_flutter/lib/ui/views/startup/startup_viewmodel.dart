import 'package:ring_sorting_flutter/services/db_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
import '../../../app/app.router.dart';

class StartupViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');

  final _navigationService = locator<NavigationService>();
  final _dbService = locator<DbService>();

  void handleStartupLogic() async {
    log.i('Startup');
    _dbService.setupNodeListening();
    // _dbService.setupAlertListening();
    // _baseService.setCurrentRoute(Routes.startUpView);
    await Future.delayed(const Duration(milliseconds: 800));
    // if (isUserLoggedIn) {
    //   log.d('Logged in user available');
    _navigationService.replaceWith(Routes.homeView);
    // } else {
    //   log.d('No logged in user');
    // }
  }

  // void doSomething() {
  //   _navigationService.replaceWith(
  //     Routes.hostel,
  //     arguments: DetailsArguments(name: 'FilledStacks'),
  //   );
  // }

  // void getStarted() {
  //   _navigationService.replaceWith(
  //     Routes.details,
  //     arguments: DetailsArguments(name: 'FilledStacks'),
  //   );
  // }
}
