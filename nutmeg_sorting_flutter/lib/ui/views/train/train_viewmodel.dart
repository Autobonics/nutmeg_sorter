import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ring_sorting_flutter/models/models.dart';
import 'package:ring_sorting_flutter/services/db_service.dart';
import 'package:ring_sorting_flutter/services/image_processing_service.dart';
import 'package:ring_sorting_flutter/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
// import '../../setup_snackbar_ui.dart';

class TrainViewModel extends ReactiveViewModel {
  final log = getLogger('AutomaticViewModel');

  final _snackBarService = locator<SnackbarService>();
  // final _navigationService = locator<NavigationService>();
  final _dbService = locator<DbService>();
  final _imageProcessingService = locator<ImageProcessingService>();
  final _storageService = locator<StorageService>();

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

  late List<CameraDescription> _cameras;
  late CameraController controller;

  void onModelReady() async {
    setBusy(true);
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) async {
      final zl = await controller.getMaxZoomLevel();
      log.i("Zoom level:$zl");
      if (zl > 3.0) controller.setZoomLevel(3.0);
      // if (!mounted) {
      //   return;
      // }
      // setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
    getDeviceData();
  }

  bool _isSorting = false;
  bool get isSorting => _isSorting;

  Future sort() async {
    _isSorting = true;
    notifyListeners();
    sortItems();
  }

  void stopSorting() {
    log.i("Stopping sorting");
    _isSorting = false;
    notifyListeners();
  }

  void setDefaultPosition() {
    log.i("Default position");
    _deviceData = DeviceData(
        stepper1: false,
        stepper3: false,
        stepper2: false,
        servoAngle: servoAngleDefault,
        timeDelay: _deviceData.timeDelay);
    setDeviceData();
    notifyListeners();
  }

  Future<void> sortItems() async {
    setDefaultPosition();
    while (_isSorting) {
      _nutImg = null;
      notifyListeners();
      log.i("Sorting");
      setStepper3(true);

      if (node!.isIr && !_isRingPlaced) {
        if (!_deviceData.stepper1) {
          setStepper1(true);
          setStepper2(true);
        }
        log.i("Ring is here");
        await Future.delayed(Duration(seconds: _deviceData.timeDelay));
        setStepper1(false);
        setStepper2(false);
        await alignRing();
        // stopSorting();
      } else {
        while (!node!.isIr) {
          log.i('No ring');
          setStepper1(true);
          setStepper2(true);
          await Future.delayed(Duration(milliseconds: 100));
        }
        // setDefaultPosition();
        // stepperStop();
      }
    }
    setStepper3(false);
  }

  bool _isRingPlaced = false;
  bool get isRingPlaced => _isRingPlaced;

  File? _nutImg;
  File? get nutImg => _nutImg;
  // File? _bottomImg;
  // File? get bottomImg => _bottomImg;

  Future alignRing() async {
    log.i("Processing");
    _isRingPlaced = true;
    while (_isRingPlaced) {
      // closeFlap();
      await Future.delayed(Duration(seconds: 3));
      XFile img = await controller.takePicture();
      log.i(
          "Height: ${controller.value.previewSize?.height} Width: ${controller.value.previewSize?.width}");
      _nutImg = await _imageProcessingService.getCroppedImageOfRing(img.path);
      // rotatedPosition();
      // // await Future.delayed(Duration(seconds: 3));
      // img = await controller.takePicture();
      // _bottomImg =
      //     await _imageProcessingService.getCroppedImageOfRing(img.path);
      // // await Future.delayed(Duration(seconds: 3));
      // //Drop based on the decision
      _isTakingDecision = true;
      notifyListeners();
      await Future.delayed(Duration(seconds: 8));
      if (_isGoodRing)
        dropLeftPosition();
      else
        dropRightPosition();
      await setRingCondition();
      // openFlap();
      await Future.delayed(Duration(seconds: 1));
      setDefaultPosition();
      _isRingPlaced = false;
      notifyListeners();
    }
  }

  bool _isTakingDecision = false;
  bool get isTakingDecision => _isTakingDecision;
  bool _isGoodRing = true;
  bool get isGoodRing => _isGoodRing;
  void setGood() {
    _isGoodRing = true;
    notifyListeners();
  }

  void setBad() {
    _isGoodRing = false;
    notifyListeners();
  }

  Future setRingCondition() async {
    _isTakingDecision = false;
    notifyListeners();
    _storageService.uploadFile(_nutImg!,
        "training/${_isGoodRing ? "good/" : "bad/"}${DateTime.now()}");
  }

  void setDelayTime(int value) {
    log.i("Delay time edited: $value");
    _deviceData.timeDelay = value;
    notifyListeners();
    setDeviceData();
  }

  void setStepper1(bool value) {
    _deviceData.stepper1 = value;
    notifyListeners();
    setDeviceData();
  }

  void setStepper2(bool value) {
    _deviceData.stepper2 = value;
    notifyListeners();
    setDeviceData();
  }

  void setStepper3(bool value) {
    _deviceData.stepper3 = value;
    notifyListeners();
    setDeviceData();
  }

  void dropRightPosition() {
    _deviceData.servoAngle = servoCloseC;
    notifyListeners();
    setDeviceData();
  }

  void dropLeftPosition() {
    _deviceData.servoAngle = servoOpenC;
    notifyListeners();
    setDeviceData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
