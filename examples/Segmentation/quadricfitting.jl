using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds
using MATLAB

include("../viewfunction.jl")
## Sphere fit

#V,FV = Lar.apply(Lar.t(3.,3.,3.),Lar.sphere(4.)([50,50]))
V,FV = Lar.apply(Lar.t(3.,3.,3.),Lar.sphere(4.,pi/2,pi/2)([40,40]))
#V,FV = Lar.cylinder(1.)([10,10])

V = AlphaStructures.matrixPerturbation(V,atol=0.1)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

center,radius = PointClouds.spherefit(V)
Vsphere, FVsphere = PointClouds.larmodelsphere(center,radius)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

#PointClouds.pointsprojsphere(V,center,radius)

# studio distanza e residuo di un punto
p = V[:,3]
params = (center,radius)

res = PointClouds.ressphere(p,params)

ressphere = findmax([PointClouds.ressphere(V[:,i],params) for i in 1:size(V,2)])



## Cylinder fit

V,FV = Lar.apply(Lar.t(1,2,2),Lar.apply(Lar.r(0,pi/6,0),Lar.cylinder(2.,6,pi/2)([50,50])))
#V,FV = Lar.cylinder(1.,2)([100,100])

V = AlphaStructures.matrixPerturbation(V,atol=0.1)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

direction,center,radius,height = PointClouds.cylinderfit(V)
Vcyl, FVcyl = PointClouds.larmodelcyl(direction,center,radius,height)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

params = direction,center,radius,height
PointClouds.pointsprojcyl(V,params)

## Cone fit

V,CV = PointClouds.cone(4.,7.,pi/2)([40,40])
#V,CV = Lar.apply(Lar.t(2,3,4),Lar.apply(Lar.r(pi/3,0,0),PointClouds.cone(2.,2.,2*pi)([36,64])))
#V,CV=Lar.apply(Lar.r(0,-pi/5,0),PointClouds.cone(3.,3.)([36,64]))
V = AlphaStructures.matrixPerturbation(V,atol=0.1)
W = [0;0;0]
for i in 1:size(V,2)
	global W
	if V[3,i]>3.
		W=hcat(W,V[:,i])
	end
end
W = W[:,[2:end...]]

V,CV = Lar.apply(Lar.t(1,2,1),Lar.apply(Lar.r(0,pi/6,0),(W,CV)))

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	#GL.GLGrid(V,CV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

coneVertex, coneaxis, angle, height = PointClouds.conefit(V)
Vcone, FVcone = PointClouds.larmodelcone(coneaxis, coneVertex, angle, height)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])
params=coneVertex, coneaxis, angle, height
PointClouds.pointsprojcone(V,params)

## Toro fit

V,CV = Lar.toroidal(2,4,2*pi,pi/2)([50,40])
#V,CV = Lar.apply(Lar.t(2,5,4),Lar.apply(Lar.r(0,pi/3,0),Lar.toroidal(2,5,2*pi,pi/2)([30,30])))
#V = AlphaStructures.matrixPerturbation(V,atol=0.1)
normals = PointClouds.computenormals(V,CV)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	#GL.GLGrid(V,FV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])


N,C,rmajor,rminor = PointClouds.initialtorus(V[:,10:end],normals[:,10:end])
N,C,rmajor,rminor = PointClouds.torusfit(V,normals)
#N,C,rmajor,rminor = PointClouds.mattorusfit(V,normals)
Vtorus, FVtorus = PointClouds.larmodeltorus(N,C,rminor,rmajor)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
 	GL.GLGrid(Vtorus,FVtorus,GL.COLORS[2],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])


#=
open("toro4.ply", "w") do f
	for i=1:size(V,2)
		x=V[1,i]
		y=V[2,i]
		z=V[3,i]
		write(f, "$x $y $z \n")
	end
end
=#
