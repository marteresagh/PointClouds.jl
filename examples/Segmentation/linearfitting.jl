using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

npoints = 1000
xslope = 0.5
yslope = 0.
off = 1.

# generation random data
xs = 3*rand(npoints)
ys = 4*rand(npoints)
zs = Float64[]

for i in 1:npoints
    push!(zs, xs[i]*xslope + ys[i]*yslope + off+0.5*rand())
end

V = convert(Lar.Points, hcat(xs,ys,zs)')

# shape detection
FV=PointClouds.DTprojxy(V)
pointsonshape,params = PointClouds.shapedetection(V,FV,0.1,"plane")

# plane fitting
params = PointClouds.planefit(V)

# plane model to view
Vplane,FVplane = PointClouds.larmodelplane(V,params)

GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLPoints(convert(Lar.Points,pointsonshape'),GL.COLORS[1])
	#GL.GLGrid(V,FV,GL.COLORS[2],0.7)
	GL.GLGrid(Vplane,FVplane,GL.COLORS[2],0.7)
	# GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);



# # directional projection
#  PointClouds.pointsproj(V,params)
# # GL.VIEW([
# #     GL.GLPoints(convert(Lar.Points,V'))
# # 	GL.GLGrid(Vplane,FVplane,GL.COLORS[12],1.)
# # ]);
#
#
# #prove
# FV=PointClouds.DTprojxy(V)
#
# rgb=ones(size(V)...)
# pointsonplane, params = PointClouds.findshape(V,FV,rgb,0.02,"plane")
# #
# # GL.VIEW([
# #     colorview(V,FV,rgb)
# # ]);
