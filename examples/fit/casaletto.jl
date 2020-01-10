using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

fname = "examples/fit/CASALETTO/muri.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

# include("./pointCloud/CASALETTO/V.jl")

include("./CASALETTO/DTmuri.jl")
# Equivalent to =>
# V = AlphaStructures.matrixPerturbation(V);
# DT = AlphaStructures.delaunayWall(V);

filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

pointsonplane,params = PointClouds.findshape(V,FV,rgb,0.02,"plane";index=2742)

axis,centroid = params
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane, axis,centroid)
GL.VIEW([
    colorview(V,VV,rgb)
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);

P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)

W,EW =  PointClouds.extractplaneshape(P,params,0.2)
GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,P'))
	GL.GLGrid(W,EW)
]);
