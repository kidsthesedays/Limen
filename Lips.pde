class Lips {

  //center points for top and bottom lips... 
  PVector topCenter;
  PVector bottomCenter;

  //Raw values for the hand mappings
  PVector lHand;
  PVector rHand;
  PVector lFoot;
  PVector rFoot;
  
  //Anchor for lower lip to leg subtraction
  PVector lAnchor;
  PVector rAnchor;
  
  Boolean debug = false;
  Boolean showOriginal = false;
  Boolean showLimbVectors = false;


  void display() {
    this.displayBottom();
    this.displayTop();
  }
  
  //for now just use the property
  void transLH(PVector limb){
      this.lHand = limb;
  }
  void transRH(PVector limb){
      this.rHand = limb;
  }
  void transLF(PVector limb){
      this.lFoot = limb;
      lFoot.sub(lAnchor);
  }
  void transRF(PVector limb){
      this.rFoot = limb;
      rFoot.sub(rAnchor);
  }
  /*
  void transLimb(PVector limb, int limbID){
    if (limbID == SimpleOpenNI.SKEL_LEFT_HAND){
      this.lHand = limb;
    }//etc
  }
  */

  void displayTop() {

   //uFP = upper fixed point of the curve
   //uCP = upper control point
    PVector uFP1 = new PVector(0,35);
    PVector uFP2 = new PVector(116,19);
    PVector uFP3 = new PVector(147,76);
    PVector uFP4 = new PVector(0,89);
    PVector uFP5 = new PVector(-147,76);
    PVector uFP6 = new PVector(-116,19);
    PVector uFP7 = new PVector(0,35);
   
    PVector uCP11 = new PVector(7,-17);
    PVector uCP12 = new PVector(60,3);
    PVector uCP22 = new PVector(191,44);
    PVector uCP23 = new PVector(201,55);
    PVector uCP33 = new PVector(82,88);
    PVector uCP34 = new PVector(19,86);
    PVector uCP44 = new PVector(-19,86);
    PVector uCP45 = new PVector(-82,88);
    PVector uCP55 = new PVector(-201,55);
    PVector uCP56 = new PVector(-191,44);
    PVector uCP66 = new PVector(-60,3);
    PVector uCP67 = new PVector(-7,-17);
  
    //lHand.y =0;    lHand.x =0;     rHand.y =0;    rHand.x =0;
    
    //Center top

    uCP67.x = uCP67.x + (lHand.x * 0.44 + rHand.x * 0.22)/2;   //lhand22
    uCP67.y = uCP67.y - (lHand.y * 1.30 + rHand.y * 0.40)/2;   //lhand 0.65

    uFP1.x = uFP1.x + (lHand.x * 0.4 + rHand.x * 0.4)/2;    
    uFP1.y = uFP1.y - (lHand.y * 1.0 + rHand.y * 1.0)/2;    
    uFP7.x = uFP7.x + (lHand.x * 0.4 + rHand.x * 0.4)/2;    
    uFP7.y = uFP7.y - (lHand.y * 1.0 + rHand.y * 1.0)/2;    

    uCP11.x = uCP11.x + (lHand.x * 0.22 + rHand.x * 0.44)/2; 
    uCP11.y = uCP11.y - (lHand.y * 0.40 + rHand.y * 1.30)/2;
 
    //top right
    uCP12.x = uCP12.x + rHand.x * 0.42;
    uCP12.y = uCP12.y - rHand.y * 0.89;
    uFP2.x = uFP2.x + rHand.x * 0.7;
    uFP2.y = uFP2.y - rHand.y * 1.2;
    
    //top left
    uFP5.x = uFP5.x + lHand.x * 0.70;
    uFP5.y = uFP5.y - lHand.y * 1.50;
    uCP45.x = uCP45.x + lHand.x * 0.4;
    uCP45.y = uCP45.y - lHand.y * 0.9;

    //right edge
    uCP22.x = uCP22.x + rHand.x * 0.92;
    uCP22.y = uCP22.y - rHand.y * 1.72;    
    uCP23.x = uCP23.x + rHand.x * 0.93;
    uCP23.y = uCP23.y - rHand.y * 1.92;

    //left edge
    uCP56.x = uCP56.x + lHand.x * 0.92;
    uCP56.y = uCP56.y - lHand.y * 1.72;
    uCP55.x = uCP55.x + lHand.x * 0.93;
    uCP55.y = uCP55.y - lHand.y * 1.92;

    //bottom right
    uFP3.x = uFP3.x + rHand.x * 0.70;
    uFP3.y = uFP3.y - rHand.y * 1.50;
    uCP33.x = uCP33.x + rHand.x * 0.40;
    uCP33.y = uCP33.y - rHand.y * 0.91;    

    //center bottom
    uCP34.x = uCP34.x + (lHand.x * 0.25 + rHand.x * 1.3)/2;
    uCP34.y = uCP34.y - (lHand.y * 0.30 + rHand.y * 2.0)/2;    
    uFP4.x = uFP4.x + (lHand.x * 0.83 + rHand.x * 0.83)/2;
    uFP4.y = uFP4.y - (lHand.y * 1.06 + rHand.y * 1.06)/2;    
    uCP44.x = uCP44.x + (lHand.x * 1.3 + rHand.x * 0.25)/2;
    uCP44.y = uCP44.y - (lHand.y * 2.0 + rHand.y * 0.30)/2;

    //bottom left
    uFP6.x = uFP6.x + lHand.x * 0.70;
    uFP6.y = uFP6.y - lHand.y * 1.20;
    uCP66.x = uCP66.x + lHand.x * 0.41;
    uCP66.y = uCP66.y - lHand.y * 0.89;

        
    
    //translate lip vectors
    pushMatrix();
    translate(topCenter.x, topCenter.y);
    
    if(debug){
      noFill();
    }else{
      fill(255,0,0);
    }

    strokeWeight(2);
    stroke(255,255,255);
   
    beginShape();
    vertex(                            uFP1.x , uFP1.y); //top center right
    bezierVertex( uCP11.x, uCP11.y, uCP12.x, uCP12.y, uFP2.x, uFP2.y); //top right
    bezierVertex( uCP22.x, uCP22.y, uCP23.x, uCP23.y, uFP3.x, uFP3.y); //top right
    bezierVertex( uCP33.x, uCP33.y, uCP34.x, uCP34.y, uFP4.x, uFP4.y); //top right
    bezierVertex( uCP44.x, uCP44.y, uCP45.x, uCP45.y, uFP5.x, uFP5.y); //top right
    bezierVertex( uCP55.x, uCP55.y, uCP56.x, uCP56.y, uFP6.x, uFP6.y); //top right
    bezierVertex( uCP66.x, uCP66.y, uCP67.x, uCP67.y, uFP7.x, uFP7.y); //top right
    endShape();
    
    if(debug){
      ellipseMode(CENTER);
      strokeWeight(1);
      stroke(255,0,6);
      textSize(10);
      text("11", uCP11.x, uCP11.y);
      text("12", uCP12.x, uCP12.y);
      text("22",uCP22.x, uCP22.y);
      text("23",uCP23.x, uCP23.y);
      text("33",uCP33.x, uCP33.y);
      text("34",uCP34.x, uCP34.y);
      text("44",uCP44.x, uCP44.y);
      text("45",uCP45.x, uCP45.y);
      text("55",uCP55.x, uCP55.y);
      text("56",uCP56.x, uCP56.y);
      text("66",uCP66.x, uCP66.y);
      text("67",uCP67.x, uCP67.y);
      
      stroke(255,0,0);
      text("FP1", uFP1.x, uFP1.y);
      text("FP2", uFP2.x, uFP2.y);
      text("FP3", uFP3.x, uFP3.y);
      text("FP4", uFP4.x, uFP4.y);
      text("FP5", uFP5.x, uFP5.y);
      text("FP6", uFP6.x, uFP6.y);
      text("FP7", uFP7.x, uFP7.y);      
      
      if(showLimbVectors){
        stroke(0,0,255);
        text("LH", lHand.x, lHand.y);
        text("RH", rHand.x, rHand.y);
        line(lHand.x,lHand.y,0,0);
        line(rHand.x,rHand.y,0,0);
      }

      if(showOriginal){
        stroke(0,255,0);
        vertex(                               0, 35); //top center right
        bezierVertex(   7, -17,   60,   3,  116, 19); //top right
        bezierVertex( 191,  44,  201,  55,  147, 76); //bottom right
        bezierVertex(  93,  88, 13.0,  80,    0, 82);//bottom center
        bezierVertex( -15,  80, -116,  92, -166, 76); //bottom left
        bezierVertex(-215,  57, -157,  30, -116, 19); //top left
        bezierVertex( -75,   7,    0, -16,    0, 35); //top center left
        endShape();
      }
    } 
    popMatrix();
  }

  void displayBottom() {
  
    //lower lip points
    PVector lFP1 = new PVector(-185,0);
    PVector lFP2 = new PVector(0,170);
    PVector lFP3 = new PVector(180,0);
    PVector lFP4 = new PVector(0,114);
    PVector lFP5 = new PVector(-185,0);

    PVector lCP11 = new PVector(-165,0);
    PVector lCP12 = new PVector(-112,170);
    PVector lCP22 = new PVector(106,170);
    PVector lCP23 = new PVector(165,0);
    PVector lCP33 = new PVector(165,0);
    PVector lCP34 = new PVector(70,114);
    PVector lCP44 = new PVector(-70,114);
    PVector lCP45 = new PVector(-165,0);
    
    lAnchor = new PVector(-13, 85);
    rAnchor = new PVector(13, 85);
    
    //println("lFoot:("+lFoot.x+","+lFoot.y+ ") rFoot:("+rFoot.x+","+rFoot.y+")");
    //lFoot.y =0;    lFoot.x =0;     
    //rFoot.y =0;    rFoot.x =0;

    //top left
    lFP1.x = lFP1.x + (lFoot.x * 0.50 + rFoot.x * 0.0);
    lFP1.y = lFP1.y + (lFoot.y * 0.36 + rFoot.y * 0.0);
    lFP5.x = lFP5.x + (lFoot.x * 0.50 + rFoot.x * 0.0);
    lFP5.y = lFP5.y + (lFoot.y * 0.36 + rFoot.y * 0.0);

    //bottom left
    lCP11.x = lCP11.x + (lFoot.x * 0.20 + rFoot.x * 0.00);
    lCP11.y = lCP11.y + (lFoot.y * 0.19 + rFoot.y * 0.00);
    lCP12.x = lCP12.x + (lFoot.x * 1.09 + rFoot.x * 0.10);
    lCP12.y = lCP12.y + (lFoot.y * 1.25 + rFoot.y * 0.10);

    //bottom center
    lFP2.x = lFP2.x + (lFoot.x * 1.28 + rFoot.x * 1.28)/2;
    lFP2.y = lFP2.y + (lFoot.y * 1.28 + rFoot.y * 1.28)/2;

    //bottom right
    lCP22.x = lCP22.x + (lFoot.x * 0.10 + rFoot.x * 1.09);
    lCP22.y = lCP22.y + (lFoot.y * 0.10 + rFoot.y * 1.25);
    lCP23.x = lCP23.x + (lFoot.x * 0.00 + rFoot.x * 0.20);
    lCP23.y = lCP23.y + (lFoot.y * 0.00 + rFoot.y * 0.20);

    //top right
    lCP33.x = lCP33.x + (lFoot.x * 0.00 + rFoot.x * 0.22);
    lCP33.y = lCP33.y + (lFoot.y * 0.00 + rFoot.y * 0.22);
    
    lFP3.x = lFP3.x + (lFoot.x * 0.0 + rFoot.x * 0.49);
    lFP3.y = lFP3.y + (lFoot.y * 0.0 + rFoot.y * 0.36);    
   
    //top center
    lCP34.x = lCP34.x + (lFoot.x * 0.10 + rFoot.x * 0.83);
    lCP34.y = lCP34.y + (lFoot.y * 0.00 + rFoot.y * 0.96);
    lFP4.x = lFP4.x + (lFoot.x * 1.11 + rFoot.x * 1.11)/2;
    lFP4.y = lFP4.y + (lFoot.y * 1.11 + rFoot.y * 1.11)/2;   
    lCP44.x = lCP44.x + (lFoot.x * 0.83 + rFoot.x * 0.10);
    lCP44.y = lCP44.y + (lFoot.y * 0.96 + rFoot.y * 0.00);
   
    
    lCP45.x = lCP45.x + (lFoot.x * 0.22 + rFoot.x * 0.00);
    lCP45.y = lCP45.y + (lFoot.y * 0.10 + rFoot.y * 0.00);

    
  
    if(debug){
      noFill();
    }else{
      fill(255,0,0);
    }
    strokeWeight(2);
    stroke(255,255,255);

    pushMatrix();
    translate(bottomCenter.x, bottomCenter.y);    
    beginShape();
    vertex(                            lFP1.x , lFP1.y); //top center right
    bezierVertex( lCP11.x, lCP11.y, lCP12.x, lCP12.y, lFP2.x, lFP2.y);  //bottom center
    bezierVertex( lCP22.x, lCP22.y, lCP23.x, lCP23.y, lFP3.x, lFP3.y); //top right
    bezierVertex( lCP33.x, lCP33.y, lCP34.x, lCP34.y, lFP4.x, lFP4.y); //top center
    bezierVertex( lCP44.x, lCP44.y, lCP45.x, lCP45.y, lFP5.x, lFP5.y); //top left bottom
    endShape();
    
    if(debug){
      ellipseMode(CENTER);
      strokeWeight(1);
      stroke(0,0,255);
      textSize(10);
      text("11",lCP11.x, lCP11.y);
      text("12",lCP12.x, lCP12.y);
      text("22",lCP22.x, lCP22.y);
      text("23",lCP23.x, lCP23.y);
      text("33",lCP33.x, lCP33.y);
      text("34",lCP34.x, lCP34.y);
      text("44",lCP44.x, lCP44.y);
      text("45",lCP45.x, lCP45.y);
      
      stroke(255,0,0);
      text("FP1", lFP1.x, lFP1.y);
      text("FP2", lFP2.x, lFP2.y);
      text("FP3", lFP3.x, lFP3.y);
      text("FP4", lFP4.x, lFP4.y);
      text("FP5", lFP5.x, lFP5.y);

      if(showLimbVectors){
        stroke(0,0,255);
        text("LF", lFoot.x, lFoot.y);
        text("RF", rFoot.x, rFoot.y);
        text("LA", lAnchor.x, lAnchor.y);
        text("RA", rAnchor.x, rAnchor.y);
        line(lFoot.x,lFoot.y,lAnchor.x,lAnchor.y);
        line(rFoot.x,rFoot.y,rAnchor.x,rAnchor.y);
      }
      
      if(showOriginal){
        stroke(0,255,0);
        beginShape();
        vertex(                               -185,   0); // top left
        bezierVertex(-165,   0, -112.0, 185,     0, 185); //top center
        bezierVertex( 106, 185,  165.0,   0, 179.6,   0); //top right
        bezierVertex( 165,   0,   70.0, 114,     0, 114); //bottom center
        bezierVertex( -70, 114, -165.0,   0,  -185,   0); //top left bottom
        endShape();
      }

    }

    
    popMatrix();
  }


  //contructors
  Lips() {
    topCenter = new PVector(0, 0);
    bottomCenter = new PVector(0, 0);
    lHand = new PVector(0,0);
    rHand = new PVector(0,0);
    lFoot = new PVector(0,0);
    rFoot = new PVector(0,0);
  }

  Lips(int topX, int topY, int bottomX, int bottomY) {
    topCenter = new PVector(topX, topY);
    bottomCenter = new PVector(bottomX, bottomY);
    lHand = new PVector(0,0);
    rHand = new PVector(0,0);
    lFoot = new PVector(0,0);
    rFoot = new PVector(0,0);
    lAnchor = new PVector(0,0);
    rAnchor = new PVector(0,0);
    
  }
  
  //hard code offset of bottom lips
  Lips(int topX, int topY) {
    topCenter = new PVector(topX, topY);
    bottomCenter = new PVector(topX, topY + 68);
    lHand = new PVector(0,0);
    rHand = new PVector(0,0);
    lFoot = new PVector(0,0);
    rFoot = new PVector(0,0);
    lAnchor = new PVector(0,0);
    rAnchor = new PVector(0,0);
     
  }


  void setTopCenter(int x, int y) {
    topCenter = new PVector(x, y);
  }

  void setBottomCenter(int x, int y) {
    bottomCenter = new PVector(x, y);
  }
}

