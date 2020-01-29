using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

# 1. input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\MURI"
allfile = PointClouds.filelevel(fname,0,false)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)

# GL.VIEW(
# 	[
# 		colorview(V,VV,rgb)
# 	]
# );



# 2. alpha shape
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

# GL.VIEW(
# 	[
# 		colorview(V,FV,rgb);
# 		#colorview(V,TV,rgb)
# 	]
# );
#

#compute normals
normals = PointClouds.computenormals(V,FV)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])

# 3.1 plane without filter by color

# pointsonplane,params = PointClouds.findshape(V,FV,rgb,0.02,"plane";index = 6729)
#
# Vplane, FVplane = PointClouds.larmodelplane(pointsonplane, params)
# GL.VIEW([
#     colorview(V,VV,rgb)
# 	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
# ]);
#
# P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)
#
# W,EW =  PointClouds.extractplaneshape(P,params,0.2)
# GL.VIEW([
# 	GL.GLPoints(convert(Lar.Points,P'))
# 	GL.GLGrid(W,EW)
# ]);
#


# 3.2 plane with filter by color
# min = [0.3,0.3,0.1]
# max = [0.8,0.7,0.4]

min = [0.3,0.2,0.1]
max = [0.7,0.6,0.6]

pointsonplane, params = PointClouds.findshape(V,FV,rgb,0.02,"plane";index = 6729,min=min,max=max)

Vplane, FVplane = PointClouds.larmodelplane(pointsonplane,params)
P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsonplane)

# 3.3 remained model
Vcurrent,FVcurrent,RGBcurrent = PointClouds.deletepoints(V,FV,rgb,pointsonplane)


# 4. views
GL.VIEW([
    GL.GLGrid(Vplane,FVplane)
    colorview(P,[[i] for i in 1:size(P,2)],Prgb)
	colorview(Vcurrent,[[i] for i in 1:size(Vcurrent,2)],RGBcurrent,0.3)
]);

W,EW =  PointClouds.extractplaneshape(P,params,α)



GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,P'))
	GL.GLGrid(W,EW,GL.COLORS[1],1.)
	colorview(Vcurrent,[[i] for i in 1:size(Vcurrent,2)],RGBcurrent,0.3)
]);

#
# include("./../../T.jl")
#
# include("./../../ET.jl")
#
# GL.VIEW([
# 	#GL.GLPoints(convert(Lar.Points,P'))
# 	GL.GLGrid(T,ET,GL.COLORS[1],1.)
#
# ]);
#
#
#
#
#
# Vcurrent, FVcurrent,RGBcurrent,allshapes = PointClouds.findall(V,FV,rgb,8,0.05,"plane";NOTSHAPE=100)
#
#
# function planarshapes(allshapes,scale)
# 	out = Array{Lar.Struct,1}()
# 	for item in allshapes
# 		P,params=item
# 		W,EW =  extractplaneshape(P,params,α,scale)
# 		push!(out, Lar.Struct([(W,EW)]))
# 	end
# 	out = Lar.Struct( out )
# 	V,CV = Lar.struct2lar(out)
# 	return V,CV
# end
#
# T,CT=planarshapes(allshapes,2.)
#
# GL.VIEW([
# 	#GL.GLPoints(convert(Lar.Points,P'))
# 	GL.GLGrid(T,CT,GL.COLORS[1],1.)
#
# ]);
