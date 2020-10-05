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
_,_,_,AABB,tightBB,_,_,spacing = PointClouds.readcloudJSON(fname)
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

# GL.VIEW(
# 	[
# 		viewRGB(Vtrasl,FV,rgb);
# 	]
# );


# ======================= RANDOM =====================================
#=
AABB = Lar.boundingbox(Vtrasl)
# RANDOM
planedetected = PointClouds.PlaneDetectionRandom(Vtrasl, FV, 0.02)
#u=4.
#AABB = Lar.boundingbox(planedetected.points).+([-u,-u,-u],[u,u,u])
Vplane,FVplane = PointClouds.DrawPlane(planedetected.plane,AABB)

# GIVEN POINTS
givenPoints = planedetected.points[:,rand(1:size(planedetected.points,2),5)]
planedetected2 = PointClouds.PlaneDetectionFromGivenPoints(Vtrasl, FV, givenPoints, 0.02)
#AABB = Lar.boundingbox(planedetected2.points).+([-u,-u,-u],[u,u,u])
Vplane2,FVplane2 = PointClouds.DrawPlane(planedetected2.plane,AABB)

GL.VIEW(
	[
		viewRGB(Vtrasl,VV,rgb)
		GL.GLGrid(Vplane,FVplane)
		#GL.GLGrid(Vplane2,FVplane2,GL.COLORS[1])
	]
);

=#



# ======================= PUNTI DA FILE =====================================
filename = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\orthophoto\\PuntiPerEstrazionePianiCasaletto_potree16.json"
dataset = PointClouds.PointForPlanes(filename)
PLANES = PointClouds.PlaneDetected[]
for data in dataset
	planedetected = PointClouds.PlaneDetectionFromGivenPoints(V, FV, data, 0.02)
	push!(PLANES,planedetected)
end


#=
ucs = Matrix[]
quotas = Float64[]
for plane in PLANES
	pp = plane.plane
	matrixaffine = convert(Matrix,hcat(Lar.nullspace(Matrix(pp.normal')),pp.normal)')
	quota = matrixaffine*pp.centroid
	push!(ucs,matrixaffine)
	push!(quotas,quota[3])
end

txtpotreedirs = "C:/Users/marte/Documents/GEOWEB/FilePotree/orthophoto/directory.txt"
thickness=0.02
for i in 1:length(PLANES)
	PointClouds.flushprintln("################################################## PLANE_$i...")
	bbin=Lar.boundingbox(PLANES[i].points)
	outputfile = "PIANI_ESTRATTI/PIANO_$i.las"
	coordsystemmatrix = ucs[i]
	quota=quotas[i]
	PointClouds.pointExtraction(
		txtpotreedirs,
		outputfile,
		coordsystemmatrix,
		bbin,
		quota,
		thickness,
		 )
end
=#

# ================== TUTTI I PIANI ==============================================
Vplane,FVplane = PointClouds.DrawPlanes(PLANES,nothing,0.5)
Vplane_trasl = PointClouds.apply_matrix(Lar.t(-trasl...),Vplane)
GL.VIEW(
	[
		#viewRGB(Vtrasl,VV,rgb)
		GL.GLGrid(Vplane_trasl,FVplane)
	]
);


# ================== ESTRAZIONE BORDO ==============================================
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\PIANO_1"

level = 2
allfile = PointClouds.filelevel(fname,level,false)
_,_,_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
spacing = spacing/2^level


W,FW = PointClouds.shapeof(PLANES[1], fname, 2, 0.06)
#W_trasl = PointClouds.apply_matrix(Lar.t(-trasl...),W)
Vbound,EVbound = PointClouds.boundaryflatshape(W,FW)
Vbound_trasl = PointClouds.apply_matrix(Lar.t(-trasl...),Vbound)

GL.VIEW(
	[
		#viewRGB(Vtrasl,VV,rgb)
		#GL.GLGrid(Vplane_trasl,FVplane)
		GL.GLGrid(Vbound_trasl,EVbound)

	]
);
