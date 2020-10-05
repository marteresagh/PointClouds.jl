__precompile__()

module PointClouds

	using LinearAlgebraicRepresentation
	Lar = LinearAlgebraicRepresentation
	using LasIO, LazIO, JSON
	using Combinatorics, DataStructures, SparseArrays
	using MATLAB,AlphaStructures
	using Polynomials, LsqFit
	using Images
	using Dates
	using NearestNeighbors

	mutable struct Plane
	    normal::Array{Float64,1}
	    centroid::Array{Float64,1}
	end

	struct PlaneDetected
		points::Lar.Points
		plane::Plane
	end

	flushprintln(s...) = begin
		println(stdout,s...)
		flush(stdout)
	end

	include("navigatedirectory.jl")
	# include("extractpc.jl")

	include("Geometry/geometry.jl")
	include("Geometry/extractionsimplex.jl")
	include("Geometry/residual.jl")
	include("Geometry/projection.jl")
	include("Geometry/mapper.jl")
	include("Geometry/normals.jl")

	# include("Segmentation/Models/cone.jl")
	# include("Segmentation/Models/sphere.jl")
	# include("Segmentation/Models/cylinder.jl")
	# include("Segmentation/Models/plane.jl")
	# include("Segmentation/Models/torus.jl")
	include("Segmentation/Models/line.jl")
	include("Segmentation/extractshape.jl")
	include("Segmentation/segmentation.jl")
	include("Segmentation/color.jl")

	include("voxel.jl")
	include("bool3d.jl")

	#include("printmodel.jl")
	include("matlab.jl")

	include("FileIO/ply.jl")
	include("FileIO/json.jl")
	include("FileIO/las.jl")
	include("FileIO/utilities.jl")
	include("FileIO/hierarchy.jl")

	include("Orthophoto/orthophoto.jl")
	include("Orthophoto/extraction.jl")
	include("Orthophoto/common.jl")
	include("Orthophoto/geometry.jl")

	include("Segmentation/PLANE.jl")

end
