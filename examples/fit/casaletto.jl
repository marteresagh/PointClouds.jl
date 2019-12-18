using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using Tesi

include("./viewfunction.jl")

fname = "examples/fit/CASALETTO/muri.las"
Vtot,VV,rgb = Tesi.loadlas(fname)
V,a = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,[1]])

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


# include("./pointCloud/CASALETTO/V.jl")
include("./CASALETTO/DTmuri.jl")

# #Equivalent to =>
# V = AlphaStructures.matrixPerturbation(V);
#DT = AlphaStructures.delaunayWall(V);

filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

pointsonplane,plane = Tesi.planeshape(V,FV,0.02,20)
Vplane, FVplane = Tesi.larmodelplane(pointsonplane, plane)
GL.VIEW([
    colorview(V,VV,rgb)
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);

#allplanes,myV,myFV = Tesi.findallplane(V,FV,0.02,50,20)
#
# meshes = [GL.GLGrid(allplanes[1][i],allplanes[2][i]) for i in 1:length(allplanes[1])]
# GL.VIEW([
#  	colorview(V,VV,rgb),
#  	meshes...,
#  	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#
# GL.VIEW([
# 	GL.GLGrid(myV,myFV)
# 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])

# allplanes2,myV2,myFV2 = Tesi.findallplane(myV,myFV,0.02,500,2)
#
# push!(allplanes[1],allplanes2[1]...)
# push!(allplanes[2],allplanes2[2]...)
#
# meshes=[GL.GLGrid(allplanes[1][i],allplanes[2][i]) for i in 1:length(allplanes[1])]
# GL.VIEW([
# 	#colorview(V,VV,rgb),
# 	meshes...
# ])
#
# GL.VIEW([
# 	GL.GLGrid(myV2,myFV2)
# ])
