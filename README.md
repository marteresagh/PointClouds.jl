# PointClouds.jl

[![Build Status](https://travis-ci.org/marteresagh/PointClouds.jl.svg)](https://travis-ci.org/marteresagh/PointClouds.jl)
[![Coveralls](https://coveralls.io/repos/github/marteresagh/PointClouds.jl/badge.svg?branch=master)](https://coveralls.io/github/marteresagh/PointClouds.jl?branch=master)

Julia package for point cloud data managing. Developed under the main project of Computational Visual Design Laboratory (CVDLAB): LAR, [LinearAlgebraicRepresentation.jl](https://github.com/cvdlab/LinearAlgebraicRepresentation.jl), with inputs and outputs formatted in order to be rendered by its associated graphic interface ViewergGL, [ViewerGL.jl](https://github.com/cvdlab/ViewerGL.jl).

# Install

```julia
] add https://github.com/marteresagh/PointClouds.jl
```
### Usage

```julia
using PointClouds
using ViewerGL
GL=ViewerGL

# colored view function based on ViewerGL
include("../viewfunction.jl")

# from a local directory
pc = "path\\potreeDirectory\\pointclouds\\PC"

LOD = 0 # level of detail
LASfiles = PointClouds.filelevel(pc,LOD)
Vcoord,VV,rgb = PointClouds.loadlas(LASfiles...) # LAR model
# translation of pc in the origin
_,V = PointClouds.subtractaverage(Vcoord)

# view
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);
```

## Authors
 - [Maria Teresa Graziano](https://github.com/marteresagh) - (marteresa28@gmail.com)

## Project managers
- Professor [Alberto Paoluzzi](http://paoluzzi.dia.uniroma3.it)
