using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

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

## sshape detection
regions = PointClouds.segmentation(V,FV,rgb,1, .5,"sphere"; VALID=600)
shape,pointsonplane,params=regions[1]
# extract model on plane and remained model
Vsphere, FVsphere = PointClouds.larmodelsphere(params)([36,36])
P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)
GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],1.)
	#colorview(Vcurrent,[[i] for i in 1:size(Vcurrent,2)],rgbcurrent,0.2)
	colorview(P,FP,Prgb)
	#colorview(V,[[i] for i in 1:size(V,2)],rgb)
]);

# sphere model
region=[shape,pointsonplane.+centroid,(params[1]+centroid,params[2])]
filename="cupola"
from="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CUPOLA"
to="C:\\Users\\marte\\Documents\\SegmentCloud"
PointClouds.regionsegmentcloud(filename, from, to, region,0.7)


# P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointson)

# Vcurrent,FVcurrent,rgbcurrent = PointClouds.deletepoints(V,FV,rgb,pointson)




## plane detection
regions = PointClouds.segmentation(V,FV,rgb,1, 0.1,"sphere")
shape,pointsonplane,params=regions[1]
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane,params)
# # extract model on plane and remained model
# P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)
# # color segmentation
# P,Prgb = PointClouds.colorsegmentation(P,FP,Prgb,.25)
# Vcurrent,FVcurrent,rgbcurrent = PointClouds.deletepoints(V,FV,rgb,P)

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.Point4d(0,0,0,1))
	# colorview(Vcurrent,FVcurrent,rgbcurrent)
	GL.GLGrid(Vplane,FVplane,GL.Point4d(1,1,1,1),0.4)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);
