using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds
using MATLAB

include("../viewfunction.jl")

## Sphere
V,FV = Lar.apply(Lar.t(3.,3.,3.),Lar.sphere(4.)([50,50]))
#V,FV = Lar.apply(Lar.t(3.,3.,3.),Lar.sphere(4.,pi/2,pi/2)([40,40]))
#V,FV = Lar.cylinder(1.)([10,10])
V = AlphaStructures.matrixPerturbation(V,atol=0.01)

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

# fitting sphere
params = PointClouds.spherefit(V)
Vsphere, FVsphere = PointClouds.larmodelsphere(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,P'),GL.COLORS[6])
	# GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# shpae detection
pointsonshape,params = PointClouds.shapedetection(V,FV,0.02,"sphere")
Vsphere, FVsphere = PointClouds.larmodelsphere(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,pointsonshape'),GL.COLORS[6])
 	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# directional projection
PointClouds.projectpointson(V,params,"sphere")
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLGrid(Vsphere, FVsphere,GL.COLORS[2],0.7)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);



## Cylinder fit

V,FV = Lar.apply(Lar.t(1,2,2),Lar.apply(Lar.r(0,pi/6,0),Lar.cylinder(2.,6,pi/2)([50,50])))
#V,FV = Lar.cylinder(1.,2)([100,100])
V = AlphaStructures.matrixPerturbation(V,atol=0.01)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

# fitting cylinder
params = PointClouds.cylinderfit(V)
Vcyl, FVcyl = PointClouds.larmodelcyl(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# shpae detection
pointsonshape,params = PointClouds.shapedetection(V,FV,0.3,"cylinder")
Vcyl, FVcyl = PointClouds.larmodelcyl(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,P'),GL.COLORS[6])
 	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# directional projection
PointClouds.projectpointson(V,params,"cylinder")
GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLGrid(Vcyl, FVcyl,GL.COLORS[2],0.7)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);


## Cone fit

V,FV = PointClouds.cone(1.,1.)([40,40])
#V,CV = Lar.apply(Lar.t(2,3,4),Lar.apply(Lar.r(pi/3,0,0),PointClouds.cone(2.,2.,2*pi)([36,64])))
#V,CV=Lar.apply(Lar.r(0,-pi/5,0),PointClouds.cone(3.,3.)([36,64]))
V = AlphaStructures.matrixPerturbation(V,atol=0.01)

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	#GL.GLGrid(V,CV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# fit
params = PointClouds.conefit(V)
Vcone, FVcone = PointClouds.larmodelcone(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# shpae detection
pointsonshape,params = PointClouds.shapedetection(V,FV,0.05,"cone")
Vcone, FVcone = PointClouds.larmodelcone(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,pointsonshape'),GL.COLORS[6])
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])


# directional projection
V = AlphaStructures.matrixPerturbation(V,atol=0.5)
PointClouds.projectpointson(V,params,"cone")
GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

## Toro fit

V,CV = Lar.toroidal(2,4)([50,50])
V,CV = Lar.apply(Lar.t(2,5,4),Lar.apply(Lar.r(0,pi/3,0),Lar.toroidal(2,5,2*pi,pi/2)([30,30])))

normals = PointClouds.computenormals(V,CV)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	#GL.GLGrid(V,FV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])


params = PointClouds.torusfit(V,normals)
Vtorus, FVtorus = PointClouds.larmodeltorus(params)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vtorus,FVtorus,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# directional projection
V,CV = Lar.toroidal(2,4)([50,50])
V = AlphaStructures.matrixPerturbation(V,atol=0.5)
PointClouds.projectpointson(V,params,"torus")
GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vtorus, FVtorus,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
