#__precompile__()

module PointClouds

	using LinearAlgebraicRepresentation
	Lar = LinearAlgebraicRepresentation
	using LasIO, JSON
	using Combinatorics, DataStructures, SparseArrays
	using MATLAB,AlphaStructures
	using Polynomials, LsqFit

	include("navigatedirectory.jl")
	include("laspointsreader.jl")

	include("Geometry/geometry.jl")
	include("Geometry/extractionsimplex.jl")
	include("Geometry/residual.jl")
	include("Geometry/projection.jl")
	include("Geometry/mapper.jl")

	include("normals.jl")

	include("Segmentation/Models/cone.jl")
	include("Segmentation/Models/sphere.jl")
	include("Segmentation/Models/cylinder.jl")
	include("Segmentation/Models/plane.jl")
	include("Segmentation/Models/torus.jl")
	include("Segmentation/extractshape.jl")
	include("Segmentation/newfit.jl")
	include("Segmentation/color.jl")

	include("voxel.jl")

	include("printmodel.jl")
	include("matlab.jl")

end
