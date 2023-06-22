//Servo
#include <Servo.h>
Servo myservo1;  // create servo object to control a servo
#define servoPin1 13
int pos = 0;    // variable to store the servo position

//Stepper
const int DIR1 = 12;
const int STEP1 = 14;
bool isStepper1Rotate = false;
const int DIR2 = 27;
const int STEP2 = 26;
bool isStepper2Rotate = false;
const int DIR3 = 25;
const int STEP3 = 2;  
bool isStepper3Rotate = false;
const int  steps_per_rev = 200;

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
#define WIFI_SSID "poco"
#define WIFI_PASSWORD "pocopoco"
// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino
/* 2. Define the API Key */
#define API_KEY "AIzaSyCZRnQ0MHXxdFRXMqkibTiT4FfUBLpjm50"
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://nutmeg-9414e-default-rtdb.asia-southeast1.firebasedatabase.app/ " //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app
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
  FirebaseJsonData stepper1Rotate;
  FirebaseJsonData stepper2Rotate;
  FirebaseJsonData stepper3Rotate;
  FirebaseJsonData servoAngle;

  jVal.get(stepper1Rotate, "stepper1");
  jVal.get(stepper2Rotate, "stepper2");
  jVal.get(stepper3Rotate, "stepper3");
  jVal.get(servoAngle, "servoAngle");


  if (stepper1Rotate.success)
  {
    Serial.println("Success data stepper1Rotate");
    bool value = stepper1Rotate.to<bool>(); 
    isStepper1Rotate = value;  
  } 

    if (stepper2Rotate.success)
  {
    Serial.println("Success data stepper2Rotate");
    bool value = stepper2Rotate.to<bool>(); 
    isStepper2Rotate = value;  
  } 

    if (stepper3Rotate.success)
  {
    Serial.println("Success data stepper3Rotate");
    bool value = stepper3Rotate.to<bool>(); 
    isStepper3Rotate = value;  
  } 

  if (servoAngle.success)
  {
    Serial.println("Success data servoAngle");
    int value = servoAngle.to<int>();   
    myservo1.write(value);
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
  myservo1.write(100);

  //Stepper
  pinMode(STEP1, OUTPUT);
  pinMode(DIR1, OUTPUT);
  pinMode(STEP2, OUTPUT);
  pinMode(DIR2, OUTPUT);
  pinMode(STEP3, OUTPUT);
  pinMode(DIR3, OUTPUT);

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
  steppr1Rotate();
  steppr2Rotate();
  steppr3Rotate();  
}

void updateData(){
  if (Firebase.ready() && ((irCurrentReading != isIr) || (millis() - sendDataPrevMillis > 5000 || sendDataPrevMillis == 0)))
  {
    irCurrentReading = isIr;
    sendDataPrevMillis = millis();
    FirebaseJson json;
    json.set("isIr", isIr);
    json.set(F("ts/.sv"), F("timestamp"));
    Serial.printf("Set json... %s\n", Firebase.RTDB.set(&fbdo, path.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    Serial.println("");
  }
}


void steppr1Rotate(){
  digitalWrite(DIR1, HIGH);
  if(isStepper1Rotate)
  {
    for(int i = 0; i<200; i++)
    {
      digitalWrite(STEP1, HIGH);
      delayMicroseconds(4000);
      digitalWrite(STEP1, LOW);
      delayMicroseconds(4000);
    }
  }
}

void steppr2Rotate(){
  digitalWrite(DIR2, HIGH);
  if(isStepper2Rotate)
  {
    for(int i = 0; i<200; i++)
    {
      digitalWrite(STEP2, HIGH);
      delayMicroseconds(2000);
      digitalWrite(STEP2, LOW);
      delayMicroseconds(2000);
    }
  }
}

void steppr3Rotate(){
  digitalWrite(DIR3, HIGH);
  if(isStepper3Rotate)
  {
    for(int i = 0; i<200; i++)
    {
      digitalWrite(STEP3, HIGH);
      delayMicroseconds(2000);
      digitalWrite(STEP3, LOW);
      delayMicroseconds(2000);
    }
  }
}