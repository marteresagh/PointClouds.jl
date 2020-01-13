using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("./viewfunction.jl")

fname = "examples/fit/CASALETTO/muri.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Vtot)

include("fit/CASALETTO/DTmuri.jl")
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

min = [0.3,0.3,0.1]
max = [0.8,0.7,0.4]

min = [0.3,0.2,0.1]
max = [0.7,0.6,0.6]

pointsonplane, params = PointClouds.findshape(V,FV,rgb,0.02,"plane";index=2742,min=min,max=max)
# axis,centroid = params
# Vplane, FVplane = PointClouds.larmodelplane(pointsonplane, axis, centroid)

P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)
myV,myFV,myrgb = PointClouds.modelremained(V,FV,rgb,pointsonplane)
GL.VIEW([
    #GL.GLGrid(Vplane,FVplane)
    colorview(P,[[i] for i in 1:size(P,2)],Prgb)
	colorview(myV,[[i] for i in 1:size(myV,2)],myrgb,0.3)
]);
rgb=ones(3,6678)*0.1

W,EW =  PointClouds.extractplaneshape(P,params,α)

GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,P'))
	GL.GLGrid(W,EW)
	colorview(myV,[[i] for i in 1:size(myV,2)],myrgb,0.3)
]);
