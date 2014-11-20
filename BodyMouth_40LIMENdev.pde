import SimpleOpenNI.*;
import beads.*;
import java.util.Arrays; 

// Global flags
boolean debug = false;


//RobotUI ui; 
String mode;
/* Different modes :
 "scanning"  // robot eyes "scanning"
 "userDetect" // onNewUser() - display bodymap - looking for psi - "Surrender Body!"
 "psyDetect"; // onStartPose() - found PSI and attempt skel traking - "Reading Psi"
 "tracking" // playback lips - main mode - successful skel track
 "trackingFail" // failed to initialise skeleton
 "lostUser" //onLostUser() - "Body Gone!"
*/


//Kinect Globals
SimpleOpenNI  kinect;

//scene
int[] sceneMap;

// Audio globals
AudioContext audio;
SamplePlayer samplePlayer;
String sourceFile; // audio source
Gain sampleGain;
Glide gainValue;
Glide rateValue;

Lips lips;

//scanning squares
int[] squares = new int[20];

// Movement stream change parameters
float lastLHand = 0;
float lastRHand = 0;
float lastLFoot = 0;
float lastRFoot = 0;
float lHandChange = 0;
float rHandChange = 0;
float lFootChange = 0;
float rFootChange = 0;
float meanLHandChange = 0;
float meanRHandChange = 0;
float meanLFootChange = 0;
float meanRFootChange = 0;
float meanChangeTotal = 0;

float lHandDistance = 0;
float rHandDistance = 0;
float lFootDistance = 0;
float rFootDistance = 0;

//automatically launch fullScreen. Don't need to use "presentation" mode
boolean sketchFullScreen(){
   return true;
}

void setup()
{
  // instantiate a new kinect
  kinect = new SimpleOpenNI(this);

  // enable depthMap generation 
  kinect.enableDepth();
  kinect.enableScene();

  // enable skeleton generation for all joints
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.setMirror(true);

  background(0, 0, 0);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  //ui = new RobotUI();
  //display and optimization
  
  // create a window the size of the depth information
  size(kinect.depthWidth(), kinect.depthHeight()); 
  
  // get rid of the grey background in Sketch->Present mode.
  ((javax.swing.JFrame)frame).getContentPane().setBackground(java.awt.Color.black);

  //to stop the "stop" button from showing, cover it from the projector
  //run.present.stop.bgcolor=#000000;

  //default is 60;
  frameRate(30);
  
  mode = "scanning";
  //init display squares
  for(int i = 0; i < squares.length; i++){
    squares[i] = 0;
  }



  ///// AUDIO ///////

  audio = new AudioContext();

  //sourceFile = sketchPath("") + "german.mp3";
  //  sourceFile = sketchPath("") + "PeopleEveryday.mp3";
   sourceFile = sketchPath("") + "amIReadyFullText.mp3";
  //safely load the file
  try {
    // initialize our SamplePlayer, loading the file
    // indicated by the sourceFile string
    samplePlayer = new SamplePlayer(audio, new Sample(sourceFile));
  }
  catch(Exception e)
  {
    // If there is an error, show an error message
    // at the bottom of the processing window.
    println("Exception while attempting to load sample!");
    e.printStackTrace(); // print description of the error
    exit(); // and exit the program
  }

  //we want it loop
  samplePlayer.setKillOnEnd(false);
  samplePlayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

  //playback rate
  rateValue = new Glide(audio, 1, 30); 
  samplePlayer.setRate(rateValue);

  gainValue = new Glide(audio, 0.0, 30);
  sampleGain = new Gain(audio, 1, gainValue);
  sampleGain.addInput(samplePlayer);

  audio.out.addInput(sampleGain);
  //audio.start();  start on detection
  
  //Lips - set position
  lips = new Lips(width/2,89); 
}



void draw()
{
  
  // update the camera
  kinect.update();

  // draw depth image
  if (debug){
    //image(kinect.depthImage(), 0, 0); 
    image(kinect.sceneImage(), 0, 0); 
  }
  
  if (mode == "scanning"){
    displayScanningEyes();
  }

  //Look for detection
  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    
    sceneMap = kinect.getUsersPixels(SimpleOpenNI.USERS_ALL);
    
    if(mode == "userDetect" || mode == "psyDetect"){ //begin calibration      
      // populate the pixels arrayf rom the sketch's current contents load full set of black background
      background(0);
      loadPixels(); 
      for (int i = 0; i < sceneMap.length; i++) { 
        // if the current pixel is on a user
        if (sceneMap[i] != 0) {
          // make it grey
          pixels[i] = color(111); 
        }
      }
      // display the changed pixel array
      updatePixels(); 
      //robotText("Sync Body <--> Mind");
    }
    
    int i = userList.get(0);
    
    // check if the skeleton is being tracked
    if (kinect.isTrackingSkeleton(i))
    {
      if(debug){
        // draw the skeleton
        drawSkeleton(i);  
      }
     
      // UPDATE LIMBS
      // return the (normalised?) vector from the torso to a limb
      PVector lHandVector = new PVector();
      PVector rHandVector = new PVector();
      PVector lFootVector = new PVector();
      PVector rFootVector = new PVector();
      PVector torsoVector = new PVector();
      float confidenceLH = kinect.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HAND, lHandVector);
      float confidenceRH = kinect.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HAND, rHandVector);
      float confidenceLF = kinect.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_FOOT, lFootVector);
      float confidenceRF = kinect.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_FOOT, rFootVector);
      float confidenceT = kinect.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_TORSO, torsoVector);
      
      //count lost limbs
      int lostLimb = 0;
      
      if(confidenceLH > 0.5){
        lHandVector.sub(torsoVector);
        lHandVector.normalize();
        updateLHDistance(i);
        //don't touch these numbers, Lips is scaled to them
        float lHandLip = map(lHandDistance, 0, 2000, 0, 200);
        lHandVector.mult(lHandLip);
        lips.transLH(lHandVector);
        //lips.transLimb(rHandVector);
      }else{
        println("LH not confident: " + confidenceLH);
        lHandChange = 0;
        lostLimb++;
      }
      if(confidenceRH > 0.5){
        rHandVector.sub(torsoVector);
        rHandVector.normalize();
        updateRHDistance(i);
        //don't touch these numbers, Lips is scaled to them
        float rHandLip = map(rHandDistance, 0, 2000, 0, 200);
        rHandVector.mult(rHandLip);
        lips.transRH(rHandVector);
      }else{
        println("RH not confident: " + confidenceRH);
        rHandChange = 0;
        lostLimb++;
      }     
      ///FEET!!      
      if(confidenceLF > 0.5){
        lFootVector.sub(torsoVector);
        lFootVector.normalize();
        //because of mirroring
        lFootVector.y = lFootVector.y * -1;
        updateLFDistance(i);
        //don't touch these numbers, Lips is scaled to them
        float lFootLip = map(lFootDistance, 86, 2000, 0, 303);
        lFootVector.mult(lFootLip);
        lips.transLF(lFootVector);
     // println("lFoot:("+lFootVector.x+","+lFootVector.y);
     // println("lFootScale("+lFootVector.x+","+lFootVector.y);     
      }else{
          println("LF not confident: " + confidenceLF);
          lFootChange = 0;
          lostLimb++;
      }
      if(confidenceRF > 0.5){
        rFootVector.sub(torsoVector);
        rFootVector.normalize();
        //because of mirroring 
        rFootVector.y = rFootVector.y * -1;
        updateRFDistance(i);
        //don't touch these numbers, Lips is scaled to them
        float rFootLip = map(rFootDistance, 86, 2000, 0, 303);
        rFootVector.mult(rFootLip);
        lips.transRF(rFootVector);
      }else{
          println("RF not confident: " + confidenceRF);
          rFootChange = 0;
          lostLimb++;
      }

      if(lostLimb > 3){
            //user lost, return to scanning and stop the audio
            kinect.stopTrackingSkeleton(i);
            mode = "scanning";
            println(mode);
            rateValue.setValue(0);
      }else{
        //clear out the scene map and add lips
        background(0);
        lips.display();
      
        //robotTextFade("Body Mapped");
        
        //////AUDIO/////      
        //set the gain based on total "size"
        float avgHandsD = (lHandDistance + rHandDistance) * 0.5;
        float avgFeetD = (lFootDistance + rFootDistance) * 0.5;
        //need to scale
        float avgTotalDistance =  (lHandDistance + rHandDistance + lFootDistance + rFootDistance) * 0.25;
        gainValue.setValue(  map(avgTotalDistance, 626, 1812, 1.1, 4.8)  );
        
        //map(incoming value, distanceStart, distanceEnd, gainFloor, gainRoof)
        float avgHandC = (meanLHandChange + meanRHandChange) * 0.5;
        float avgFeetC = (meanLFootChange + meanRFootChange) * 0.5;
        
        //from test avgHangsChangePeak = 308, FeetChange = 511, hand distance = 860, feet distance = 1227
        meanChangeTotal = (meanLHandChange + meanRHandChange + meanLFootChange + meanRFootChange) / 4;      
  
        //if there's not enough movement, stop the track
        if (meanChangeTotal < 11) {
          rateValue.setValue(0);
        }
        else {
          float playSpeed = map(meanChangeTotal, 11, 596, 0.74, 1.15);
          rateValue.setValue(playSpeed);
        }
        ///END SOUND///      
      }

      
      if(debug){      
        // show the parameters on screen
        stroke(255,255,255);
        textSize(16);
        int textDisplay = 400;
        //formatted vector values
        String sHands = "lHandVector: (" + nf(lHandVector.x,3,1) + ", " + nf(lHandVector.y,3,1) + ")   rHandVector: (" + nf(rHandVector.x,3,1) + " , " + nf(rHandVector.y,3,1);
        String sFeet = "lFootVector: (" + nf(lFootVector.x,3,1) + " , " + nf(lFootVector.y,3,1) + ")   rFootVector: (" + nf(rFootVector.x,3,1) + " , " + nf(rFootVector.y,3,1);
        String sHMags = "lHandDistance: " + nf(lHandDistance,3,1) + "  rHandDistance: " + nf(rHandDistance,3,1);
        String sFMags = "lFootDistance: " + nf(lFootDistance,3,1) + "  rFootDistance: " + nf(rFootDistance,3,1);
        //text("meanChangeTotal: " + meanChangeTotal, 100, textDisplay);
        text(sHands, 100, textDisplay);
        text(sFeet, 100, textDisplay +20);  
        text(sHMags, 100, textDisplay+40);
        text(sFMags, 100, textDisplay+60);
        //text("AvgHandChange: " + avgHandC + " AvgFeetChange: " + avgFeetC, 100, textDisplay+80);
        //text("rHandDistance: " + rHandDistance, 100, textDisplay+80);
        //text("Change in rHand: " + rHandChange, 100, textDisplay+100);
        //text("Avg. Change in rHand: " + meanRHandChange, 100, textDisplay+120);
        // instantiate the rect depths to 0
        float lHandRect = map(lHandDistance, 0, 2000, 0, height);
        float rHandRect = map(rHandDistance, 0, 2000, 0, height);
        float lFootRect = map(lFootDistance, 0, 2000, 0, height);
        float rFootRect = map(rFootDistance, 0, 2000, 0, height);    
        rect(10, 10, 50, lHandRect);
        rect(kinect.depthWidth() - 60, 10, 50, rHandRect);
        rect(10, kinect.depthHeight() - lFootRect, 50, kinect.depthWidth() - 10);
        rect(kinect.depthWidth() - 60, kinect.depthHeight() - rFootRect, 50, kinect.depthWidth() - 10);
      }

    }//end skel tracking loop
  }//end user detected
  else{ //no users detected, must be scanning
    mode = "scanning";
    println("bottom loop, mode = scanning");
  }
  if(debug){
      stroke(0,255,0,255);
      textSize(25);
      text("MODE:"+mode, 100, 20);
  }
    
}//end draw()

void robotText(String output){
  stroke(0,255,0);
  strokeWeight(30);
  textSize(46);
  float textX = textWidth(output);
  //todo: set font to something "robot"?
  text(output, kinect.depthWidth()/2 - textX/2, 404);

}


//quick and dodgy way to get the confidence of limbs working
void updateLHDistance(int userID){
      // get the distance between joints
      lHandDistance = getJointDistance(userID, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HAND);
      // calculate how much the joint has moved
      lHandChange = abs(lastLHand - lHandDistance);
      // calculate the average speed of the joint
      meanLHandChange = floor((0.5 * meanLHandChange) + (0.5 * lHandChange));
      // store the current distance for use in the next round
      lastLHand = lHandDistance;
}

void updateRHDistance(int userID){
      rHandDistance = getJointDistance(userID, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HAND);
      rHandChange = abs(lastRHand - rHandDistance);
      meanRHandChange = floor((0.5 * meanRHandChange) + (0.5 * rHandChange));    
      lastRHand = rHandDistance;
}

void updateLFDistance(int userID){
      lFootDistance = get2DJointDistance(userID, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_FOOT);
      lFootChange = abs(lastLFoot - lFootDistance);
      meanLFootChange = floor((0.5 * meanLFootChange) + (0.5 * lFootChange));
      lastLFoot = lFootDistance;
}

void updateRFDistance(int userID){
      rFootDistance = get2DJointDistance(userID, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_FOOT);   
      rFootChange = abs(lastRFoot - rFootDistance);
      meanRFootChange = floor((0.5 * meanRFootChange) + (0.5 * rFootChange));    
      lastRFoot = rFootDistance;
}      

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{  
  // draw limbs  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}



// Event-based Methods

// when a person ('user') enters the field of view
void onNewUser(int userId)
{
  println("New User Detected - userId: " + userId);

  mode = "userDetect";
  robotText("Human detected. Surrender Body!");
  // start pose detection
  kinect.startPoseDetection("Psi", userId);
  println("onnewUser: set mode = userDetect");
}

// when a person ('user') leaves the field of view 
void onLostUser(int userId)
{
  println("User Lost - userId: " + userId);

  mode = "scanning";
  //song.pause();
}

// when a user begins a pose
void onStartPose(String pose, int userId)
{
  println("Start of Pose Detected  - userId: " + userId + ", pose: " + pose);

  // stop pose detection
  kinect.stopPoseDetection(userId); 
  mode = "psyDetect";

  // start attempting to calibrate the skeleton
  kinect.requestCalibrationSkeleton(userId, true);
}

// when calibration begins
void onStartCalibration(int userId)
{
  println("Beginning Calibration - userId: " + userId);
}

// when calibaration ends - successfully or unsucessfully 
void onEndCalibration(int userId, boolean successfull)
{
  println("Calibration of userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");

    mode = "tracking";
    // begin skeleton tracking
    kinect.startTrackingSkeleton(userId); 

    // play our song or sound effect
    audio.start();
    println("playing song, mode = tracking");
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    // Start pose detection
    kinect.startPoseDetection("Psi", userId);
    
    //mode = "trackingFail";
  }
}


///////DISTANCES/////


// prints out the distance between any two joints 
float getJointDistance(int userId, int joint1Id, int joint2Id)
{
  float d;    // to store final distance value

  // two PVectors to hold the position of two joints
  PVector joint1 = new PVector();
  PVector joint2 = new PVector();

  // get 3D position of both joints
  kinect.getJointPositionSkeleton(userId, joint1Id, joint1);
  kinect.getJointPositionSkeleton(userId, joint2Id, joint2);

  d = distance3D(joint1, joint2);    // calcualte the distance between the two joints

  return d;
}

// calculate the distance between any two points in 3D space and return it as a float
float distance3D(PVector point1, PVector point2)
{
  float diff_x, diff_y, diff_z;    // to store differences along x, y and z axes
  float distance;                  // to store final distance value

    // calculate the difference between the two points
  diff_x = point1.x - point2.x;
  diff_y = point1.y - point2.y;
  diff_z = point1.z - point2.z; 

  // calculate the Euclidean distance between the two points
  distance = sqrt(pow(diff_x, 2)+pow(diff_y, 2)+pow(diff_z, 2));

  return distance;  // return the distance as a float
}

// prints out the distance between any two joints 
float get2DJointDistance(int userId, int joint1Id, int joint2Id)
{
  float d;    // to store final distance value

  // two PVectors to hold the position of two joints
  PVector joint1 = new PVector();
  PVector joint2 = new PVector();

  // get 3D position of both joints
  kinect.getJointPositionSkeleton(userId, joint1Id, joint1);
  kinect.getJointPositionSkeleton(userId, joint2Id, joint2);

  d = distance2D(joint1, joint2);    // calcualte the distance between the two joints in 2D

  return d;
}


// calculate the distance between any two points in 3D space and return it as a float
float distance2D(PVector point1, PVector point2)
{
  float diff_x, diff_y;    // to store differences along x, y and z axes
  float distance;                  // to store final distance value

    // calculate the difference between the two points
  diff_x = point1.x - point2.x;
  diff_y = point1.y - point2.y;

  // calculate the Euclidean distance between the two points
  distance = sqrt(pow(diff_x, 2)+pow(diff_y, 2));

  return distance;  // return the distance as a float
}


void displayScanningEyes(){
  
  background(0);
  //starting offset for squares row
  //int squaresX = 193; //find the center
  int squareSide = 10;
  int squaresX = kinect.depthWidth()/2 - (squareSide * squares.length)/2;
  int squaresY = 86;

  // Highlight current sin square
  int sinHighlight = floor(map(sin(frameCount*3.1), -1, 1, 0, squares.length));
  if(sinHighlight != squares.length){
    squares[sinHighlight] = 255;
  }
  
  //fade all squares
  for(int i = 0; i < squares.length; i++){
    squares[i] = squares[i] - 15;
  }

  //draw squares
  strokeWeight(2);
  stroke(73);
  for(int i = 0; i < squares.length; i++){
      fill(255, 0, 0, squares[i]);
      rect(squaresX + (10 * i), squaresY, squareSide, squareSide);   
  }
  //also picking up last fade effect
  robotText("Scanning");

}


