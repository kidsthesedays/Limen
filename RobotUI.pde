
//doesn't really work or in use
class RobotUI {

  //constructor
  RobotUI(){
    mode = 0;   
  }

  int[] scanArray = new int[8];  

 
  int mode;
  /*
  static int SCANNING = 0;  // robot eyes "scanning"
  static int USERDETECTED = 1; // onNewUser() - display bodymap - looking for psi - "Surrender Body!"
  static int PSY_CALIBRATE = 2; // onStartPose() - found PSI and forming skelington - "Reading Psi"
  static int TRACKING = 3; // playback lips - main mode
  static int LOSTUSER = 4; //onLostUser() - "Body Gone!"
  */
  
  
  //sine wave
  
  void updateMode(int newMode){
    mode = newMode;
  }
  
  //display according to which mode we're in
  void display(){
  
    if(mode == 0){ //SCANNING
    }else if (mode == 1){    //USERDETECTED
    }else if (mode == 2){    //PSY_CALIBRATE
    }else if (mode == 3){   //TRACKING
      lips.display();
    }else if (mode == 4){    //LOSTUSER
    }
    
  }

}


void scanning(){
  //array of squares colored in HSB mode 
  // then reduce the Brightness by 1, every frame % hardNumber
  // use a sine wave to choose between the elements in the array
  
}

