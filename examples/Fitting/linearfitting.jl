using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

npoints = 200
xslope = 1.
yslope = 0.
off = 5.

# generation random data
xs = rand(npoints)
ys = rand(npoints)
zs = []

for i in 1:npoints
    push!(zs, xs[i]*xslope + ys[i]*yslope + off+rand())
end

V = convert(Lar.Points, hcat(xs,ys,zs)')

VV = [[i] for i = 1:size(V,2)]

# plane fitting
params = PointClouds.planefit(V)

# plane shape to view
Vplane,FVplane = PointClouds.larmodelplane(V,params)

GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);

# directional projection
PointClouds.pointsproj(V,params)
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vplane,FVplane,GL.COLORS[12],1.)
]);
