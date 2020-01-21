using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds
using MATLAB

################################################################################ Sphere fit
V,FV = Lar.apply(Lar.t(1.,2.,1.),Lar.sphere(5.)([64,64]))
#V,FV = Lar.apply(Lar.r(-pi/4,0,0),Lar.cylinder(1.)([100,20]))
#V,FV = Lar.cylinder(1.)([10,10])

V = AlphaStructures.matrixPerturbation(V,atol=0.1)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'))
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

center,radius = PointClouds.spherefit(V)
Vsphere, FVsphere = PointClouds.larmodelsphere(center,radius)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[4],0.2)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

#PointClouds.pointsprojsphere(V,center,radius)

# studio distanza e residuo di un punto
p = V[:,3]
params = (center,radius)

res = PointClouds.ressphere(p,center,radius)

ressphere = max(Lar.abs.([PointClouds.ressphere(V[:,i],center,radius) for i in 1:size(V,2)])...)



################################################################################ Cylinder fit
V,FV = Lar.apply(Lar.r(-pi/3,0,0),Lar.apply(Lar.t(0,0,-10),Lar.cylinder(10.7,20)([100,10])))
V,FV = Lar.cylinder(1.,2)([10,10])

V = AlphaStructures.matrixPerturbation(V,atol=0.1)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,V'))
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

direction,center,radius,height = PointClouds.cylinderfit(V)
Vcyl, FVcyl = PointClouds.larmodelcyl(direction,center,radius,height)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

PointClouds.pointsprojcyl(V,direction,center,radius)
# studio distanza e residuo di un punto
p = V[:,546]
res = PointClouds.rescyl(p,params)
rescyl = max(Lar.abs.([PointClouds.rescyl(V[:,i],direction,center,radius) for i in 1:size(V,2)])...)

################################################################################ Cone fit
V,CV = PointClouds.cone(4.,7.)([64,64])
#V,CV = Lar.apply(Lar.t(2,3,4),Lar.apply(Lar.r(pi/3,0,0),PointClouds.cone(2.,2.,2*pi)([36,64])))
#V,CV=Lar.apply(Lar.r(0,-pi/5,0),PointClouds.cone(3.,3.)([36,64]))
V = AlphaStructures.matrixPerturbation(V,atol=0.1)
W=[0;0;0]
for i in 1:size(V,2)
	global W
	if V[3,i]>3.
		W=hcat(W,V[:,i])
	end
end
W=W[:,[2:end...]]

V,CV = Lar.apply(Lar.t(2,3,4),Lar.apply(Lar.r(pi/3,0,0),(W,CV)))

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,W'))
 	#GL.GLGrid(V,CV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

coneVertex, coneaxis, angle, height = PointClouds.conefit(V)  # invece che il raggio mi devo far tornare l'angolo e quindi il raggio lo calcolo in larmodelcone
Vcone, FVcone = PointClouds.larmodelcone(coneaxis, coneVertex, angle, height)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

PointClouds.pointsprojcone(V,coneaxis,coneVertex,angle)

################################################################################ Toro fit


V,CV = Lar.toroidal(2,4,2*pi,2*pi)()
V,CV = Lar.apply(Lar.t(2,3,4),Lar.apply(Lar.r(0,pi/6,0),Lar.toroidal(2,5,2*pi,pi/2)([64,64])))
V = AlphaStructures.matrixPerturbation(V,atol=0.1)


GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	#GL.GLGrid(V,FV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

N,C,r1,r0 = PointClouds.initialtorus(V)
N,C,r1,r0 = PointClouds.torusfit(V)  # se i dati hanno molto rumore funziona meglio LM
C,N,r1,r0 = PointClouds.mattorusfit(V) # se i dati non hanno rumore funziona meglio GN
Vcone, FVcone = PointClouds.larmodeltorus(N,C,r0,r1)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])


################################################################################ Calcolo residui

V,FV = Lar.apply(Lar.r(-pi/3,0,0),Lar.apply(Lar.t(0,0,-10),Lar.cylinder(1,20)([100,20])))

V,FV = Lar.apply(Lar.t(1.,2.,1.),Lar.sphere(1.5)([50,50]))

params = (1,2,1)
V,FV = Lar.apply(Lar.t(2,3,4),Lar.apply(Lar.r(-pi/3,pi/4,-pi/5),PointClouds.ellipsoid(params)([50,50])))

params=(1.,2.,3.)
V,FV = PointClouds.hyperboloid(params)([36,36])

V,CV = PointClouds.cone(4.,7.)([64,64])

V,CV=Lar.apply(Lar.r(pi/5,0,0),PointClouds.cylinderellip((10,5,20),2*pi)([36,36]))

V = AlphaStructures.matrixPerturbation(V,atol=0.01)

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	#GL.GLGrid(V,CV,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

center,radius = PointClouds.spherefit(V)
ressphere = max(Lar.abs.([PointClouds.ressphere(V[:,i],center,radius) for i in 1:size(V,2)])...)

Vsphere, FVsphere = PointClouds.larmodelsphere(center,radius)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[4],0.7)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])


direction,center,radius,height = PointClouds.cylinderfit(V)
rescyl = max(Lar.abs.([PointClouds.rescyl(V[:,i],direction, center, radius) for i in 1:size(V,2)])...)

Vcyl, FVcyl = PointClouds.larmodelcyl(direction,center,radius,height)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

center, radii, rot = PointClouds.hefit(V)
reshe = max(Lar.abs.([PointClouds.reshe(V[:,i],center, radii, rot) for i in 1:size(V,2)])...)
Vell, FVell = PointClouds.larmodelellipsoid(center, radii, rot)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vell,FVell,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

Vhyp, FVhyp = PointClouds.larmodelhyperboloid(center,radii, rot)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vhyp, FVhyp,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

coneVertex, coneaxis, radius, height = PointClouds.conefit(V)
rescone = max(Lar.abs.([PointClouds.rescone(V[:,i], coneVertex, coneaxis, radius, height) for i in 1:size(V,2)])...)

Vcone, FVcone = PointClouds.larmodelcone(coneaxis,coneVertex,radius, height)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V'))
 	GL.GLGrid(Vcone,FVcone,GL.COLORS[4],0.8)
 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

center, radii, rot = PointClouds.cylellipfit(V)
reshe = max(Lar.abs.([PointClouds.reshe(V[:,i], center, radii, rot) for i in 1:size(V,2)])...)

Vcyl, FVcyl = PointClouds.larmodelcylell(center, radii, rot)()

GL.VIEW([
 	GL.GLPoints(convert(Lar.Points,V[:,259]'))
 	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[4],0.8)
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
