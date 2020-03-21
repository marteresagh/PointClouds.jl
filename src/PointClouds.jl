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

	include("geometry.jl")
	include("extractionsimplex.jl")
	include("normals.jl")

	include("mapper.jl")

	include("Segmentation/residual.jl")
	include("Segmentation/projection.jl")
	include("Segmentation/fit.jl")
	include("Segmentation/cone.jl")
	include("Segmentation/sphere.jl")
	include("Segmentation/cylinder.jl")
	include("Segmentation/plane.jl")
	include("Segmentation/torus.jl")
	include("Segmentation/newfit.jl")
	include("Segmentation/color.jl")


	include("voxel.jl")


	include("printmodel.jl")
	include("matlab.jl")

end
