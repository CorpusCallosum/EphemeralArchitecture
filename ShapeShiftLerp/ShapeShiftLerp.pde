import hypermedia.video.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;

import controlP5.*;
import processing.opengl.*;
import java.awt.event.*;
import java.awt.Color;

import SimpleOpenNI.*;

import processing.video.*;
Capture video;

// modelab.nu Processing Tutorial - Marius Watz, 2010
// http://modelab.nu/?p=4147 / http://workshop.evolutionzone.com

ControlP5 controlP5; // instance of the controlP5 library

//SLIDER VRS
int slGridResolution, _brightness, _contrast, _sat; // slider value for grid resolution
float Z; // controls the height difference in the terrain
float noiseXD, noiseYD; // modifiers for X,Y noise

boolean toggleSolid=true; // controls rendering style

Mesh mesh; // Terrain object

OpenCV opencv;

//float[][] colorGrid;
color[][] colorGrid;
float[][] brightnessGrid;

PImage img;
PImage modifiedImg;
PImage blendedImg;
PImage alphaImg, scaledImg;
PImage colorSnapshot; //save color information every hour
PImage colorInit; //initialize with color from most recent snapshot
PImage depthSnapshot;

SimpleOpenNI kinect;

boolean drawKinect = false;
boolean _debug = false;
boolean _blendMode = true;
boolean _drawLines = true;
boolean _transparent = false;
boolean _useKinect = true;

float _counter = 110;

//color timers
long startTime; 
long currentTime;
long lastTime = 0;
long colorTime = 0;
int colorDuration = 1000 * 20; //how long each color lasts in ms
//int runTime = 1000*60*5; //5 minutes
int everyHour = 3600; //1 hour = 3600 seconds to save out every hour

int cycles = 1;

color colorPalette[] = new color[ 5 ];
color fromColor;
color toColor;
color transColor;
int currentColor;
int lastColor;
float transSpeed; // moves 0 - 1 to transition fromColor toColor


Timer _saveDepthMapTimer;
Timer _loadColorTimer;

int transX, transY, transZ;
float rotX, rotY, rotZ;

//==============================================
void setup() {
  size(1024, 768, OPENGL);
  noCursor();

  initControllers(); // initialize interface, see "GUI" tab
  generateMesh(); // initialize mesh surface, see "Terrain"

  //camera or kinect initialize
  opencv = new OpenCV( this );
  kinect = new SimpleOpenNI( this );
  kinect.start();
  
  try{
    kinect.enableDepth();
  }
  catch(Exception e){
   println("kinect not kinects, fuuuuuuu");
   _useKinect = false;
  //create webcam object 
   opencv.capture( 640, 480 ); 

  }

  if(_useKinect){
    img = kinect.depthImage();
  }
  else{
    opencv.read();
    img = opencv.image();
  }
  
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

  opencv.allocate( img.width, img.height );
  for (int x=0;x<alphaImg.width;x++) {
    for (int y=0;y<alphaImg.height;y++) {
      alphaImg.set(x, y, 10);
    }
  }
  
  float _scale = .1;
  scaledImg = createImage(round(img.width*_scale), round(img.height*_scale), RGB);
  
  //color grid initialize
  colorGrid = new color[scaledImg.width][scaledImg.height];
  brightnessGrid = new float[scaledImg.width][scaledImg.height];
  
  currentColor = 1;
  lastColor = 0;
  transSpeed = 0.0;
  
  startTime = System.currentTimeMillis();
  cycles = 1;
  
  //initialize color palette
  colorMode( RGB );
  colorPalette[ 0 ] = color( 25, 228, 245, 255 );   //ice blue
  colorPalette[ 1 ] = color( 5, 3, 255, 255 );      //dark blue
  colorPalette[ 2 ] = color( 88, 4, 180, 255 );     //purple
  colorPalette[ 3 ] = color( 233, 19, 237, 255 );   //magenta
  colorPalette[ 4 ] = color( 255, 255, 255, 255 );  //white
  
    
  fromColor = colorPalette[ lastColor ];
  transColor = colorPalette[ lastColor ];
  toColor = colorPalette[ currentColor ];
  
  
  //create image to save color to
  colorSnapshot = createImage( scaledImg.width, scaledImg.height, HSB );
  depthSnapshot = createImage( img.width, img.height, RGB );

  startTime = System.currentTimeMillis();

  _saveDepthMapTimer = new Timer(60*60);//one hour
  _saveDepthMapTimer.start();
  
   _loadColorTimer = new Timer(1);//
   _loadColorTimer.start();
  
  transX = -600;
  transY = -1400;
  transZ = -800;
  rotX = -PI / 4;
  rotY = 0;
  rotZ = PI;
  

  draw();
  loadColor();
  
}


//============================================================
void draw() {

  kinect.update();//SimpleOpenNi
  background(0);
  smooth();

  transSpeed = (float) colorTime / colorDuration;
  transColor = lerpColor( colorPalette[ lastColor ], colorPalette[ currentColor ], transSpeed ); //the current color
  
  currentTime = System.currentTimeMillis() - startTime;//how long the sketch has been running in m
  if ( colorTime >= colorDuration ) {
    cycles ++;
    lastColor = currentColor;
    currentColor ++;
    if ( currentColor > colorPalette.length - 1 ) {
      currentColor = 0;
    } 
    fromColor = colorPalette[ lastColor ];
    toColor = colorPalette[ currentColor ];
  }
  if ( cycles > 1 ) {
    colorTime = currentTime - ((cycles - 1 ) * colorDuration );
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
  rotateX( rotX );
  rotateY( rotY );
  rotateZ( rotZ );
  //rotate( rotX, rotY, rotZ );
  translate( transX, transY, transZ );
  //translate( 4000, 500, -2000);  
  
  lights();
  //nav.doTransforms(); // transformations using Nav3D
  mesh.draw();
  popMatrix();

  // turn off depth test so the controlP5 GUI draws correctly
  hint(DISABLE_DEPTH_TEST);

  //contrast
  if(_useKinect){
    img = kinect.depthImage();
  }
  else{
    opencv.read();
    img = opencv.image(); 
  }
  
  img.copy( img, 0, 0, img.width, img.height, 0, 0, img.width+10, img.height+10 );

  //use opencv for brightness and contrast
  opencv.copy( img); 
  opencv.flip(OpenCV.FLIP_BOTH);
  
  opencv.brightness( _brightness );
  opencv.contrast( _contrast );

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
    image(img, width-350, 0, 320, 240);
    image(modifiedImg, width-350, 240, 320, 240);
    image(blendedImg, width-350, 240*2, 320, 240);
  }
  img = blendedImg;

  float s = .1;

  scaledImg.copy(img, 0, 0, img.width, img.height, 0, 0, round(img.width*s), round(img.height*s));

  generateMesh(); // initialize mesh surface, see "Terrain"

  if (_debug)
    controlP5.draw();

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
    _loadColorTimer.reset();
  }
  
  //draw rect
  noStroke();
  fill(0);
  rect(0,0,25,height);
  rect(width-5,0,20,height);
}

// initializes 3D mesh
void generateMesh() {

  if (mesh == null) mesh = new Mesh(this);
  //terrain.buildModel();
}

//save mesh to stl
void saveSTL() {

  long saveTime = System.currentTimeMillis()/1000;
  mesh.getMeshReference().saveAsSTL(sketchPath("data/stl/LANscape"+saveTime+".stl"));

  for ( int i = 0; i < scaledImg.width; i++ ) {
    for ( int j = 0; j < scaledImg.height; j++ ) {

      colorMode( HSB, 255 );
      color c = colorGrid[i][j];
      //println(colorGrid[i][j]);
      colorSnapshot.set( i, j, c );
    }
  }

  colorSnapshot.save( sketchPath("data/color/colorSnapshot"+saveTime+".jpg") );
  colorSnapshot.save( sketchPath("data/colorInitialize.jpg") );
  
}

//save every minute
void saveDepthMap() {
  long saveTime = System.currentTimeMillis()/1000;
  for ( int i = 0; i < img.width; i++ ) {
    for ( int j = 0; j < img.height; j++ ) {
      color c = img.get( i, j );
      depthSnapshot.set(i, j, c );
      
    }
  }
  
  depthSnapshot.save("data/lastDepth.jpg");
  depthSnapshot.save("data/depth/depth"+saveTime+".jpg");
}

void loadColor() {
  //initialize color grid to starting color
  colorInit = loadImage("colorInitialize.jpg");
  if(colorInit != null){
  for (int i = 0; i < scaledImg.width; i++ ) {
    for ( int j = 0; j < scaledImg.height; j++ ) {
      colorMode( HSB, 255 );
      int initialHue = round( hue(colorInit.get( i, j )) );
      colorGrid[i][j] = color( 163, 0, 255, 255 );
    }
  }
  }
}


void stop() {
  super.stop();
}


