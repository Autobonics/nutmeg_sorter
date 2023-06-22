import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ring_sorting_flutter/models/models.dart';
import 'package:ring_sorting_flutter/services/db_service.dart';
import 'package:ring_sorting_flutter/services/image_processing_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.logger.dart';
// import '../../setup_snackbar_ui.dart';
import 'dart:math';

class TrainViewModel extends ReactiveViewModel {
  final log = getLogger('AutomaticViewModel');

  final _snackBarService = locator<SnackbarService>();
  final _dbService = locator<DbService>();
  final _imageProcessingService = locator<ImageProcessingService>();

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
      _topImg = null;
      notifyListeners();
      log.i("Sorting");
      // setStepper3(true);

      if (node!.isIr && !_isNutPlaced) {
        // if (!_deviceData.stepper1) {
        //   setStepper1(true);
        //   setStepper2(true);
        // }
        log.i("Ring is here");
        setStepper1(false);
        setStepper2(true);
        await Future.delayed(Duration(milliseconds: 2000));
        setStepper2(false);
        await alignRing();
        // stopSorting();
      } else {
        while (!node!.isIr && _isSorting) {
          log.i('No ring');
          setStepper1(true);
          // setStepper2(true);
          await Future.delayed(Duration(milliseconds: 100));
        }
        // setDefaultPosition();
        // stepperStop();
      }
    }
    setStepper3(false);
    setStepper2(false);
    setStepper1(false);
  }

  bool _isNutPlaced = false;
  bool get isNutPlaced => _isNutPlaced;

  File? _topImg;
  File? get topImg => _topImg;

  Future alignRing() async {
    log.i("Processing");
    _isNutPlaced = true;
    while (_isNutPlaced) {
      // rightDirection();
      await Future.delayed(Duration(seconds: 3));
      XFile img = await controller.takePicture();
      log.i(
          "Height: ${controller.value.previewSize?.height} Width: ${controller.value.previewSize?.width}");
      _topImg = await _imageProcessingService.getCroppedImageOfRing(img.path);
      await Future.delayed(Duration(seconds: 1));
      //Drop based on the decision
      bool isGoodRing = await decideIsGoodRing();
      if (isGoodRing)
        dropLeftPosition();
      else
        dropRightPosition();
      //==
      setStepper2(true);
      await Future.delayed(Duration(seconds: 2));
      setStepper2(false);
      //==continue
      await Future.delayed(Duration(seconds: 1));
      setStepper3(true);
      await Future.delayed(Duration(seconds: 3));
      setStepper3(false);
      setDefaultPosition();
      _isNutPlaced = false;
      notifyListeners();
    }
  }

  Future<bool> decideIsGoodRing() async {
    log.i("Deciding ring condition");
    final s1 = await _topImg!.length();
    Random random = Random();
    bool c = random.nextBool();
    log.i(c);
    return c;
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
