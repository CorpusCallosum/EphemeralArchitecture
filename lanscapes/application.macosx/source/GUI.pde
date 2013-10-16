// functions for setting up our controlP5 GUI and the Nav3D 
// camera controller. to receive mouse wheel events we have to 
// do a little Java magic, such as implementing the
// java.awt.event.MouseWheelListener interface (see end of this
// tab.)

int _x, _y, _z;

void initControllers() {
  //_x = width/2;
  //_y = 500;//height/2;
  //_z = -3000;
  //nav = new UNav3D(this); 
  //nav.trans.set(_x, _y, _z);
  //nav.rot.set(10*PI/12, 0, 0);

  // create a listener for mouse wheel events
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(color(0, 0, 0));


  //Z SHIFT
  Z = 3000;
  controlP5.addSlider("Z", // name, must match variable name 
  5, 4000, // min and max values 
  Z, // the default value
  20, 40, // X,Y position of slider
  100, 13); // width and height of slider

  //BRIGHTNESS
  _brightness=-10;
  controlP5.addSlider("_brightness", // name, must match variable name
  -200, 200, // min and max values
  _brightness, // the default value
  20, 60, // X,Y position of slider
  500, 13); // width and height of slider

  //CONTRAST
  _contrast=99;
  controlP5.addSlider("_contrast", // name, must match variable name
  -200, 200, // min and max values
  _contrast, // the default value
  20, 80, // X,Y position of slider
  500, 13); // width and height of slider
  
  //SATURATION
  _sat=200;
  controlP5.addSlider("_sat", // name, must match variable name
  0, 255, // min and max values
  _sat, // the default value
  20, 100, // X,Y position of slider
  500, 13); // width and height of slider

  // add a "bang" input, a button that triggers a custom function.
  // we'll use it to regenerate the mesh
  //  controlP5.addBang("generateMesh",20,20,20,20);

  //controlP5.addBang("saveSTL", 220, 20, 20, 20);

  // add toggle switch
  controlP5.addToggle("toggleSolid", 300, 20, // X,Y position 
  20, 20); // width and height
  controlP5.setAutoDraw(false);
  
}

// catch ControlP5 events to force rebuilding the mesh
void controlEvent(ControlEvent theEvent) {
  generateMesh();
}


// pass mouse and key events to our Nav3D instance
void mouseDragged() {
  // ignore mouse event if cursor is over controlP5 GUI elements
  if (controlP5.window(this).isMouseOver()) return;

  //nav.mouseDragged();
}

void keyPressed() {
  
  //nav.keyPressed();

  if (key == ' ') {
    //load image as mesh
    img = modifiedImg;
    generateMesh(); // initialize mesh surface, see "Terrain"
  }
  else if (key == 'k') {
    //draw the kinect image
    drawKinect = !drawKinect;
  }
  else if (key == 'd') {
    //draw the kinect image
    _debug = !_debug;
    if(_debug){
     cursor(); 
    }
    else{
     noCursor(); 
    }
  }
  else if (key == 'o') {
   println("transX: " + transX + ", transY: " + transY + ", transZ: " + transZ);
   println("rotX: " + rotX + ", rotY: " + rotY + ", rotZ: " + rotZ);
  }
  else if (key == 'w') {
   toggleSolid = !toggleSolid;
  }
  else if (key == 't') {
   _transparent = !_transparent;
  }
   else if (key == 'l') {
   _drawLines = !_drawLines;
  }
  else if (key == 'm') {
   _blendMode = !_blendMode;
  }
   else if (key == 's') {
    //save stl
    saveSTL();
    saveDepthMap();
   }
    else if (key == 'c') {
    loadColor();
   }
   
   //translate
    else if (key == '=') {
      //zoom in
      transZ +=50;
   }
   else if (key == '-') {
      //zoom out
      transZ -= 50;
   }
    else if (key == '7') {
      //down
      transY += 50;
    }
    else if (key == '8') {
      //up
      transY -= 50;
   }
   else if (key == '9') {
      //left
      transX -= 50;
   }
   else if (key == '0') {
      //right
      transX += 50;
   }
   
   
   //rotation
       else if (key == '1') {
      //zoom in
      rotZ -= PI / 12;
   }
   else if (key == '2') {
      //zoom out
     rotZ += PI / 12;
   }
    else if (key == '3') {
      //up
      rotY -= PI / 12;
   }
   else if (key == '4') {
      //right
      rotY += PI / 12;
   }
   else if (key == '5') {
      //left
      rotX -= PI / 12;
   }
   else if (key == '6') {
      //down
      rotX += PI / 12;
   }
  
}

void trans(int x, int y, int z){
  _x = x;
  _y = y;
  _z = z;
  //nav.trans.set(_x, _y, _z);
}