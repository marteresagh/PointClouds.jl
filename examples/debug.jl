using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
include("viewfunction.jl")
# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
level = 1
allfile = PointClouds.filelevel(fname,level,false)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)
spacing = spacing/2^level

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Voriginal)
aabb=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457]),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875]))
AABB=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457].-centroid),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875].-centroid))

W,EW,FW = PointClouds.boxmodel(AABB)
GL.VIEW(
	[
		colorview(V,VV,rgb)
		GL.GLGrid(W,EW)
	]
);

"2.322972769302368e6 4.7701366959991455e6 335.9046516418457 2.322984289455414e6 4.770148216152191e6 347.4248046875"

from = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
to =  "C:\\Users\\marte\\Documents\\SegmentCloud\\roofprova.las"
PointClouds.volumetricsegmentcloudlas(from, to, aabb)

V,(VV,EV,FV,CV) = Lar.cuboid([1,1,1],true)


model = (V,EV,FV)
coordpoint = [-0.5,.5,.5]
@show ispointinpolyhedron(model,coordpoint)

aabb=Lar.boundingbox(V)
GL.VIEW(
	[
		#colorview(V,VV,rgb)
		GL.GLGrid(V,EV)
		GL.GLPoints(convert(Lar.Points,coordpoint'))
	]
);

#=
open("FV.jl", "w") do f
	write(f, "[")
	for simplex in FV
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#


########  PLY reader


const tf = dirname(@__FILE__)

prova = MeshIO.FileIO.load(joinpath(tf, "point.ply"))

joinpath(tf, "point.ply")

f = joinpath(dirname(@__FILE__),"test.ply")
V,(VV,EV,FV,CV)=Lar.cuboid([1,1,1],true)
model = (V,FV)

PointClouds.saveply("test.ply", V, rgb)
