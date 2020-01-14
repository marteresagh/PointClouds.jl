using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("../viewfunction.jl")
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.mat3DT(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3 #0.03316948190331459
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);

#1. first plane
pointsonplane1, params1 = PointClouds.findshape(V,FV,rgb,0.02,"plane"; index=8083)
axis,centroid = params1
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane1, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

# P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)

#2. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane1)

pointsonplane2, params2 = PointClouds.findshape(V,FV,rgb,0.02,"plane"; index=1338)
axis,centroid = params2
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane2, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

#3. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane2)

pointsonplane3, params3 = PointClouds.findshape(V,FV,rgb,0.02,"plane"; index=2669)
axis,centroid = params3
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane3, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

#4. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane3)

pointsonplane4, params4 = PointClouds.findshape(V,FV,rgb,0.02,"plane";index=4597)
axis,centroid = params4
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane4, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

#4. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane4)

pointsonplane5, params5 = PointClouds.findshape(V,FV,rgb,0.02,"plane";index=2636)
axis,centroid = params5
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane5, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

#5. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane5)

pointsonplane6, params6 = PointClouds.findshape(V,FV,rgb,0.02,"plane";index=4210)
axis,centroid = params6
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane6, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);


#6. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane6)

pointsonplane7, params7 = PointClouds.findshape(V,FV,rgb,0.02,"plane";index=3696)
axis,centroid = params7
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane7, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);


#7. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane7)

pointsonplane8, params8 = PointClouds.findshape(V,FV,rgb,0.03,"plane";index=1079)
axis,centroid = params8
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane8, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);


#8. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane8)

pointsonplane9, params9 = PointClouds.findshape(V,FV,rgb,0.03,"plane";index=1726)
axis,centroid = params9
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane9, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

#9. other plane
V,FV,rgb = PointClouds.modelremained(V,FV,rgb,pointsonplane9)

pointsonplane10, params10 = PointClouds.findshape(V,FV,rgb,0.05,"plane";index=611)
axis,centroid = params10
Vplane, FVplane = PointClouds.larmodelplane(pointsonplane10, axis, centroid)

GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(V,VV,rgb)
]);

allpoints=[pointsonplane1,pointsonplane2,pointsonplane3,pointsonplane4,pointsonplane5,pointsonplane6,pointsonplane7,pointsonplane8,pointsonplane9,pointsonplane10]
allplane=[params1,params2,params3,params4,params5,params6,params7,params8,params9,params10]


flat(allpoints,allplane)
p = 0.5 #spacing cupola 0.4, spacing casaletto 0.27404680848121645,

W,CW = PointClouds.voxeloriented(allpoints,allplane,p,0)
T,CT = PointClouds.pointclouds2cubegrid(V,p,0)
W, ∂FW = PointClouds.extractsurfaceboundary(W,CW)

GL.VIEW(
	[
		#colorview(V,[[i] for i in 1:size(V,2)],rgb)
		GL.GLLar2gl(W,CW)
		#GL.GLLar2gl(T,CT)
	]
)


#=

open("V0.jl", "w") do f
	n=size(W,2)
	write(f, "[ ")
	for i in 1:n
		x = W[1,i]
		write(f, "$x ")
	end
	write(f, ";\n")
	for i in 1:n
		y = W[2,i]
		write(f, "$y ")
	end
	write(f, ";\n")
	for i in 1:n
		z = W[3,i]
		write(f, "$z ")
	end
	write(f, "]")
end



open("CV0.jl", "w") do f
	write(f, "[")
	for simplex in CW
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
