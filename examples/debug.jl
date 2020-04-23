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

bbin = AABB

bbin = tightBB

bbin = "C:/Users/marte/Documents/FilePotree/cava.json"

GSD = 0.3
PO = "XY-"
outputimage = "Vista_"*PO*"_GSD_"*"$GSD"*".png"
@time PointClouds.orthoprojectionimage(txtpotreedirs, outputimage, bbin, GSD, PO)
"295370.8436816006 4.781124438537028e6 225.44601794335938 295632.16918208887 4.781385764037516e6 486.77151843164063" #colombella
"458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" #cava

"295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781376.7190012 300.3583829030762"
julia extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt prova.png C:/Users/marte/Documents/FilePotree/cava.json 0.3 XY+



## models intersection
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
# V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.apply(Lar.r(0,0,0),Lar.cuboid([4,4,4],true)))
# tightAABB = (hcat([0,0,0.]),hcat([1,1,1.]))
# modelAABB = PointClouds.getmodel(tightAABB)
# model = V,EV,FV
# GL.VIEW(
# 	[
# 		#GL.GLPoints(convert(Lar.Points,V[:,4]'))
# 		GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
# 		GL.GLGrid(modelAABB[1],modelAABB[2],GL.Point4d(1,1,1,1))
# 		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
#
# 	]
# )


## tree structures for file .hrc
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds

txtpotreedirs = "C:/Users/marte/Documents/FilePotree/directory.txt"
potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
potree = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
filehrc = PointClouds.searchfile(potree,".hrc")


raw = read(filehrc[1])

data = bitstring.(UInt8.(raw))

bitstring.(UInt8.(raw))
convert(Float64,raw[2:5])
convert(,10011110000101000000000000000000)

join(data[5:2])

parse(Int64,10011110000101000000000000000000,2)

Int(10011110000101000000000000000000)

"10011110"
 "00010100"
 "00000000"
 "00000000"


00000000000000000001010010011110

function readhrc(potree::String)

	typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters togli quelli che non usi
	tree = joinpath(potree,octreeDir,"r") # path to directory "r"
	hrcs = PointClouds.searchfile(tree,".hrc")

	for hrc in hrcs
		raw = read(hrc)
		treehrc = reshape(raw, (5, div(length(raw), 5)))

		for i in 1:size(treehrc,2)
			children = bitstring(UInt8(treehrc[1,i]))
			npoints = parse(Int, bitstring(UInt8(treehrc[5,i]))*bitstring(UInt8(treehrc[4,i]))*bitstring(UInt8(treehrc[3,i]))*bitstring(UInt8(treehrc[2,i])); base=2)
			#struct da finire
		end
	end

	return treehrc
end


treehrc=readhrc(potree)



t=Trie{String}()

t["r"]="r.las"
t["r1"]="r1.las"
t["r2"]="r2.las"
t["r12"]="r12.las"
t["r20"]="r20.las"


function triepotree(potree)
	typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters
	tree = potree*"\\"*octreeDir*"\\r" # path to directory "r"

	trie=Trie{String}()

	println("search in $tree ")

	# 2.- check all file
	files = PointClouds.searchfile(tree,".las")
	for file in files
		name = rsplit(splitdir(file)[2],".")[1]
		trie[name]=file
	end

	return trie
end
potree="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\COLOMBELLA"
trie = triepotree(potree)
