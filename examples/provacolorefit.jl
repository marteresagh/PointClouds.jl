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
pointsonplane,params = PointClouds.findshape(V,FV,0.02,"plane";index=2742)
axis,centroid = params
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane, axis,centroid)

P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)

GL.VIEW([
    colorview(P,FP,Prgb)
]);
