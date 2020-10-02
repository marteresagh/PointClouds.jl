using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
V,VV,rgb = PointClouds.loadlas(allfile...)
trasl,Vtrasl = PointClouds.subtractaverage(V)

GL.VIEW(
	[
		viewRGB(Vtrasl, VV, rgb)
		GL.GLAxis(GL.Point3d(0,0,0), GL.Point3d(1,1,1))
	]
);


## alpha shape
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		viewRGB(Vtrasl,FV,rgb);
	]
);

## plane detection
planedetected = PointClouds.PlaneDetectionRandom(Vtrasl, FV, 0.02)

u=4.
AABB = Lar.boundingbox(planedetected.points).+([-u,-u,-u],[u,u,u])
Vplane,FVplane = PointClouds.DrawPlane(planedetected.plane,AABB)

GL.VIEW(
	[
		viewRGB(Vtrasl,FV,rgb);
		GL.GLGrid(Vplane,FVplane)
	]
);

givenPoints = planedetected.points[:,rand(1:size(planedetected.points,2),5)]
initPlane = Plane(PointClouds.PlaneFromPoints(givenPoints))
Vplane,FVplane = PointClouds.DrawPlane(initPlane.plane,AABB)

planedetected2 = PointClouds.PlaneDetectionFromGivenPoints(Vtrasl, FV, givenPoints, 0.02)


AABB = Lar.boundingbox(planedetected2.points).+([-u,-u,-u],[u,u,u])
Vplane2,FVplane2 = PointClouds.DrawPlane(planedetected2.plane,AABB)

GL.VIEW(
	[
		viewRGB(Vtrasl,VV,rgb)
		GL.GLGrid(Vplane,FVplane)
		GL.GLGrid(Vplane2,FVplane2,GL.COLORS[2])
	]
);
