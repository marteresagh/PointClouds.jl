using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Voriginal)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

## alpha shape
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.5 #da variare
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);

## shape detection
regions = PointClouds.segmentation(V,FV,rgb,1, .5,"sphere"; VALID=600)
shape,pointsonsphere,params=regions[1]
Vsphere, FVsphere = PointClouds.larmodelsphere(params)([36,36])

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.Point4d(0,0,0,1))
	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],1.)
]);

## segment original pointcloud
# riporta i parametri nella loro posizione originale
region=[shape,pointsonsphere.+centroid,(params[1]+centroid,params[2])]
filename="cupola"
from="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
to="C:\\Users\\marte\\Documents\\SegmentCloud"
PointClouds.regionsegmentcloud(filename, from, to, region,0.7)
