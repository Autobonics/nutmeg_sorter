const uid = "DUwpLtepkpcACTgdTAHjqvMRjml1";

/// Device Sensor Reading model
class DeviceReading {
  bool isIr;
  DateTime lastSeen;

  DeviceReading({
    required this.isIr,
    required this.lastSeen,
  });

  factory DeviceReading.fromMap(Map data) {
    return DeviceReading(
      isIr: !data['isIr'] ?? false,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(data['ts']),
    );
  }
}

/// Device control model
const int servoAngleDefault = 100;
const int timeDelayDefault = 12;
const int servoCloseC = 40;
const int servoOpenC = 110;

/// =====
class DeviceData {
  bool stepper1;
  bool stepper2;
  bool stepper3;
  int servoAngle;
  int timeDelay;

  DeviceData({
    required this.stepper1,
    required this.stepper2,
    required this.stepper3,
    required this.servoAngle,
    required this.timeDelay,
  });

  factory DeviceData.fromMap(Map data) {
    return DeviceData(
      stepper1: data['stepper1'] ?? false,
      stepper2: data['stepper2'] ?? false,
      stepper3: data['stepper3'] ?? false,
      servoAngle:
          data['servoAngle'] != null ? data['servoAngle'] : servoAngleDefault,
      timeDelay:
          data['timeDelay'] != null ? data['timeDelay'] : timeDelayDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepper1': stepper1,
        'stepper2': stepper2,
        'stepper3': stepper3,
        'servoAngle': servoAngle,
        'timeDelay': timeDelay,
      };
}
