using LinearAlgebraicRepresentation #AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL



###  Json
aabb=(hcat([.5,.5,.5]),hcat([1,4.,10]))
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


## image julia
using LinearAlgebraicRepresentation #AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using Images
using ViewerGL
GL = ViewerGL
include("viewfunction.jl")
n = 300
V = rand(3,n)
VV=[[i] for i in 1:n]

example=Lar.apply(Lar.r(0,0,pi/4),Lar.apply(Lar.s(2.,5.,3.),(V,VV)))
GL.VIEW(
	[
		#GL.GLPoints(convert(Lar.Points,V[:,4]'))
		viewRGB(example...,V)
		#GL.GLGrid(model[1],model[3],GL.Point4d(1,1,1,1))
		#viewRGB(axismodel...,[0 1. 0 0;0 0. 1 0;0 0. 0 1])
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)


GSD = 0.05
PO = "YZ-"
#coordsystemmatrix = PointClouds.newcoordsyst(PO)

coordsystemmatrix = (Lar.r(pi/4,0,0)*Lar.r(0,0,pi/3))[1:3,1:3]
coordsystemmatrix = (Lar.r(0,pi/4,0)*Lar.r(0,0,pi/2))[1:3,1:3]
axisv = [0.0  1.0  0.0  0.0; 0.0  0.0  1.0  0.0; 0.0  0.0  0.0  1.0]
axismodel=(10*coordsystemmatrix[3,:].+(coordsystemmatrix'*axisv),[[1,2],[1,3],[1,4]])

aabb = Lar.boundingbox(example[1])
model = PointClouds.getmodel(aabb)


RGBtensor, rasterquote, refX, refY = PointClouds.initrasterarray(coordsystemmatrix,GSD,model)
RGBtensor = PointClouds.image(example[1], V, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, GSD)
save("otherview2.png", colorview(RGB, RGBtensor))

GL.VIEW(
	[
		#GL.GLPoints(convert(Lar.Points,V[:,4]'))
		viewRGB(example...,V)
		GL.GLGrid(model[1],model[3],GL.Point4d(1,1,1,1))
		viewRGB(axismodel...,[0 1. 0 0;0 0. 1 0;0 0. 0 1])
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)


## image potree
using PointClouds
using Images

txtpotreedirs = "C:/Users/marte/Documents/FilePotree/directory.txt"
potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
bbin=tightBB
bbin = "C:/Users/marte/Documents/FilePotree/cava.json"
bbin = (hcat([458117.67; 4.49376852e6; 196.67]), hcat([458452.44; 4.49417179e6; 237.5]))
GSD = 0.1
PO = "XY+"
outputimage = "C:\\Users\\marte\\Documents\\Vista_"*PO*"_GSD_"*"$GSD"*".png"
@time PointClouds.orthoprojectionimage(txtpotreedirs, outputimage, bbin, GSD, PO)
"295370.8436816006 4.781124438537028e6 225.44601794335938 295632.16918208887 4.781385764037516e6 486.77151843164063" #colombella
"458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" #cava

"295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781376.7190012 300.3583829030762"
julia --track-allocation=user extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt prova.png "295400.8436816006 4.781124438537028e6 225.44601794335938 295500.16918208887 4.7813767190012e6 300.3583829030762" 0.3 XY+

"295400.8436816006 4.781124438537028e6 225.44601794335938 295500.16918208887 4.7813767190012e6 300.3583829030762"

julia extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt -o prova.png --bbin "458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" --gsd 0.3 --po XY+

## models intersection
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.apply(Lar.r(0,0,0),Lar.cuboid([4,4,4],true)))
tightAABB = (hcat([0,0,0.]),hcat([1,1,1.]))
modelAABB = PointClouds.getmodel(tightAABB)
model = V,EV,FV


V = rand(3,10)

PointClouds.inmodel(model).([V[:,i] for i in 1:size(V,2)])
PointClouds.inmodel(model)([-0.5,0.5,1])
PointClouds.inmodel(model)([-30.,-30,-30])

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,[0.5,0.5,0.5]'))
		#GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
		GL.GLGrid(model[1],model[2],GL.Point4d(1,1,1,1))
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)
## tree structures for file .hrc
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using DataStructures
txtpotreedirs = "C:/Users/marte/Documents/FilePotree/directory.txt"
potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
potree = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"

potree = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\COLOMBELLA"
trie = PointClouds.triepotree(potree)



using PointClouds
using Images

txtpotreedirs = "C:/Users/marte/Documents/FilePotree/directory.txt"
potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
bbin = (hcat([458117.68; 4.49376853e6; 196.68]), hcat([458452.43; 4.49417178e6; 230.49]))
PointClouds.modelsdetection(PointClouds.getmodel(bbin), tightBB)



PointClouds.inmodel(PointClouds.getmodel(bbin))()
bbin = tightBB

bbin = AABB
model=PointClouds.getmodel(tightBB)
PointClouds.inmodel(PointClouds.getmodel(bbin)).([model[1][:,i] for i in 1:8])
modelAABB = PointClouds.getmodel(bbin)
modelBB = PointClouds.getmodel(tightBB)
GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,model[1][:,1]'))
		GL.GLGrid(modelAABB[1],modelAABB[2],GL.Point4d(1,1,1,1))
		GL.GLGrid(modelBB[1],modelBB[2],GL.Point4d(1,1,1,1))
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
)


V,(VV,EV,FV,CV) = Lar.cuboid([1,1,1],true)
PointClouds.testinternalpoint(V,EV,FV)([0.4,0.4,1])

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,[1,0.9,0.9]'))
		GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
		#GL.GLGrid(modelBB[1],modelBB[2],GL.Point4d(1,1,1,1))
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)


using LasIO
using LazIO

fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA\\data\\r\\r.las"

h,p=LasIO.FileIO.load(fname)

PointClouds.xyz(p[1], h)

typeformat(fname)
