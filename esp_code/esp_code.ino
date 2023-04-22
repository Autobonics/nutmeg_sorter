//Servo
#include <Servo.h>
Servo myservo1;  // create servo object to control a servo
Servo myservo2;  // create servo object to control a servo
#define servoPin1 13
#define servoPin2 32
int pos = 0;    // variable to store the servo position

//Stepper
const int DIR = 12;
const int STEP = 14;
const int  steps_per_rev = 200;
bool isStepperRotate = false;

//IR LED
#define irPin 15

//WiFi
#define wifiLedPin 2

//Firebase
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
// Provide the token generation process info.
#include <addons/TokenHelper.h>
// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>
/* 1. Define the WiFi credentials */
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino
/* 2. Define the API Key */
#define API_KEY "AIzaSyBujIYAU6YiX1kd69HqeY9exU1GeCePLkc"
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://ring-sorting-machine-default-rtdb.asia-southeast1.firebasedatabase.app/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app
/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "device@autobonics.com"
#define USER_PASSWORD "12345678"
// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
unsigned long sendDataPrevMillis = 0;
// Variable to save USER UID
String uid;
//Databse
String path;


unsigned long printDataPrevMillis = 0;

FirebaseData stream;
void streamCallback(StreamData data)
{
  Serial.println("NEW DATA!");

  String p = data.dataPath();

  Serial.println(p);
  printResult(data); // see addons/RTDBHelper.h

  // Serial.println();
  FirebaseJson jVal = data.jsonObject();
  FirebaseJsonData stepperRotate;
  FirebaseJsonData flapAngle;
  FirebaseJsonData rotateAngle;

  jVal.get(stepperRotate, "stepper");
  jVal.get(flapAngle, "flapAngle");
  jVal.get(rotateAngle, "rotateAngle");


  if (stepperRotate.success)
  {
    Serial.println("Success data stepperRotate");
    bool value = stepperRotate.to<bool>(); 
    isStepperRotate = value;  
    // if(value){
    //   stepprRotate();
    // } else {
    //   stepperStop();
    // }
  } 

  if (flapAngle.success)
  {
    Serial.println("Success data flapAngle");
    int value = flapAngle.to<int>();   
    myservo1.write(value);
  }  
  if (rotateAngle.success)
  {
    Serial.println("Success data rotateAngle");
    int value = rotateAngle.to<int>();   
    myservo2.write(value);
  }  

}


void streamTimeoutCallback(bool timeout)
{
  if (timeout)
    Serial.println("stream timed out, resuming...\n");

  if (!stream.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream.httpCode(), stream.errorReason().c_str());
}



void setup() {

  Serial.begin(115200);
 
  //Servo
  myservo1.attach(servoPin1);
  myservo2.attach(servoPin2);
  myservo1.write(100);
  myservo2.write(180);

  //Stepper
  pinMode(STEP, OUTPUT);
  pinMode(DIR, OUTPUT);

  //IR
  pinMode(irPin, INPUT);
 
  //WIFI
  pinMode(wifiLedPin, OUTPUT);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  unsigned long ms = millis();
  while (WiFi.status() != WL_CONNECTED)
  {
    digitalWrite(wifiLedPin, LOW);
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  digitalWrite(wifiLedPin, HIGH);
  Serial.println(WiFi.localIP());
  Serial.println();

  //FIREBASE
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Limit the size of response payload to be collected in FirebaseData
  fbdo.setResponseSize(2048);

  Firebase.begin(&config, &auth);

  // Comment or pass false value when WiFi reconnection will control by your code or third party library
  Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);

  config.timeout.serverResponse = 10 * 1000;

  // Getting the user UID might take a few seconds
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

  path = "devices/" + uid + "/reading";

//Stream setup
  if (!Firebase.beginStream(stream, "devices/" + uid + "/data"))
    Serial.printf("sream begin error, %s\n\n", stream.errorReason().c_str());

  Firebase.setStreamCallback(stream, streamCallback, streamTimeoutCallback);
}

bool isIr = false;
bool irCurrentReading = false;

void loop() {
  isIr = digitalRead(irPin);
  updateData();  
  stepprRotate();
}

void updateData(){
  if (Firebase.ready() && ((irCurrentReading != isIr) || (millis() - sendDataPrevMillis > 5000 || sendDataPrevMillis == 0)))
  {
    irCurrentReading = isIr;
    sendDataPrevMillis = millis();
    FirebaseJson json;
    json.set("isRing", isIr);
    json.set(F("ts/.sv"), F("timestamp"));
    Serial.printf("Set json... %s\n", Firebase.RTDB.set(&fbdo, path.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    Serial.println("");
  }
}


void stepprRotate(){
  digitalWrite(DIR, HIGH);
  // Serial.println("Spinning Clockwise...");
  // for(int i = 0; i<steps_per_rev; i++)
  // {
  //   digitalWrite(STEP, HIGH);
  //   delayMicroseconds(3500);
  //   digitalWrite(STEP, LOW);
  //   delayMicroseconds(3500);
  // }
   if(isStepperRotate)
  {
    digitalWrite(STEP, HIGH);
    delayMicroseconds(3500);
    digitalWrite(STEP, LOW);
    delayMicroseconds(3500);
  }
}

void stepperStop(){
  digitalWrite(STEP, LOW);
}

void closeFlap(){
  myservo1.write(40);
}

void openFlap(){
  myservo1.write(100);
}

void straitPosition(){
  myservo2.write(180);
}

void rotatedPosition(){
  myservo2.write(0);
}

void dropLeftPosition(){
  myservo2.write(45);
}

void dropRightPosition(){
  myservo2.write(135);
}