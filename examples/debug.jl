using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
level = 1
allfile = PointClouds.filelevel(fname,level,false)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)
spacing = spacing/2^level

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Voriginal)
aabb=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457]),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875]))

W,EW,FV= PointClouds.boxmodel(aabb)

GL.VIEW(
	[
		#colorview(V,VV,rgb)
		GL.GLGrid(V,EV)
		GL.GLPoints(convert(Lar.Points,coordpoint'))
	]
);

"2.322972769302368e6 4.7701366959991455e6 335.9046516418457 2.322984289455414e6 4.770148216152191e6 347.4248046875"

from = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
to =  "C:\\Users\\marte\\Documents\\SegmentCloud\\roofprova.las"
PointClouds.volumesegmentcloud(from, to, aabb)

V,(VV,EV,FV,CV) = Lar.cuboid([1,1,1],true)
coordpoint = [0.5,0.5,-1.]
Lar.testinternalpoint(V,EV,FV)(coordpoint)
aabb=Lar.boundingbox(V)

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
