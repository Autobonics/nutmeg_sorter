import 'package:ring_sorting_flutter/models/models.dart';
import 'package:ring_sorting_flutter/services/db_service.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
// import '../../setup_snackbar_ui.dart';

class ControlViewModel extends ReactiveViewModel {
  final log = getLogger('HomeViewModel');

  // final _snackBarService = locator<SnackbarService>();
  // final _navigationService = locator<NavigationService>();
  final _dbService = locator<DbService>();

  DeviceReading? get node => _dbService.node;

  @override
  List<DbService> get reactiveServices => [_dbService];

  //Device data
  DeviceData _deviceData = DeviceData(
      stepper1: false,
      stepper3: false,
      stepper2: false,
      servoAngle: servoAngleDefault,
      timeDelay: timeDelayDefault);
  DeviceData get deviceData => _deviceData;

  void setDeviceData() {
    _dbService.setDeviceData(_deviceData);
  }

  void getDeviceData() async {
    setBusy(true);
    DeviceData? deviceData = await _dbService.getDeviceData();
    if (deviceData != null) {
      _deviceData = DeviceData(
          stepper1: deviceData.stepper1,
          stepper2: deviceData.stepper2,
          stepper3: deviceData.stepper3,
          servoAngle: deviceData.servoAngle,
          timeDelay: deviceData.timeDelay);
    }
    setBusy(false);
  }

  void onModelReady() {
    getDeviceData();
  }

  void setStepper1() {
    _deviceData.stepper1 = !_deviceData.stepper1;
    notifyListeners();
    setDeviceData();
  }

  void setStepper2() {
    _deviceData.stepper2 = !_deviceData.stepper2;
    notifyListeners();
    setDeviceData();
  }

  void setStepper3() {
    _deviceData.stepper3 = !_deviceData.stepper3;
    notifyListeners();
    setDeviceData();
  }

  void rightDirection() {
    _deviceData.servoAngle = servoCloseC;
    notifyListeners();
    setDeviceData();
  }

  void leftDirection() {
    _deviceData.servoAngle = servoOpenC;
    notifyListeners();
    setDeviceData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
