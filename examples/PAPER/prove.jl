using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds
using NearestNeighbors
NN = NearestNeighbors
include("../viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
allfile = PointClouds.filelevel(fname,0)
_,_,_,AABB,_,_,_,spacing = PointClouds.readcloudJSON(fname)
V,VV,rgb = PointClouds.loadlas(allfile...)
trasl,Vtrasl = PointClouds.subtractaverage(V)

GL.VIEW(
	[
		viewRGB(Vtrasl, VV, rgb)
		GL.GLAxis(GL.Point3d(0,0,0), GL.Point3d(1,1,1))
	]
);


## alpha shape
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		viewRGB(Vtrasl,FV,rgb);
	]
);

## plane detection
u=4.

# RANDOM
planedetected = PointClouds.PlaneDetectionFromRandomInitPoint(Vtrasl, FV, 0.02)

AABB = Lar.boundingbox(Vtrasl)
#AABB = Lar.boundingbox(planedetected.points).+([-u,-u,-u],[u,u,u])
Vplane,FVplane = PointClouds.DrawPlane(planedetected.plane,AABB)

#GIVEN POINTS
givenPoints = planedetected.points[:,rand(1:size(planedetected.points,2),5)]
planedetected2 = PointClouds.PlaneDetectionFromGivenPoints(Vtrasl, FV, givenPoints, 0.02)


#AABB = Lar.boundingbox(planedetected2.points).+([-u,-u,-u],[u,u,u])
Vplane3,FVplane3 = PointClouds.DrawPlane(planedetected2.plane,AABB)



GL.VIEW(
	[
		viewRGB(Vtrasl,VV,rgb)
		GL.GLGrid(Vplane,FVplane)
		#GL.GLGrid(Vplane2,FVplane2,GL.COLORS[1])
		GL.GLGrid(Vplane3,FVplane3,GL.COLORS[3])
	]
);




kdtree = KDTree(Vtrasl)

idxs, dists = nn(kdtree, Vtrasl[:,3], 2, true)



#
# x = rand(10)
# a = rand()
# b = rand()
# y = Float64[]
#
# for i in 1:size(x,1)
#     push!(y, x[i]*a + b + 0.01*rand()) # points perturbation
# end
# pointsonline = vcat(x',y')
#
# params = PointClouds.linefit(vcat(x',y'))
#
# V,EV = PointClouds.larmodelsegment(pointsonline,params)
#
#
# GL.VIEW(
# 	[
# 		GL.GLPoints(convert(Lar.Points,pointsonline'))
# 		GL.GLGrid(V,EV)
# 		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# 	]
# );
