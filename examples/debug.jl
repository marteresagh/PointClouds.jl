using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
include("viewfunction.jl")
# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"
level = 0
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

using MeshIO
const tf = dirname(@__FILE__)

prova = MeshIO.FileIO.load(joinpath(tf, "point.ply"))

joinpath(tf, "point.ply")

f = joinpath(dirname(@__FILE__),"test.ply")
V,(VV,EV,FV,CV)=Lar.cuboid([1,1,1],true)
model = (V,FV)

function saveply(f, vertices; normals=nothing, rgb=nothing)
    io = open(f,"w")

    nV = size(vertices,2)


    # write the header
    write(io, "ply\n")
    write(io, "format ascii 1.0\n")
    write(io, "element vertex $nV\n")
    write(io, "property float x\nproperty float y\nproperty float z\n")

    if !isnothing(normals)
        write(io, "property float nx\nproperty float ny\nproperty float nz\n")
    end

    if !isnothing(rgb)
        write(io, "property float red\nproperty float green\nproperty float blue\n")
    end
    write(io, "end_header\n")

    # write the vertices and faces
    for i in 1:nV
		if normals==rgb
			println(io, join(vertices[:,i], " "))
		elseif !isnothing(normals)
	        println(io, join(vertices[:,i], " "), " ", join(normals[:,i], " "))
		elseif !isnothing(rgb)
	        println(io, join(vertices[:,i], " "), " ", join(rgb[:,i], " "))
		end
		#println(io, join(vertices[:,i], " "), " ", join(normals[:,i], " "), " ", join(floor.(Int,rgb[:,i].*255), " "))
    end
    close(io)
end

saveply("test.ply", vertices, rgb=rgb)
