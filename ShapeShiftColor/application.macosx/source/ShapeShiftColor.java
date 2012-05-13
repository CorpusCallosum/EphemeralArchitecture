import processing.core.*; 
import processing.xml.*; 

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
import processing.opengl.*; 
import toxi.math.waves.*; 
import toxi.geom.*; 
import toxi.geom.mesh.*; 
import toxi.math.noise.*; 

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

public class ShapeShiftColor extends PApplet {


















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
PImage colorSnapshot; //save color information every hour
PImage colorInit; //initialize with color from most recent snapshot
int startHue = 110;

Kinect kinect;
boolean drawKinect = false;
boolean _debug = false;
boolean _blendMode = true;
boolean _drawLines = true;
boolean _transparent = false;

float _counter = 110;

//Date today = new Date();
long startTime; 
long currentTime;
long lastTime = 0;
int runTime = 120000; //4 days = 345600000 milliseconds
int everyHour = 3600; //1 hour = 3600 seconds
Timer _saveDepthMapTimer;


//==============================================
public void setup() {
  size(1024, 768, OPENGL);


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
  blendedImg = loadImage("data/lastDepth.jpg");
  alphaImg = createImage(img.width, img.height, RGB);
 // blendedImg = createImage(img.width, img.height, RGB);
  
  float _scale = .1f;
  scaledImg = createImage(round(img.width*_scale), round(img.height*_scale), RGB);
  colorGrid = new float[scaledImg.width][scaledImg.height];
  brightnessGrid = new float[scaledImg.width][scaledImg.height];

  opencv.allocate( img.width, img.height );
  for(int x=0;x<alphaImg.width;x++){
     for(int y=0;y<alphaImg.height;y++){
       alphaImg.set(x,y,10); 
     }
  }
  
  
  
  //create image to save color to
  colorSnapshot = createImage( scaledImg.width, scaledImg.height, HSB );
  
  //startTime = round(today.getTime()/1000); //unix time - seconds
  startTime = System.currentTimeMillis();
 
 _saveDepthMapTimer = new Timer(60);//one minute
  _saveDepthMapTimer.start();
  
  draw();
  loadColor();
}


//============================================================
public void draw() {
  
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
  
  float s = .1f;
  
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
   _saveDepthMapTimer.update();
   if ( _saveDepthMapTimer.isExpired()) {
     saveDepthMap();
     _saveDepthMapTimer.reset();
     _saveDepthMapTimer.start();
   }
   
    lastTime = currentTime;
    
}

// initializes 3D mesh
public void generateMesh() {
 
  if (mesh == null) mesh = new Mesh(this);
  //terrain.buildModel();
}

//save mesh to stl
public void saveSTL() {
  
  long saveTime = System.currentTimeMillis()/1000;
  mesh.getMeshReference().saveAsSTL(sketchPath("data/LANscape"+saveTime+".stl"));
  
  for ( int i = 0; i < scaledImg.width; i++ ) {
    for ( int j = 0; j < scaledImg.height; j++ ) {
      
      colorMode( HSB, 255 );
      int c = color( round( startHue + colorGrid[i][j] ), 255, 255 );
      
      //println("colorGridValue: " + colorGrid[i][j] + ", red: " + red(c) + ", green: " + green(c) + ", blue: " + blue(c));
      //println(colorGrid[i][j]);
      colorSnapshot.set( i, j, c );
    }
  }
  
     colorSnapshot.save( sketchPath("data/colorSnapshot"+saveTime+".jpg") );
      colorSnapshot.save( sketchPath("data/colorInitialize.jpg") );
      
}

//save every minute
public void saveDepthMap(){
  long saveTime = System.currentTimeMillis()/1000;
  img.save("data/lastDepth.jpg");
  img.save("data/depth/depth"+saveTime+".jpg");
}

public void loadColor(){
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
// functions for setting up our controlP5 GUI and the Nav3D 
// camera controller. to receive mouse wheel events we have to 
// do a little Java magic, such as implementing the
// java.awt.event.MouseWheelListener interface (see end of this
// tab.)

int _x, _y, _z;

public void initControllers() {
  _x = width/2;
  _y = 500;//height/2;
  _z = -3000;
  nav = new UNav3D(this); 
  nav.trans.set(_x, _y, _z);
  nav.rot.set(10*PI/12, 0, 0);

  // create a listener for mouse wheel events
  controlP5 = new ControlP5(this);
  controlP5.setColorLabel(color(0, 0, 0));

  //GRID RESOUTION
  /*slGridResolution=50;
  controlP5.addSlider("slGridResolution", // name, must match variable name
  5, scaledImg.width, // min and max values
  slGridResolution, // the default value
  20, 20, // X,Y position of slider
  100, 13) // width and height of slider
    .setId(1); */

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
public void controlEvent(ControlEvent theEvent) {
  generateMesh();
}


// pass mouse and key events to our Nav3D instance
public void mouseDragged() {
  // ignore mouse event if cursor is over controlP5 GUI elements
  if (controlP5.window(this).isMouseOver()) return;

  nav.mouseDragged();
}

public void keyPressed() {
  nav.keyPressed();

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
  }
  else if (key == 'o') {
    println("x : " +nav.rot.x);
    println("y : " +nav.rot.y);
    println("z : " +nav.rot.z);
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
  
}
// this class calculates a 3D terrain using the noise(x,y)
// function. see http://processing.org/reference/noise_.html
// for more information about noise().
//
// because the user might change grid resolution or the X and Y
// modifiers for the noise function, the Terrain.draw() function
// needs to be able to regenerate the mesh and calculate the
// Z heights every frame.

class Mesh {
  PApplet parent;

  Pt pt[][];
  int gridRes; // grid resolution
  int lastGridRes; // last known grid resolution
  UGeometry model;

  

  
  
  
  
  float NS = 0.05f;
  float SIZE = 100;

  float AMP = SIZE*4;
  
  TriangleMesh mesh = new TriangleMesh();

  boolean isWireFrame;
  boolean showNormals;
  boolean doSave;

  float vertexHueA;
  int vertexColorA;
  float vertexHueB;
  int vertexColorB;
  float vertexHueC;
  int vertexColorC;

  Terrain terrain;

  Matrix4x4 normalMap = new Matrix4x4().translateSelf(128, 128, 128).scaleSelf(127);

  Mesh(PApplet _parent) {    
    parent=_parent;
    //  buildModel();

    //TRY LOADING THE STL HERE
    //  mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("stl/LANscape1336843728.stl"),STLReader.TRIANGLEMESH);
  }

  public TriangleMesh getMeshReference() {
    return mesh;
  }

  public void draw() {

    // check which drawing style to use
    /*if(toggleSolid) {
     fill(37, 109, 154);
     //       stroke(0);
     
     colorMode(HSB);
     stroke(_counter, 255, 255);
     //noFill();
     fill(0);
     // noStroke();
     }
     else {
     noFill();
     fill(0, 0, 0, 128);
     stroke(9, 133, 255 );
     //noStroke();
     }
     model.draw(parent);*/

    background(0);
    lights();
    shininess(16);
    directionalLight(255, 255, 255, 100, 25 , 0);
    pointLight(255,255,255, 0,0, 300);    specular(255);
    //drawAxes(400);

    if ( isWireFrame ) {
      noFill();
      stroke( 255 );
    } 
    else {
      fill( 255 );
      noStroke();
    }
    updateMesh();

    drawMesh( g, mesh, !isWireFrame, showNormals );
    //drawLines();

    if ( doSave ) {
      saveFrame( "sh-"+(System.currentTimeMillis()/1000)+".png" );
      doSave=false;
    }
  }




  public void drawMesh( PGraphics gfx, TriangleMesh mesh, boolean vertexNormals, boolean showNormals ) {
    gfx.beginShape( PConstants.TRIANGLES );
    AABB bounds = mesh.getBoundingBox();
    Vec3D min = bounds.getMin();
    Vec3D max = bounds.getMax();
    int sat = 100;
    // println("boundsMin: " + bounds.getMin() + ", boundsMax: " + bounds.getMax());

    if ( vertexNormals ) {
      for ( Iterator i = mesh.faces.iterator(); i.hasNext(); ) {

        Face f = (Face)i.next();
        colorMode(HSB);

        Vec3D n = normalMap.applyTo(f.a.normal);
        
        //println("vertexHueA: " + colorGrid[floor(map((f.a.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.a.z), -1175, 1175, 0, scaledImg.height-1))]);
        vertexHueA = startHue + colorGrid[floor(map((f.a.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.a.z), -1175, 1175, 0, scaledImg.height-1))]; //mapping based on 4 day cycle in seconds
        while ( vertexHueA > 255 ) {
          vertexHueA -= 255;
        }
        vertexColorA = color(vertexHueA, sat, 255 );
        setVertexColor(gfx, vertexColorA);
        
        gfx.normal( f.a.normal.x, f.a.normal.y, f.a.normal.z );
        gfx.vertex(f.a.x, f.a.y, f.a.z);

        n = normalMap.applyTo(f.b.normal);
        vertexHueB = startHue +colorGrid[floor(map((f.b.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.b.z), -1175, 1175, 0, scaledImg.height-1))]; //mapping based on 4 day cycle in seconds
        if ( vertexHueB > 255 ) {
          vertexHueB -= 255;
        }
        // println( vertexHueB );
        vertexColorB = color( round(vertexHueB), sat, 255 );
        setVertexColor(gfx, vertexColorB);

        gfx.normal(f.b.normal.x, f.b.normal.y, f.b.normal.z);
        gfx.vertex(f.b.x, f.b.y, f.b.z);

        n = normalMap.applyTo(f.c.normal);
        vertexHueC = startHue + colorGrid[floor(map((f.c.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.c.z), -1175, 1175, 0, scaledImg.height-1))]; //mapping based on 4 day cycle in seconds
        if ( vertexHueC > 255 ) {
          vertexHueC -= 255;
        }
        vertexColorC = color( round(vertexHueC), sat, 255 );
        setVertexColor(gfx, vertexColorC);
 
        gfx.normal(f.c.normal.x, f.c.normal.y, f.c.normal.z);
        gfx.vertex(f.c.x, f.c.y, f.c.z);
      }
    } 

    else {
      for (Iterator i=mesh.faces.iterator(); i.hasNext();) {
        Face f=(Face)i.next();
        gfx.normal(f.normal.x, f.normal.y, f.normal.z);
        gfx.stroke(255, 0, 0);
        gfx.vertex(f.a.x, f.a.y, f.a.z);
        gfx.stroke(0, 255, 0);
        gfx.vertex(f.b.x, f.b.y, f.b.z);
        gfx.stroke(0, 0, 255);
        gfx.vertex(f.c.x, f.c.y, f.c.z);
      }
    }
    gfx.endShape();

    if (showNormals) {
      if (vertexNormals) {
        for (Iterator i=mesh.vertices.values().iterator(); i.hasNext();) {
          Vertex v=(Vertex)i.next();
          Vec3D w = v.add(v.normal.scale(10));
          Vec3D n = v.normal.scale(127);
          gfx.stroke(n.x + 128, n.y + 128, n.z + 128);
          gfx.line(v.x, v.y, v.z, w.x, w.y, w.z);
        }
      } 

      else {
        for (Iterator i=mesh.faces.iterator(); i.hasNext();) {
          Face f=(Face)i.next();
          Vec3D c = f.a.add(f.b).addSelf(f.c).scaleSelf(1f / 3);
          Vec3D d = c.add(f.normal.scale(20));
          Vec3D n = f.normal.scale(127);
          gfx.stroke(n.x + 128, n.y + 128, n.z + 128);
          gfx.line(c.x, c.y, c.z, d.x, d.y, d.z);
        }
      }
    }
  }

  public void setVertexColor(PGraphics gfx, int c) {
    gfx.strokeWeight(3);
    if (toggleSolid) {
      gfx.fill( c );
    } 
    else {
      gfx.fill( 0 );  
      gfx.stroke( c );
    }
    
    if(_drawLines){
      int lineColor = color(hue(c), 255, brightness(c));
      gfx.stroke( lineColor );
    }
    else{
      gfx.noStroke();
    }
    if(_transparent){
      gfx.noFill();
    }
  }

  public void updateMesh() {
    terrain = new Terrain(round(scaledImg.width), round(scaledImg.height), round(50));
    float[] el = new float[scaledImg.width*scaledImg.height];

    for (int z = 0, i = 0; z < scaledImg.height; z++) {
      for (int x = 0; x < scaledImg.width; x++) {

        el[i] = brightness(scaledImg.get(x, z))/255.0f * Z;

        if ( el[i] - brightnessGrid[x][z] > 20 ) {
          colorGrid[x][z] = round( currentTime * 255 / runTime ); //convert from time since start to int between 0-255
          //println("colorgridValue: " + colorGrid[x][z]);
        }
        brightnessGrid[x][z] = el[i];

        i++;
      }
    }
    terrain.setElevation(el);

    // create mesh
    mesh = (TriangleMesh)terrain.toMesh();
    mesh.center(null);
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
/*
SIMPLE TIMER CLASS
Jack Kalish
*/

class Timer {

  long _startTime;
  long _time;
  boolean _expired, _stopped;


  Timer(long t) {
    _time = t*1000; //convert from seconds to ms
    reset();
  }

  public float getElapsedTime() {
    return millis() - _startTime;
  }

  public void update() {
    if (!_stopped) {
      if (getElapsedTime() > _time) {
        _expired = true;
      }
    }
  }

  public boolean isExpired() {
    update();
    return _expired;
  }

  public void reset() {
    _startTime = millis();
    _expired = false;
    _stopped = true;
  }

  public void stop() {
    reset();
  }
  
  public void start() {
    _startTime = millis();
    _stopped = false;
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
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "ShapeShiftColor" });
  }
}
