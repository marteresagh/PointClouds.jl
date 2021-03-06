using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\MURI"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);


## alpha shape
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

## plane detection
regions = PointClouds.segmentation(V,FV,rgb,1, 0.03,"plane";VALID=500)
shape,pointsonplane,params=regions[1]
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane,params)
# extract model on plane and remained model
P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)
# color segmentation
P,Prgb = PointClouds.colorsegmentation(P,FP,Prgb,.25)
Vcurrent,FVcurrent,rgbcurrent = PointClouds.deletepoints(V,FV,rgb,P)

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,P'),GL.Point4d(0,0,0,1))
	colorview(Vcurrent,FVcurrent,rgbcurrent)
	GL.GLGrid(Vplane,FVplane,GL.Point4d(1,1,1,1),0.4)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);


## segment original pointcloud
# riporta i parametri nella loro posizione originale
region=[shape,pointsonplane.+centroid,(params[1],params[2]+centroid)]
filename="facciatalaterale"
from="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\MURI"
to="C:\\Users\\marte\\Documents\\SegmentCloud"
PointClouds.regionsegmentcloud(filename, from, to, region,0.03)


## extract boundary of flat shape
W,EW =  PointClouds.boundaryflatshape(regions[1],0.2)
GL.VIEW([
	#colorview(P,[[i] for i in 1:size(P,2)],Prgb)
	GL.GLGrid(W,EW)
]);


## compute normals
#normals = PointClouds.computenormals(V,FV)
#GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])
