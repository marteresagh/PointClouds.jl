using LinearAlgebraicRepresentation #AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
include("viewfunction.jl")
# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\point-cloud-private"
level = 0
allfile = PointClouds.filelevel(fname,level,false)
_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
spacing = spacing/2^level

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Voriginal)
aabb=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457]),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875]))
AABB=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457].-centroid),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875].-centroid))

model = PointClouds.boxmodel(aabb)
GL.VIEW(
	[
		colorview(V,VV,rgb)
		#GL.GLGrid(W,EW)
	]
);

"2.322972769302368e6 4.7701366959991455e6 335.9046516418457 2.322984289455414e6 4.770148216152191e6 347.4248046875"

from = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"

tolas =  "C:\\Users\\marte\\Documents\\SegmentCloud\\roofprova.las"

toply =  "C:\\Users\\marte\\Documents\\SegmentCloud\\roofprova.ply"

PointClouds.segmentpclas(from, tolas, model)

PointClouds.segmentpcply(from, toply, model)

V,(VV,EV,FV,CV) = Lar.cuboid([1,1,1],true)




########  PLY reader

PointClouds.saveply("test.ply", V)


###  Json
aabb=(hcat([.5,.5,.5]),hcat([1,4.,10]))
PointClouds.aabbASCII(folder, aabb)
volume = "C:/Users/marte/Documents/SegmentCloud/CAVA/CAVA.json"
V,CV,FV,EV=PointClouds.volumemodel(volume)

GL.VIEW(
	[
		#colorview(Voriginal.-centroid,VV,rgb)
		GL.GLPoints(convert(Lar.Points,T1'))
		GL.GLGrid(T,FT,GL.Point4d(1,1,1,1))
		#GL.GLLar2gl(V,CV)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)

potree = "C:/Users/marte/Documents/potreeDirectory/pointclouds/point-cloud-private"
folder = "C:/Users/marte/Documents/SegmentCloud/CAVA"
volume = "C:/Users/marte/Documents/FilePotree/cava.json"

aabb=(hcat([295370.8436816006, 4781124.438537028, 225.44601794335939]),hcat([295632.16918208889, 4781385.764037516, 486.77151843164065]))
aabb=(hcat([0,0,0.]),hcat([1,1.,1]))

"295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781385.764037516 486.77151843164065"


ispath(volume)
PointClouds.clip(potree,folder,aabb)


T,(VV,EV,FV,CV)= Lar.cuboid([1,1,1],true)
point=[0,0.5,0.5]
model = T,EV,FV
PointClouds.ispointinpolyhedron(model,point)
