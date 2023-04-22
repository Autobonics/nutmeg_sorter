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
      stepper: false,
      flapAngle: flapAngleDefault,
      rotateAngle: rotateAngleDefault,
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
          stepper: deviceData.stepper,
          flapAngle: deviceData.flapAngle,
          rotateAngle: deviceData.rotateAngle,
          timeDelay: deviceData.timeDelay);
    }
    setBusy(false);
  }

  void onModelReady() {
    getDeviceData();
  }

  void setStepper() {
    _deviceData.stepper = !_deviceData.stepper;
    notifyListeners();
    setDeviceData();
  }

  void closeFlap() {
    _deviceData.flapAngle = closeFlapC;
    notifyListeners();
    setDeviceData();
  }

  void openFlap() {
    _deviceData.flapAngle = openFlapC;
    notifyListeners();
    setDeviceData();
  }

  void straitPosition() {
    _deviceData.rotateAngle = straitPositionC;
    notifyListeners();
    setDeviceData();
  }

  void rotatedPosition() {
    _deviceData.rotateAngle = rotatedPositionC;
    notifyListeners();
    setDeviceData();
  }

  void dropLeftPosition() {
    _deviceData.rotateAngle = dropLeftPositionC;
    notifyListeners();
    setDeviceData();
  }

  void dropRightPosition() {
    _deviceData.rotateAngle = dropRightPositionC;
    notifyListeners();
    setDeviceData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
