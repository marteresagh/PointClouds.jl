using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using Test


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
