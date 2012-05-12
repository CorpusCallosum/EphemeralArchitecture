/* a custom mesh STL exporter */
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
import toxi.geom.mesh.STLWriter;
//import toxi.geom.util.*;

// assume this has been populated somehow...
TriangleMesh mesh;

// create stl color model with mesh base color
// the true flag means facets can have their own RGB value
MaterialiseSTLColorModel colModel=new MaterialiseSTLColorModel(0x112233,true);
// create STLWriter instance
STLWriter stl = new STLWriter(colModel);
// write the file header
stl.beginSave(sketchPath("color.stl"), mesh.getNumFaces());
int k=0;
// iterate over all mesh faces
for (Iterator i=mesh.faces.iterator(); i.hasNext();) {
  TriangleMesh.Face f=(TriangleMesh.Face)i.next();
  // tint every 2nd face in alternating colors
  // btw. a RGB value of -1 will disable the face color
  // and revert to the default mesh color
  stl.face(f.b, f.a, f.c, f.normal, 0==k%2 ? 0xff00ff : 0xffff00);
  k++;
}
stl.endSave(); 
