using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")
include("./geometricmodel.jl")
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);


DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 5.
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);
rgb=ones(size(V))
# GL.VIEW(
# 	[
# 		colorview(V,FV,rgb)
# 	]
# );

## Plane
pointsonplane,params = PointClouds.findshape(V,FV,rgb,0.5,"plane",index=574)
myV,myFV,myrgb = PointClouds.deletepoints(V,FV,rgb,pointsonplane)
P,EP=PointClouds.extractplaneshape(pointsonplane,params,5.)
DT=PointClouds.DTprojxy(P)
pointsonplane1,params1 = PointClouds.findshape(myV,myFV,myrgb,0.5,"plane",index=2096)
myV,myFV,myrgb = PointClouds.deletepoints(myV,myFV,myrgb,pointsonplane1)

pointsonplane2,params2 = PointClouds.findshape(myV,myFV,myrgb,0.5,"plane",index=1911)
myV,myFV,myrgb = PointClouds.deletepoints(myV,myFV,myrgb,pointsonplane2)



#plane
Vplane1, FVplane1 = PointClouds.larmodelplane(pointsonplane1,params1)
Vplane2, FVplane2 = PointClouds.larmodelplane(pointsonplane2,params2)
# GL.VIEW([
# 	GL.GLPoints(convert(Lar.Points,myV'),GL.COLORS[6])
# 	#GL.GLPoints(convert(Lar.Points,pointsonplane2'),GL.COLORS[3])
#  	GL.GLGrid(Vplane,FVplane,GL.COLORS[2],0.7)
#  	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])



## cylinder
pointsoncyl,params = PointClouds.findshape(myV,myFV,myrgb,0.5,"cylinder",index=477)
myV,myFV,myrgb = PointClouds.deletepoints(myV,myFV,myrgb,pointsoncyl)

pointsoncyl1,params1 = PointClouds.findshape(myV,myFV,myrgb,.5,"cylinder",index=14)
myV,myFV,myrgb = PointClouds.deletepoints(myV,myFV,myrgb,pointsoncyl1)

pointsoncyl2,params2 = PointClouds.findshape(myV,myFV,myrgb,.5,"cylinder",index=125)
myV,myFV,myrgb = PointClouds.deletepoints(myV,myFV,myrgb,pointsoncyl2)

#cylinder model
Vcyl, FVcyl = PointClouds.larmodelcyl(params...)([36,1])
Vcyl1, FVcyl1 = PointClouds.larmodelcyl(params1...)([36,1])
Vcyl2, FVcyl2 = PointClouds.larmodelcyl(params2...)([36,1])
# GL.VIEW([
# 	GL.GLPoints(convert(Lar.Points,myV'),GL.COLORS[6])
#  	GL.GLPoints(convert(Lar.Points,pointsoncyl2'),GL.COLORS[5])
#  	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],0.7)
#  	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])

## sfera
pointsonsphere,params = PointClouds.findshape(myV,myFV,myrgb,.5,"sphere",index=17)
Vsphere, FVsphere = PointClouds.larmodelsphere(params...)([36,36])
GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,pointsonsphere'),GL.COLORS[6])
 	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

myV,myFV,myrgb = PointClouds.deletepoints(myV,myFV,myrgb,pointsonsphere)

## cono
pointsoncone,params = PointClouds.findshape(myV,myFV,myrgb,1000.,"cone")
params = PointClouds.conefit(pointsoncone)
Vcone, FVcone = PointClouds.larmodelcone(params...)([36,36])
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,myV'),GL.COLORS[6])
	GL.GLPoints(convert(Lar.Points,pointsoncone'),GL.COLORS[3])

 	GL.GLGrid(Vcone,FVcone,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,myV'),GL.COLORS[6])
	# GL.GLPoints(convert(Lar.Points,pointsoncone'),GL.COLORS[11])
	# GL.GLGrid(Vcone,FVcone,GL.COLORS[11],0.7)

	GL.GLPoints(convert(Lar.Points,pointsonplane'),GL.COLORS[5])
	GL.GLPoints(convert(Lar.Points,pointsonplane1'),GL.COLORS[5])
	GL.GLPoints(convert(Lar.Points,pointsonplane2'),GL.COLORS[5])
	GL.GLGrid(P,DT,GL.COLORS[5],0.7)
	GL.GLGrid(Vplane1,FVplane1,GL.COLORS[5],0.7)
	GL.GLGrid(Vplane2,FVplane2,GL.COLORS[5],0.7)

	# GL.GLPoints(convert(Lar.Points,pointsoncyl'),GL.COLORS[8])
	# GL.GLPoints(convert(Lar.Points,pointsoncyl1'),GL.COLORS[8])
	# GL.GLPoints(convert(Lar.Points,pointsoncyl2'),GL.COLORS[8])
	# GL.GLGrid(Vcyl,FVcyl,GL.COLORS[8],0.7)
	# GL.GLGrid(Vcyl1,FVcyl1,GL.COLORS[8],0.7)
	# GL.GLGrid(Vcyl2,FVcyl2,GL.COLORS[8],0.7)

	# GL.GLPoints(convert(Lar.Points,pointsonsphere'),GL.COLORS[10])
	# GL.GLGrid(Vsphere,FVsphere,GL.COLORS[10],0.7)
 	# GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
