// functions for setting up our controlP5 GUI and the Nav3D 
// camera controller. to receive mouse wheel events we have to 
// do a little Java magic, such as implementing the
// java.awt.event.MouseWheelListener interface (see end of this
// tab.)

void initControllers() {
  nav=new MouseNav3D(this); 
  nav.trans.set(width/2,height/2,0);
  nav.rot.set(PI/6,PI/6,0);
  
  // create a listener for mouse wheel events
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(color(0,0,0));
  
  //GRID RESOUTION
  slGridResolution=50;
  controlP5.addSlider("slGridResolution", // name, must match variable name
    5,img.width, // min and max values
    slGridResolution, // the default value
    20,20, // X,Y position of slider
    100,13) // width and height of slider
    .setId(1); 

//Z SHIFT
  Z=500;
  controlP5.addSlider("Z", // name, must match variable name
    5,1000, // min and max values
    Z, // the default value
    20,40, // X,Y position of slider
    100,13); // width and height of slider
    
    //BRIGHTNESS
  _brightness=-10;
  controlP5.addSlider("_brightness", // name, must match variable name
    -200,200, // min and max values
    _brightness, // the default value
    20,60, // X,Y position of slider
    100,13); // width and height of slider
    
    //CONTRAST
  _contrast=102;
  controlP5.addSlider("_contrast", // name, must match variable name
    -200,200, // min and max values
    _contrast, // the default value
    20,80, // X,Y position of slider
    100,13); // width and height of slider
 
  // add a "bang" input, a button that triggers a custom function.
  // we'll use it to regenerate the mesh
//  controlP5.addBang("generateMesh",20,20,20,20);

  controlP5.addBang("saveSTL",220,20,20,20);
  
    // add toggle switch
  controlP5.addToggle("toggleSolid",
    300,20, // X,Y position
    20,20); // width and height
}

// catch ControlP5 events to force rebuilding the mesh
void controlEvent(ControlEvent theEvent) {
  generateMesh();
}

void saveSTL() {
  terrain.model.writeSTL(this, 
    IO.getIncrementalFilename("Terrain ###.stl", sketchPath));
}
  
// pass mouse and key events to our Nav3D instance
void mouseDragged() {
  // ignore mouse event if cursor is over controlP5 GUI elements
  if(controlP5.window(this).isMouseOver()) return;
  
  nav.mouseDragged();
}

void keyPressed() {
  nav.keyPressed();
  
  if(key == ' '){
   //load image as mesh
    img = modifiedImg;
     generateMesh(); // initialize mesh surface, see "Terrain"
  }
  else if(key == 'k'){
   //draw the kinect image
  drawKinect = !drawKinect; 
  }
}

