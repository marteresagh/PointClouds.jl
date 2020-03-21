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

	include("Fitting/residual.jl")
	include("Fitting/projection.jl")
	include("Fitting/fit.jl")
	include("Fitting/cone.jl")
	include("Fitting/sphere.jl")
	include("Fitting/cylinder.jl")
	include("Fitting/plane.jl")
	include("Fitting/torus.jl")
	include("Fitting/newfit.jl")


	include("voxel.jl")


	include("printmodel.jl")
	include("matlab.jl")

end
