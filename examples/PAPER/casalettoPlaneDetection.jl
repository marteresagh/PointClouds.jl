using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds
using NearestNeighbors
NN = NearestNeighbors
include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
allfile = PointClouds.filelevel(fname,0)
_,_,_,AABB,_,_,_,spacing = PointClouds.readcloudJSON(fname)
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
u=4.

# RANDOM
planedetected = PointClouds.PlaneDetectionRandom(Vtrasl, FV, 0.02)

AABB = Lar.boundingbox(Vtrasl)
#AABB = Lar.boundingbox(planedetected.points).+([-u,-u,-u],[u,u,u])
Vplane,FVplane = PointClouds.DrawPlane(planedetected.plane,AABB)

#GIVEN POINTS
givenPoints = planedetected.points[:,rand(1:size(planedetected.points,2),5)]
planedetected2 = PointClouds.PlaneDetectionFromGivenPoints(Vtrasl, FV, givenPoints, 0.02)


#AABB = Lar.boundingbox(planedetected2.points).+([-u,-u,-u],[u,u,u])
Vplane3,FVplane3 = PointClouds.DrawPlane(planedetected2.plane,AABB)



GL.VIEW(
	[
		viewRGB(Vtrasl,VV,rgb)
		GL.GLGrid(Vplane,FVplane)
		#GL.GLGrid(Vplane2,FVplane2,GL.COLORS[1])
		GL.GLGrid(Vplane3,FVplane3,GL.COLORS[3])
	]
);




kdtree = KDTree(Vtrasl)

idxs, dists = knn(kdtree, Vtrasl[:,3], 2, true)


filename = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\orthophoto\\PuntiPerEstrazionePianiCasaletto_potree16.json"
dataset = PointClouds.PointForPlanes(filename)
