using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CUPOLA"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Voriginal)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.5 #da variare
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);



pointson,params = PointClouds.findshape(V,FV,rgb,0.3,"sphere",index=4342)

# sphere model
Vsphere, FVsphere = PointClouds.larmodelsphere(params...)([36,36])

P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointson)

Vcurrent,FVcurrent,rgbcurrent = PointClouds.deletepoints(V,FV,rgb,pointson)

GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,V[:,10876]'))
	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[2],1.)
	#colorview(Vcurrent,[[i] for i in 1:size(Vcurrent,2)],rgbcurrent,0.2)
	colorview(P,[[i] for i in 1:size(P,2)],Prgb)
	#colorview(V,[[i] for i in 1:size(V,2)],rgb)
]);


#ressphere = max(Lar.abs.([PointClouds.ressphere(P[:,i],params) for i in 1:size(P,2)])...)




########################### PROVA
#
# V,FV = Lar.apply(Lar.t(1.,2.,1.),Lar.sphere(5.)([64,64]))
#
# V = AlphaStructures.matrixPerturbation(V,atol=0.1)
#V,FV = Lar.apply(Lar.r(-pi/4,0,0),Lar.cylinder(1.)([100,20]))
#V,FV = Lar.cylinder(1.)([10,10])
# DT = PointClouds.delaunayMATLAB(V)
# filtration = AlphaStructures.alphaFilter(V, DT);
#
# α = 0.4 #da variare
# VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);
#
# GL.VIEW([
# 	GL.GLPoints(convert(Lar.Points,V'))
# 	GL.GLGrid(V,FV)
# 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ]);

# rgb=ones(3,size(V,2))
#
#
# pointson,params = PointClouds.findshape(V,FV,rgb,1.,"sphere")
# center,radius = PointClouds.spherefit(V[:,[1:10...]])
# Vsphere, FVsphere = PointClouds.larmodelsphere(center,radius)()
#
# GL.VIEW([
#  	GL.GLPoints(convert(Lar.Points,V[:,[1:10...]]'))
#  	GL.GLGrid(Vsphere,FVsphere,GL.COLORS[1],0.2)
#  	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#
