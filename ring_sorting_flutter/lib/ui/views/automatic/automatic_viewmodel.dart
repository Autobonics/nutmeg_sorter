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

class TrainViewModel extends ReactiveViewModel {
  final log = getLogger('AutomaticViewModel');

  final _snackBarService = locator<SnackbarService>();
  // final _navigationService = locator<NavigationService>();
  final _dbService = locator<DbService>();
  final _imageProcessingService = locator<ImageProcessingService>();

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
        stepper: false,
        flapAngle: flapAngleDefault,
        rotateAngle: rotateAngleDefault,
        timeDelay: _deviceData.timeDelay);
    setDeviceData();
    notifyListeners();
  }

  Future<void> sortItems() async {
    setDefaultPosition();
    while (_isSorting) {
      _topImg = null;
      _bottomImg = null;
      notifyListeners();
      log.i("Sorting");
      if (node!.isRing && !_isRingPlaced) {
        if (!_deviceData.stepper) {
          stepperRotate();
        }
        log.i("Ring is here");
        await Future.delayed(Duration(seconds: _deviceData.timeDelay));
        stepperStop();
        await alignRing();
        // stopSorting();
      } else {
        while (!node!.isRing) {
          log.i('No ring');
          stepperRotate();
          await Future.delayed(Duration(milliseconds: 100));
        }
        // setDefaultPosition();
        // stepperStop();
      }
    }
  }

  bool _isRingPlaced = false;
  bool get isRingPlaced => _isRingPlaced;

  File? _topImg;
  File? get topImg => _topImg;
  File? _bottomImg;
  File? get bottomImg => _bottomImg;

  Future alignRing() async {
    log.i("Processing");
    _isRingPlaced = true;
    while (_isRingPlaced) {
      closeFlap();
      await Future.delayed(Duration(seconds: 3));
      XFile img = await controller.takePicture();
      log.i(
          "Height: ${controller.value.previewSize?.height} Width: ${controller.value.previewSize?.width}");
      _topImg = await _imageProcessingService.getCroppedImageOfRing(img.path);
      rotatedPosition();
      await Future.delayed(Duration(seconds: 1));
      img = await controller.takePicture();
      _bottomImg =
          await _imageProcessingService.getCroppedImageOfRing(img.path);
      await Future.delayed(Duration(seconds: 1));
      //Drop based on the decision
      bool isGoodRing = await decideIsGoodRing();
      await Future.delayed(Duration(seconds: 5));
      if (isGoodRing)
        dropLeftPosition();
      else
        dropRightPosition();
      //==continue
      await Future.delayed(Duration(seconds: 1));
      openFlap();
      await Future.delayed(Duration(seconds: 1));
      setDefaultPosition();
      _isRingPlaced = false;
      notifyListeners();
    }
  }

  Future<bool> decideIsGoodRing() async {
    log.i("Deciding ring condition");
    final s1 = await _topImg!.length();
    final s2 = await _bottomImg!.length();
    if (s1 > s2) {
      return true;
    } else {
      return false;
    }
  }

  void setDelayTime(int value) {
    log.i("Delay time edited: $value");
    _deviceData.timeDelay = value;
    notifyListeners();
    setDeviceData();
  }

  void stepperRotate() {
    _deviceData.stepper = true;
    notifyListeners();
    setDeviceData();
  }

  void stepperStop() {
    _deviceData.stepper = false;
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
    log.i("Left position");
    _deviceData.rotateAngle = dropLeftPositionC;
    notifyListeners();
    setDeviceData();
  }

  void dropRightPosition() {
    log.i("Right position");
    _deviceData.rotateAngle = dropRightPositionC;
    notifyListeners();
    setDeviceData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
