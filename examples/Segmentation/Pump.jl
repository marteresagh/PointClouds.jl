using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\PUMP"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

## alpha shapes
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.05 #0.03316948190331459
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

## shape detection
regions = PointClouds.segmentation(V,FV,rgb,1, 0.008,"cylinder";VALID=1000)
shape,pointsoncyl,params = regions[1]
Vcyl, FVcyl = PointClouds.larmodelcyl(params)([36,36])
P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsoncyl)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.Point4d(0,0,0,1))
	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],1.)
]);

## shape of
P,FW =  PointClouds.shapeof(regions[1],0.05)
GL.VIEW([
	#colorview(P,[[i] for i in 1:size(P,2)],Prgb)
	colorview(P,FW,Prgb)
]);

## segment original pointcloud
# riporta i parametri nella loro posizione originale
region=[shape,pointsoncyl.+centroid,(params[1],params[2]+centroid,params[3],params[4])]
filename="tube"
from="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\PUMP"
to="C:\\Users\\marte\\Documents\\SegmentCloud"
PointClouds.regionsegmentcloud(filename, from, to, region,0.008)
