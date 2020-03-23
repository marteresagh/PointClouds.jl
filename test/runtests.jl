using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds

if VERSION < VersionNumber("1.0.0")
	using Base.Test
else
	using Test
end

# include("navigatedirectory.jl")
# include("fit.jl")

# UTILITIES
include("geometry.jl")
include("laspointsreader.jl")
include("mapper.jl")
include("matlab.jl")

# FITTING MODEL
include("Models/plane.jl")
include("Models/cylinder.jl")
include("Models/sphere.jl")
include("Models/cone.jl")
include("Models/torus.jl")

# VOXELIZATION
include("voxel.jl")
