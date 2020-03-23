using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

# initialization
npoints = 1000
xslope = 0.5
yslope = 0.
off = 1.

## generation random data on plane
xs = 3*rand(npoints)
ys = 4*rand(npoints)
zs = Float64[]

for i in 1:npoints
    push!(zs, xs[i]*xslope + ys[i]*yslope + off+0*rand()) # points perturbation
end

## points input
V = convert(Lar.Points, hcat(xs,ys,zs)')
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

## shape detection
FV = PointClouds.DTprojxy(V) # connection for neighborhood
pointsonshape,params = PointClouds.shapedetection(V,FV,0.05,"plane",VALID=10)


# plane model to view
Vplane,FVplane = PointClouds.larmodelplane(V,params)

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLPoints(convert(Lar.Points,pointsonshape'),GL.COLORS[1])
	GL.GLGrid(Vplane,FVplane,GL.COLORS[2],0.7)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

## plane fitting on all points
params = PointClouds.planefit(V)
# plane model to view
Vplane,FVplane = PointClouds.larmodelplane(V,params)

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLGrid(Vplane,FVplane,GL.COLORS[2],0.7)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);


## directional projection
PointClouds.pointsproj(V,params)
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLGrid(Vplane,FVplane,GL.COLORS[2],0.7)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);
