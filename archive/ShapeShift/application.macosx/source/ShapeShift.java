import processing.core.*; 
import processing.xml.*; 

import unlekker.util.*; 
import unlekker.modelbuilder.*; 
import ec.util.*; 
import hypermedia.video.*; 
import controlP5.*; 
import processing.opengl.*; 
import java.awt.event.*; 
import org.openkinect.*; 
import org.openkinect.processing.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class ShapeShift extends PApplet {








OpenCV opencv;

// modelab.nu Processing Tutorial - Marius Watz, 2010
// http://modelab.nu/?p=4147 / http://workshop.evolutionzone.com
//
// Shared under Creative Commons "share-alike non-commercial use 
// only" license.





ControlP5 controlP5; // instance of the controlP5 library

//SLIDER VRS
int slGridResolution, _brightness, _contrast; // slider value for grid resolution
float Z; // controls the height difference in the terrain
float noiseXD, noiseYD; // modifiers for X,Y noise

boolean toggleSolid=false; // controls rendering style

MouseNav3D nav; // camera controller
Terrain terrain; // Terrain object

PImage img;
PImage modifiedImg;
PImage blendedImg;
PImage alphaImg;






Kinect kinect;
boolean depth = true;
boolean rgb = false;
boolean ir = false;

float deg = 15; // Start at 15 degrees

boolean drawKinect = false;
int counter = 0;


public void setup() {
  size(1280, 800, OPENGL);

  // input image must be square or have a greater height than width.

  // this image is borrowed from the excellent contour map tutorial
  // by OnFormative:
  // http://onformative.com/lab/creating-contour-maps/
  img=loadImage("heightmap.png");

  initControllers(); // initialize interface, see "GUI" tab
  generateMesh(); // initialize mesh surface, see "Terrain"

  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(depth);

  // kinect.enableRGB(rgb);
  //kinect.enableIR(ir);
  //kinect.tilt(deg);
  opencv = new OpenCV( this );

  img = kinect.getDepthImage();
  alphaImg = createImage(img.width, img.height, RGB);
  blendedImg = createImage(img.width, img.height, RGB);
  

  opencv.allocate( img.width, img.height );
  for(int x=0;x<alphaImg.width;x++){
     for(int y=0;y<alphaImg.height;y++){
       alphaImg.set(x,y,50); 
     }
  }
  
 // lights();
}

public void draw() {
  background(0);
  smooth();

  // because we want controlP5 to be drawn on top of everything
  // we need to disable OpenGL's depth testing at the end
  // of draw(). that means we need to turn it on again here.
  hint(ENABLE_DEPTH_TEST); 

  pushMatrix();    
  lights();

  nav.doTransforms(); // transformations using Nav3D
  terrain.draw();

  popMatrix();

  // turn off depth test so the controlP5 GUI draws correctly
  hint(DISABLE_DEPTH_TEST);

  //contrast
  img = kinect.getDepthImage();

  //use opencv for brightness and contrast
  opencv.copy( img); 
  //  int c = (int) map(mouseX, 0, width, -128, 128);
  //   int b = (int) map(mouseY, 0, height, -128, 128);
 // int b = -10;
 // int c = 102;
  opencv.brightness( _brightness );
  opencv.contrast( _contrast );
  opencv.flip(OpenCV.FLIP_HORIZONTAL);

  modifiedImg = opencv.image();
  modifiedImg.mask(alphaImg);
// if(counter >= 10){
  blendedImg.blend(modifiedImg, 0, 0, img.width, img.height, 0, 0, img.width, img.height, DIFFERENCE);
 // counter = 0;
 //}



  fill(255);
  if (drawKinect) {
    image(img, width-310, 0, 320, 240);
    image(modifiedImg, width-310, 240, 320, 240);
    image(blendedImg, width-310, 240*2, 320, 240);
  }
  img = blendedImg;
  generateMesh(); // initialize mesh surface, see "Terrain"
  
  counter++;
}

// initializes 3D mesh
public void generateMesh() {
  if (terrain==null) terrain=new Terrain(this);
  terrain.buildModel();
}

// functions for setting up our controlP5 GUI and the Nav3D 
// camera controller. to receive mouse wheel events we have to 
// do a little Java magic, such as implementing the
// java.awt.event.MouseWheelListener interface (see end of this
// tab.)

public void initControllers() {
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
  _brightness=-8;
  controlP5.addSlider("_brightness", // name, must match variable name
    -200,200, // min and max values
    _brightness, // the default value
    20,60, // X,Y position of slider
    100,13); // width and height of slider
    
    //CONTRAST
  _contrast=92;
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
public void controlEvent(ControlEvent theEvent) {
  generateMesh();
}

public void saveSTL() {
  terrain.model.writeSTL(this, 
    IO.getIncrementalFilename("Terrain ###.stl", sketchPath));
}
  
// pass mouse and key events to our Nav3D instance
public void mouseDragged() {
  // ignore mouse event if cursor is over controlP5 GUI elements
  if(controlP5.window(this).isMouseOver()) return;
  
  nav.mouseDragged();
}

public void keyPressed() {
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

class Pt {
  float x,y,z;
  
  Pt(float _x,float _y,float _z) {
    set(_x,_y,_z);
    x=_x;
    y=_y;
    z=_z;
  }

  public void set(float _x,float _y,float _z) {
    x=_x;
    y=_y;
    z=_z;
  }
  
  public void add(float _x,float _y,float _z) {
    x=x+_x;
    y=y+_y;
    z=z+_z;
  }

}
// this class calculates a 3D terrain using the noise(x,y)
// function. see http://processing.org/reference/noise_.html
// for more information about noise().
//
// because the user might change grid resolution or the X and Y
// modifiers for the noise function, the Terrain.draw() function
// needs to be able to regenerate the mesh and calculate the
// Z heights every frame.

class Terrain {
  PApplet parent;
  
  Pt pt[][];
  int gridRes; // grid resolution
  int lastGridRes; // last known grid resolution
  UGeometry model;
  
  Terrain(PApplet _parent) {    
    parent=_parent;
    buildModel();  
  }
  
  
  public void draw() {
    // check which drawing style to use
    if(toggleSolid) {
      fill(255);
     //       stroke(0);

      noStroke();
    }
    else {
      noFill();
    //  fill(0);
      stroke(255);
    //  noStroke();
    }
    model.draw(parent);

  }
  
  // draw mesh as horizontal lines
  public void drawLines() {
    stroke(0);
  
    for(int i=0; i<gridRes; i++) {
      noFill();
      beginShape();
      for(int j=0; j<gridRes; j++) {
        vertex(pt[i][j].x,pt[i][j].y,pt[i][j].z);
      }
      endShape();
    }
  }

  // draw mesh surface as strips of quads
  public void buildModel() {
    float bottomZ;
    float colFract;
    
    gridRes=slGridResolution;
//    pt=generateNoisePoints(gridRes);
    pt=generateImagePoints(gridRes);
    
    bottomZ=-Z*0.5f;
    if(model==null) model=new UGeometry();
    else model.reset();
    
    noStroke();
    for(int i=0; i<gridRes-1; i++) {
      model.beginShape(QUAD_STRIP);
      for(int j=0; j<gridRes; j++) {
        setColorZ(pt[i+1][j].z);
        model.vertex(pt[i+1][j].x,pt[i+1][j].y,pt[i+1][j].z);
        
        setColorZ(pt[i][j].z);
        model.vertex(pt[i][j].x,pt[i][j].y,pt[i][j].z);
        
      }
      model.endShape();
    }
    
    // draw edges of the mesh
    
    fill(0xffe56000);
    stroke(255);
    
    // left edge
    model.beginShape(QUAD_STRIP);
    for(int i=0; i<gridRes; i++) {
      model.vertex(pt[0][i].x,pt[0][i].y,pt[0][i].z);
      model.vertex(pt[0][i].x,pt[0][i].y,bottomZ);
    }
    model.endShape();

    // right side
    model.beginShape(QUAD_STRIP);
    for(int i=0; i<gridRes; i++) {
      model.vertex(pt[gridRes-1][i].x,pt[gridRes-1][i].y,bottomZ);
      model.vertex(pt[gridRes-1][i].x,pt[gridRes-1][i].y,pt[gridRes-1][i].z);
    }
    model.endShape();
//
    // lower edge
    model.beginShape(QUAD_STRIP);
    for(int i=0; i<gridRes; i++) {
      model.vertex(pt[i][gridRes-1].x,pt[i][gridRes-1].y,pt[i][gridRes-1].z);
      model.vertex(pt[i][gridRes-1].x,pt[i][gridRes-1].y,bottomZ);
    }
    model.endShape();

    // top edge
    model.beginShape(QUAD_STRIP);
    for(int i=0; i<gridRes; i++) {
      model.vertex(pt[i][0].x,pt[i][0].y,bottomZ);
      model.vertex(pt[i][0].x,pt[i][0].y,pt[i][0].z);
    }
    model.endShape();
    
    // bottom plane
    model.beginShape(QUADS);
    model.vertex(pt[0][0].x,pt[0][0].y,bottomZ);
    model.vertex(pt[gridRes-1][0].x,pt[gridRes-1][0].y,bottomZ);
    model.vertex(pt[gridRes-1][gridRes-1].x,pt[gridRes-1][gridRes-1].y,bottomZ);
    model.vertex(pt[0][gridRes-1].x,pt[0][gridRes-1].y,bottomZ);
    model.endShape();    
  
    model.center();  
    
  }
  
  public void setColorZ(float z) {
    // set color as a function of Z position
    float colFract=(z+Z*0.5f)/Z;
    fill(25,
      50+75*colFract,
      80+175*colFract);
  } 
}
public Pt[][] generateImagePoints(int res) {
  Pt[][] pt;
  float D;

  int imgw=img.width;
  int imgh=img.height;
  float xstep=(float)imgw/(float)res;
  float ystep=(float)imgh/(float)res;

  pt=new Pt[res][res];
  D=(float)width*0.8f;
  D=D/(float)(res-1);

  for(int i=0; i<res; i++) {
    for(int j=0; j<res; j++) {
      // generate new verex
      pt[i][j]=new Pt(
      (float)i*D,
      (float)j*D,
      0);
      
      int X=(int)((float)i*xstep);
      int Y=(int)((float)j*ystep);
      pt[i][j].z=
        (brightness(img.get(X,Y))/255.0f)*Z;
    }
  }
  
  return pt;
}


public Pt[][] generateNoisePoints(int res) {
  Pt[][] pt;

  float D,noiseStart,noiseX,noiseY;

  // set offset for noise function
  noiseStart=random(1000);    

  pt=new Pt[res][res];

  // D is the distance between each vertex, calculated
  // as 80% of width, divided by gridRes minus one
  D=(float)width*0.8f;
  D=D/(float)(res-1);

  for(int i=0; i<res; i++) {
    for(int j=0; j<res; j++) {
      // generate new verex
      pt[i][j]=new Pt(
      (float)i*D,
      (float)j*D,
      0);
    }
  }

  noiseX=noiseStart;
  for(int i=0; i<res; i++) {
    noiseY=0;

    for(int j=0; j<res; j++) {
      pt[i][j].z=noise(noiseX,noiseY)*Z-Z*0.5f;          
      noiseY+=(noiseYD/(float)res)*0.1f;
    }

    noiseX+=(noiseXD/(float)res)*0.1f;
  }

  return pt;
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "ShapeShift" });
  }
}
