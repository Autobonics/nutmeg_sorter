const uid = "7XBomY7VFIb4gfp5VM4IVcIk7xs2";

/// Device Sensor Reading model
class DeviceReading {
  bool isRing;
  DateTime lastSeen;

  DeviceReading({
    required this.isRing,
    required this.lastSeen,
  });

  factory DeviceReading.fromMap(Map data) {
    return DeviceReading(
      isRing: data['isRing'] ?? false,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(data['ts']),
    );
  }
}

/// Device control model
const int flapAngleDefault = 100;
const int rotateAngleDefault = 180;
const int timeDelayDefault = 12;
const int closeFlapC = 45;
const int openFlapC = 60;
const int straitPositionC = 180;
const int rotatedPositionC = 0;
const int dropLeftPositionC = 45;
const int dropRightPositionC = 135;

/// =====
class DeviceData {
  bool stepper;
  int flapAngle;
  int rotateAngle;
  int timeDelay;

  DeviceData({
    required this.stepper,
    required this.flapAngle,
    required this.rotateAngle,
    required this.timeDelay,
  });

  factory DeviceData.fromMap(Map data) {
    return DeviceData(
      stepper: data['stepper'] ?? false,
      flapAngle:
          data['flapAngle'] != null ? data['flapAngle'] : flapAngleDefault,
      rotateAngle: data['rotateAngle'] != null
          ? data['rotateAngle']
          : rotateAngleDefault,
      timeDelay:
          data['timeDelay'] != null ? data['timeDelay'] : timeDelayDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepper': stepper,
        'flapAngle': flapAngle,
        'rotateAngle': rotateAngle,
        'timeDelay': timeDelay,
      };
}
