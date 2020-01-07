using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("./viewfunction.jl")

fname = "examples/fit/CASALETTO/muri.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
centroid,V = PointClouds.subtractaverage(Vtot)
V,a = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,[1]])

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

pointsonplane,axis,centroid = PointClouds.planeshape(V,FV,0.02;index=2742,NOTPLANE=20)


Vplane, FVplane = PointClouds.larmodelplane(pointsonplane, axis,centroid)
GL.VIEW([
    colorview(V,VV,rgb)
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);

P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)
GL.VIEW(
	[
		colorview(P,FP,Prgb);
		GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
	]
);

PointClouds.pointsproj(P,axis,centroid)

function chplane(P,axis,centroid,α)
	mrot = hcat(Lar.nullspace(Matrix(axis')),axis)
	W = Lar.inv(mrot)*(P)
	W1 = W[[1,2],:]
	DT = PointClouds.mat2DT(W1)
	filtration = AlphaStructures.alphaFilter(W1, DT);
	VV, EV, FV = AlphaStructures.alphaSimplex(W1, filtration, α);
	return W1,FV
end

W1,FV = chplane(P,axis,centroid,0.2)
GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,P'))
	GL.GLGrid(W1,FV)
]);

GL.VIEW(
	[
		colorview(P,FP,Prgb);
		#GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
	]
);
