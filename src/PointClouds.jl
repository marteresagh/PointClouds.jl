__precompile__()

module PointClouds
	using LinearAlgebraicRepresentation
	using LasIO
	Lar = LinearAlgebraicRepresentation
	using Combinatorics
	using JSON
	using DataStructures
	using MATLAB
	using Polynomials
	using LsqFit
	using QHull
	using AlphaStructures
	using SparseArrays


	include("navigatedirectory.jl")
	include("laspointsreader.jl")

	include("geometry.jl")
	include("extractionsimplex.jl")
	include("normals.jl")

	include("mapper.jl")

	include("Fitting/residual.jl")
	include("Fitting/projection.jl")
	include("Fitting/fit.jl")
	include("Fitting/cone.jl")
	include("Fitting/sphere.jl")
	include("Fitting/cylinder.jl")
	include("Fitting/plane.jl")
	include("Fitting/torus.jl")


	include("voxel.jl")


	include("printmodel.jl")
	include("matlab.jl")

end
