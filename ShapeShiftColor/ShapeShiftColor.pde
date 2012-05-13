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
import java.awt.Color;

import org.openkinect.*;
import org.openkinect.processing.*;

// modelab.nu Processing Tutorial - Marius Watz, 2010
// http://modelab.nu/?p=4147 / http://workshop.evolutionzone.com

ControlP5 controlP5; // instance of the controlP5 library

//SLIDER VRS
int slGridResolution, _brightness, _contrast, _sat; // slider value for grid resolution
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
PImage colorSnapshot; //save color information every hour
PImage colorInit; //initialize with color from most recent snapshot
int startHue = 110;
int cycles = 1;

Kinect kinect;
boolean drawKinect = false;
boolean _debug = false;
boolean _blendMode = true;
boolean _drawLines = false;
boolean _transparent = false;

float _counter = 110;

//Date today = new Date();
long startTime; 
long currentTime;
long lastTime = 0;
long colorTime = 0;
int runTime = 120000; //4 days = 345600000 milliseconds
int everyHour = 3600; //1 hour = 3600 seconds
Timer _saveDepthMapTimer;
Timer _loadColorTimer;


//==============================================
void setup() {
  size(1024, 768, OPENGL);
noCursor();


  // input image must be square or have a greater height than width.

  // this image is borrowed from the excellent contour map tutorial
  // by OnFormative:
  // http://onformative.com/lab/creating-contour-maps/


  initControllers(); // initialize interface, see "GUI" tab
  generateMesh(); // initialize mesh surface, see "Terrain"

  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(true);

  opencv = new OpenCV( this );

  img = kinect.getDepthImage();
  //load the latest depth map here
  try{
    blendedImg = loadImage("data/lastDepth.jpg");
  }
  catch (Exception e){
    blendedImg = createImage(img.width, img.height, RGB);
  }
  if(blendedImg == null){
    blendedImg = createImage(img.width, img.height, RGB);
  }
  alphaImg = createImage(img.width, img.height, RGB);
 // 
  
  float _scale = .1;
  scaledImg = createImage(round(img.width*_scale), round(img.height*_scale), RGB);
  colorGrid = new float[scaledImg.width][scaledImg.height];
  brightnessGrid = new float[scaledImg.width][scaledImg.height];

  opencv.allocate( img.width, img.height );
  for (int x=0;x<alphaImg.width;x++) {
    for (int y=0;y<alphaImg.height;y++) {
      alphaImg.set(x, y, 10);
    }
  }



  //create image to save color to
  colorSnapshot = createImage( scaledImg.width, scaledImg.height, HSB );

  //startTime = round(today.getTime()/1000); //unix time - seconds
  startTime = System.currentTimeMillis();

  _saveDepthMapTimer = new Timer(60);//one minute
  _saveDepthMapTimer.start();
  
   _loadColorTimer = new Timer(1);//
  _loadColorTimer.start();

  draw();
  loadColor();
}


//============================================================
void draw() {

  background(0);
  smooth();

  //currentTime = round( today.getTime()/1000 ) - startTime;// how long the sketch has been running in seconds
  currentTime = System.currentTimeMillis() - startTime;
  if ( colorTime >= runTime ) {
    cycles++;
  }
  if ( cycles > 1 ) {
    colorTime = currentTime - ( (cycles - 1 ) * runTime );
  }
  else {
    colorTime = currentTime;
  }

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
  opencv.brightness( _brightness );
  opencv.contrast( _contrast );
  opencv.flip(OpenCV.FLIP_HORIZONTAL);

  modifiedImg = opencv.image();
  modifiedImg.mask(alphaImg);
  // if(counter >= 10){
  int mode;
  if (_blendMode) {
    mode = DIFFERENCE;
  }
  else {
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

  scaledImg.copy(img, 0, 0, img.width, img.height, 0, 0, round(img.width*s), round(img.height*s));

  generateMesh(); // initialize mesh surface, see "Terrain"

  if (_debug)
    controlP5.draw();

  /*_counter+=.01;
   if(_counter >= 255)
   _counter = 0;*/

  if ( round(currentTime/1000) % everyHour == 0 && round(lastTime/1000) % everyHour !=0) {
    saveSTL();
    //println("saved");
  }
  _saveDepthMapTimer.update();
  if ( _saveDepthMapTimer.isExpired()) {
    saveDepthMap();
    _saveDepthMapTimer.reset();
    _saveDepthMapTimer.start();
  }

  lastTime = currentTime;

  /*if (_firstRun) {
    loadColor();
    _firstRun = false;
  }*/
  
  if(_loadColorTimer.isExpired()){
    loadColor();
  }
}

// initializes 3D mesh
void generateMesh() {

  if (mesh == null) mesh = new Mesh(this);
  //terrain.buildModel();
}

//save mesh to stl
void saveSTL() {

  long saveTime = System.currentTimeMillis()/1000;
  mesh.getMeshReference().saveAsSTL(sketchPath("data/LANscape"+saveTime+".stl"));

  for ( int i = 0; i < scaledImg.width; i++ ) {
    for ( int j = 0; j < scaledImg.height; j++ ) {

      colorMode( HSB, 255 );
      color c = color( round( startHue + colorGrid[i][j] ), 255, 255 );

      //println("colorGridValue: " + colorGrid[i][j] + ", red: " + red(c) + ", green: " + green(c) + ", blue: " + blue(c));
      //println(colorGrid[i][j]);
      colorSnapshot.set( i, j, c );
    }
  }

  colorSnapshot.save( sketchPath("data/colorSnapshot"+saveTime+".jpg") );
  colorSnapshot.save( sketchPath("data/colorInitialize.jpg") );
}

//save every minute
void saveDepthMap() {
  long saveTime = System.currentTimeMillis()/1000;
  img.save("data/lastDepth.jpg");
  img.save("data/depth/depth"+saveTime+".jpg");
}

void loadColor() {
  //initialize color grid to starting color
  colorInit = loadImage("colorInitialize.jpg");
  for (int i = 0; i < scaledImg.width; i++ ) {
    for ( int j = 0; j < scaledImg.height; j++ ) {
      colorMode( HSB, 255 );
      int initialHue = round( hue(colorInit.get( i, j )) );
      colorGrid[i][j] = initialHue - startHue;
    }
  }
}

