import unlekker.util.*;
import unlekker.modelbuilder.*;
import ec.util.*;

import hypermedia.video.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;

import controlP5.*;
import processing.opengl.*;
import java.awt.event.*;

import org.openkinect.*;
import org.openkinect.processing.*;

// modelab.nu Processing Tutorial - Marius Watz, 2010
// http://modelab.nu/?p=4147 / http://workshop.evolutionzone.com

ControlP5 controlP5; // instance of the controlP5 library

//SLIDER VRS
int slGridResolution, _brightness, _contrast; // slider value for grid resolution
float Z; // controls the height difference in the terrain
float noiseXD, noiseYD; // modifiers for X,Y noise

boolean toggleSolid=true; // controls rendering style

UNav3D nav; // camera controller
Mesh mesh; // Terrain object

OpenCV opencv;

float[][] colorGrid;
float[][] brightnessGrid;

PImage img;
PImage modifiedImg;
PImage blendedImg;
PImage alphaImg, scaledImg;

Kinect kinect;
boolean drawKinect = false;
boolean _debug = false;
boolean _blendMode = true;

float _counter = 110;

//Date today = new Date();
long startTime; 
long currentTime;
long lastTime = 0;
int runTime = 120000; //4 days = 345600000 milliseconds
int everyHour = 3600; //1 hour = 3600 seconds




//==============================================
void setup() {
  size(1440, 900, OPENGL);


  // input image must be square or have a greater height than width.

  // this image is borrowed from the excellent contour map tutorial
  // by OnFormative:
  // http://onformative.com/lab/creating-contour-maps/
  
  
  initControllers(); // initialize interface, see "GUI" tab
  generateMesh(); // initialize mesh surface, see "Terrain"

  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(true);

  // kinect.enableRGB(rgb);
  //kinect.enableIR(ir);
  //kinect.tilt(deg);
  
  
  opencv = new OpenCV( this );

  img = kinect.getDepthImage();
  alphaImg = createImage(img.width, img.height, RGB);
  blendedImg = createImage(img.width, img.height, RGB);
  
  float _scale = .1;
  scaledImg = createImage(round(img.width*_scale), round(img.height*_scale), RGB);
  colorGrid = new float[scaledImg.width][scaledImg.height];
  brightnessGrid = new float[scaledImg.width][scaledImg.height];

  opencv.allocate( img.width, img.height );
  for(int x=0;x<alphaImg.width;x++){
     for(int y=0;y<alphaImg.height;y++){
       alphaImg.set(x,y,10); 
     }
  }
  
  //initialize color grid to starting color
  for (int i = 0; i < scaledImg.width; i++ ) {
    for ( int j = 0; j < scaledImg.height; j++ ) {
      colorGrid[i][j] = 110 * runTime / 255; //vertexHue -> 110
      brightnessGrid[i][j] = 0;
    }
  }
  
  //startTime = round(today.getTime()/1000); //unix time - seconds
  startTime = System.currentTimeMillis();
 
  
}


//============================================================
void draw() {
  
  background(0);
  smooth();
  
  //currentTime = round( today.getTime()/1000 ) - startTime;// how long the sketch has been running in seconds
  currentTime = System.currentTimeMillis() - startTime;
  //println("startTime: " + startTime + ", currentTime: " + currentTime);

  // because we want controlP5 to be drawn on top of everything
  // we need to disable OpenGL's depth testing at the end
  // of draw(). that means we need to turn it on again here.
  hint(ENABLE_DEPTH_TEST); 

  pushMatrix();    
  lights();
  nav.doTransforms(); // transformations using Nav3D
  mesh.draw();
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
  int mode;
  if(_blendMode){
     mode = DIFFERENCE;
  }
  else{
       mode = BLEND;

  }
  blendedImg.blend(modifiedImg, 0, 0, img.width, img.height, 0, 0, img.width, img.height, mode);

  fill(255);
  if (drawKinect) {
    image(img, width-310, 0, 320, 240);
    image(modifiedImg, width-310, 240, 320, 240);
    image(blendedImg, width-310, 240*2, 320, 240);
  }
  img = blendedImg;
  
  float s = .1;
  
  scaledImg.copy(img, 0, 0, img.width,  img.height, 0, 0, round(img.width*s), round(img.height*s));
  
  generateMesh(); // initialize mesh surface, see "Terrain"
  
  if(_debug)
    controlP5.draw();
  
  /*_counter+=.01;
  if(_counter >= 255)
   _counter = 0;*/
   
   if ( round(currentTime/1000) % everyHour == 0 && round(lastTime/1000) % everyHour !=0) {
     saveSTL();
     //println("saved");
   }
   
    lastTime = currentTime;
}



// initializes 3D mesh
void generateMesh() {
  if (mesh == null) mesh = new Mesh(this);
  //terrain.buildModel();
}

//save mesh to stl
void saveSTL() {
  mesh.getMeshReference().saveAsSTL(sketchPath("LANscape"+(System.currentTimeMillis()/1000)+".stl"));
}




