import unlekker.util.*;
import unlekker.modelbuilder.*;
import ec.util.*;

import hypermedia.video.*;


OpenCV opencv;

// modelab.nu Processing Tutorial - Marius Watz, 2010
// http://modelab.nu/?p=4147 / http://workshop.evolutionzone.com
//
// Shared under Creative Commons "share-alike non-commercial use 
// only" license.

import controlP5.*;
import processing.opengl.*;
import java.awt.event.*;

ControlP5 controlP5; // instance of the controlP5 library

//SLIDER VRS
int slGridResolution, _brightness, _contrast; // slider value for grid resolution
float Z; // controls the height difference in the terrain
float noiseXD, noiseYD; // modifiers for X,Y noise

boolean toggleSolid=false; // controls rendering style

UNav3D nav; // camera controller
Terrain terrain; // Terrain object

PImage img;
PImage modifiedImg;
PImage blendedImg;
PImage alphaImg;



import org.openkinect.*;
import org.openkinect.processing.*;

Kinect kinect;
boolean drawKinect = false;
boolean _debug = false;

void setup() {
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
  kinect.enableDepth(true);

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
       alphaImg.set(x,y,10); 
     }
  }
  
 // lights();
}

void draw() {
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
  
  if(_debug)
    controlP5.draw();
  
}

// initializes 3D mesh
void generateMesh() {
  if (terrain==null) terrain=new Terrain(this);
  terrain.buildModel();
}

