using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds

if VERSION < VersionNumber("1.0.0")
	using Base.Test
else
	using Test
end

include("voxel.jl")
# include("laspointsreader.jl")
# include("navigatedirectory.jl")
# include("fit.jl")
# include("geometry.jl")
include("mapper.jl")
include("matlab.jl")
include("Models/plane.jl")
# include("Models/cylinder.jl")
# include("Models/sphere.jl")
# include("Models/cone.jl")
# include("Models/torus.jl")
