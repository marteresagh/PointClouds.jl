using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

# generation random points on plane
npoints = 1000
xslope = 3.
yslope = 0.
off = 5.

xs = rand(npoints)
ys = rand(npoints)
zs = Float64[]

for i in 1:npoints
    push!(zs, xs[i]*xslope + ys[i]*yslope + off)
end

V = convert(Lar.Points, hcat(xs,ys,zs)')
FV=PointClouds.DTprojxy(V)


# other examples
# V,FV = Lar.cylinder(1.,2)([100,10])
#
# V,FV = Lar.apply(Lar.t(1.,2.,1.),Lar.sphere(5.)([64,64]))
#
# V,FV = Lar.toroidal(2,4,2*pi,2*pi)()


# compute normals
normals = PointClouds.computenormals(V,FV)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(-1,-1,-1),GL.Point3d(1,1,1))])
