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

	include("fit.jl")
	include("quadricfit.jl")
	include("planefit.jl")
	include("navigatedirectory.jl")
	include("laspointsreader.jl")
	include("matlab.jl")
	include("geometry.jl")
	include("mapper.jl")
	include("torusfit.jl")
	include("voxel.jl")
end
