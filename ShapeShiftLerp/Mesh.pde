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

  import processing.opengl.*;

  import toxi.math.waves.*;
  import toxi.geom.*;
  import toxi.geom.mesh.*;
  import toxi.math.noise.*;
  float NS = 0.05f;
  float SIZE = 100;

  float AMP = SIZE*4;
  
  TriangleMesh mesh = new TriangleMesh();

  boolean isWireFrame;
  boolean showNormals;
  boolean doSave;

  float vertexHueA;
  color vertexColorA;
  float vertexHueB;
  color vertexColorB;
  float vertexHueC;
  color vertexColorC;
  
  float xSeed, ySeed = 0;
  float vertexBrightness;
 

  Terrain terrain;

  Matrix4x4 normalMap = new Matrix4x4().translateSelf(128, 128, 128).scaleSelf(127);

  Mesh(PApplet _parent) {    
    parent=_parent;

    //TRY LOADING THE STL HERE
    //  mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("stl/LANscape1336843728.stl"),STLReader.TRIANGLEMESH);
  }

  TriangleMesh getMeshReference() {
    return mesh;
  }

  void draw() {
 
    background(0);
    lights();
    shininess(16);
    directionalLight( 255, 255, 255, 100, 25 , 0);
    pointLight( 255, 255, 255, 0,0, 300);    
    specular(255);
  

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


  void drawMesh( PGraphics gfx, TriangleMesh mesh, boolean vertexNormals, boolean showNormals ) {

    gfx.beginShape( PConstants.TRIANGLES );
    AABB bounds = mesh.getBoundingBox();
    Vec3D min = bounds.getMin();
    Vec3D max = bounds.getMax();
   // int sat = 100;
    // println("boundsMin: " + bounds.getMin() + ", boundsMax: " + bounds.getMax());

    if ( vertexNormals ) {
      for ( Iterator i = mesh.faces.iterator(); i.hasNext(); ) {

        Face f = (Face)i.next();
        colorMode(RGB);

        //vertexA
        Vec3D n = normalMap.applyTo(f.a.normal);
        
        vertexColorA = colorGrid[floor(map((f.a.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.a.z), -1175, 1175, 0, scaledImg.height-1))];
        setVertexColor(gfx, vertexColorA);
        
        gfx.normal( f.a.normal.x, f.a.normal.y, f.a.normal.z );
        gfx.vertex(f.a.x, f.a.y, f.a.z);

        //vertexB
        n = normalMap.applyTo(f.b.normal);
        
        vertexColorB = colorGrid[floor(map((f.b.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.b.z), -1175, 1175, 0, scaledImg.height-1))];
        setVertexColor(gfx, vertexColorB);

        gfx.normal(f.b.normal.x, f.b.normal.y, f.b.normal.z);
        gfx.vertex(f.b.x, f.b.y, f.b.z);

        //vertexC
        n = normalMap.applyTo(f.c.normal);
        
        vertexColorC = colorGrid[floor(map((f.c.x), -1575, 1575, 0, scaledImg.width-1))][floor(map((f.c.z), -1175, 1175, 0, scaledImg.height-1))];
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

  void setVertexColor(PGraphics gfx, int c) {
    gfx.strokeWeight(1);
    if (toggleSolid) {
      gfx.fill( c );
      /*int strokeColor = c + 20;
      if ( strokeColor > 255 ) {
        strokeColor -= 255;
      gfx.stroke( strokeColor );*/
      gfx.stroke(150);
    } 
    else {
      gfx.fill( 0 );  
      gfx.stroke( c );
    }
    
    if(_drawLines){
      //color lineColor = color(hue(c), 150, brightness(c));
      vertexBrightness = map( noise( xSeed, ySeed), 0, 1, 150, 255 );
      xSeed += .05;
        if (xSeed % 150 == 0 ) {
          ySeed += .1;
        }
        //color lineColor = color( 0, 0, vertexBrightness);
 
      color lineColor = color( vertexBrightness );
     
      gfx.stroke( lineColor );
    }
    else{
      gfx.noStroke();
    }
    if(_transparent){
      gfx.noFill();
    }
  }

  void updateMesh() {
    terrain = new Terrain(round(scaledImg.width), round(scaledImg.height), round(50));
    float[] el = new float[scaledImg.width*scaledImg.height];

    for (int z = 0, i = 0; z < scaledImg.height; z++) {
      for (int x = 0; x < scaledImg.width; x++) {

        el[i] = brightness(scaledImg.get(x, z))/255.0 * Z;

        if ( abs(el[i] - brightnessGrid[x][z]) > 20 ) {
          colorGrid[x][z] = transColor; 
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
  
  color getCurrentColor(){
   //return  round( colorTime * 255 / runTime ) + startHue;
   return transColor;
 
  }
  
}

