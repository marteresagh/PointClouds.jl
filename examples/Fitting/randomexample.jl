using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

npoints = 20
xslope = 1
yslope = 0
off = 5

# create random data
xs = rand(npoints)
ys = rand(npoints)
zs = []

for i in 1:npoints
    push!(zs,xs[i]*xslope + ys[i]*yslope + off+rand())
end

V = convert(Lar.Points,hcat(xs,ys,zs)')

VV = [[i] for i = 1:size(V,2)]
N,C = PointClouds.planefit(V)

Vplane,FVplane = PointClouds.larmodelplane(V,N,C)

GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);

PointClouds.pointsproj(V,N,C)
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);



# PointClouds.resplane(V[:,1],N,C)
# resplane = max(Lar.abs.([PointClouds.resplane(V[:,i],N,C) for i in 1:size(V,2)])...)
