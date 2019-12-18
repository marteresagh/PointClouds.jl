using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using Tesi

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
N,C = Tesi.planefit(V)

Vplane,FVplane = Tesi.larmodelplane(V,(N...,Lar.dot(N,C)))

GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);

Tesi.pointsproj(V,N,C) #TODO?? così sto modificando i punti originali della nuvola
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
	GL.GLGrid(Vplane,FVplane,GL.COLORS[1],0.5)
]);
Tesi.distpointplane(V[:,1],N,C)
Tesi.resplane(V[:,1],N,C) 
resplane = max(Lar.abs.([Tesi.resplane(V[:,i],N,C) for i in 1:size(V,2)])...)


#
#
# V = [0.5 1. 2. 2.5 3. 4. 5. 2.; 0.001 0.001 0.003 -0.001 -0.001 -0.003 0. 2.; 1. 2. 0.5 5. 4. 1. 2. 5.]
# VV = [[i] for i = 1:size(V,2)]
# FV = [[1,2,3],[1,2,8],[2,3,4],[2,4,8],[3,4,5],[3,5,6],[5,6,7]]
# EV = Lar.simplexFacets(FV)
# # EV = Lar.simplexFacets(FV)
# # adj = Lar.verts2verts(EV)
#
# GL.VIEW([
# 	GL.GLExplode(
# 		V,
# 		[[t] for t in FV],
# 		1.,1.,1.,	# Explode Ratio
# 		99, 1		# Colors
# 	);
#
# 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1));
# 	]
# )
#
# pointsonplane,plane = Tesi.planeshape(V,FV,0.02,3)
#
# Vplane, FVplane = Tesi.larmodelplane(pointsonplane,plane)
#
# GL.VIEW([
#     GL.GLPoints(convert(Lar.Points,V'))
# 	GL.GLPolyhedron(Vplane,FVplane)
# 	GL.GLAxis(GL.Point3d(-1, -1, -1), GL.Point3d(1, 1, 1))
# ]);
#
# myV,myFV=Tesi.modelremained(V,FV,pointsonplane)
#
# GL.VIEW([
# 	GL.GLExplode(
# 		myV,
# 		[[t] for t in myFV],
# 		1.,1.,1.,	# Explode Ratio
# 		99, 1		# Colors
# 	);
#
# 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1));
# 	]
# )
