using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

# 1. Example on plane - generation random points on plane
npoints = 20000
xslope = 0.3
yslope = 0.5
off = 2.

xs = rand(npoints)
ys = rand(npoints)
zs = Float64[]

for i in 1:npoints
    push!(zs, xs[i]*xslope + ys[i]*yslope + off)
end

V = convert(Lar.Points, hcat(xs,ys,zs)')
FV = PointClouds.DTprojxy(V)

normals = PointClouds.computenormals(V,FV)
# normals = PointClouds.flipnormals(normals)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])


# 2. Cylinder
V,FV = Lar.cylinder(1.,2)([100,10])

normals = PointClouds.computenormals(V,FV)
# normals = PointClouds.flipnormals(normals)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])

# 3. Sphere
V,FV = Lar.apply(Lar.t(1.,2.,1.),Lar.sphere(5.)([64,64]))
normals = PointClouds.computenormals(V,FV)
normals = PointClouds.flipnormals(normals)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])

# 4. Torus
V,FV = Lar.toroidal(2,4,2*pi,pi/4)([64,64])
normals = PointClouds.computenormals(V,FV)
# normals = PointClouds.flipnormals(normals)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])



# prova

lista = [1,2,3,4,5,6,7,8,9]
for w in lista
    println(w)
    if w==3
        setdiff(lista,w)
    end
end
