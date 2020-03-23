using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\MURI"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
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
flag = true
while flag
	global flag
	try
		pointsonshape,params = PointClouds.shapedetection(V,FV,0.02,"plane",VALID=100)
		flag = false
	catch y
		if !isa(y, AssertionError)
			flag = false
			@show "error"
		end
	end
end

pointsonshape,params = PointClouds.shapedetection(V,FV,0.02,"plane",VALID=100)
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

## extract boundary of flat shape
W,EW =  PointClouds.extractplaneshape(P,params,0.2)
GL.VIEW([
	#colorview(P,[[i] for i in 1:size(P,2)],Prgb)
	GL.GLGrid(W,EW)
]);


## compute normals
#normals = PointClouds.computenormals(V,FV)
#GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])
