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
bbin=(hcat([295400.8436816006; 4.781124438537028e6; 225.44601794335938]), hcat([295500.16918208887; 4.7813767190012e6; 300.3583829030762]))
bbin = tightBB

bbin = "C:/Users/marte/Documents/FilePotree/cava.json"

GSD = 0.3
PO = "XY+"
outputimage = "Vista_"*PO*"_GSD_"*"$GSD"*".png"
@time PointClouds.orthoprojectionimage(txtpotreedirs, outputimage, bbin, GSD, PO)
"295370.8436816006 4.781124438537028e6 225.44601794335938 295632.16918208887 4.781385764037516e6 486.77151843164063" #colombella
"458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" #cava

"295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781376.7190012 300.3583829030762"
julia --track-allocation=user extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt prova.png "295400.8436816006 4.781124438537028e6 225.44601794335938 295500.16918208887 4.7813767190012e6 300.3583829030762" 0.3 XY+

"295400.8436816006 4.781124438537028e6 225.44601794335938 295500.16918208887 4.7813767190012e6 300.3583829030762"


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

potree="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\COLOMBELLA"
trie = PointClouds.triepotree(potree)
readdir("src")

using DataStructures
trie = DataStructures.Trie{String}()

trie["r"]="r.las"
trie["r0"]="r0.las"
trie["r00"]="r00.las"
trie["r1"]="r1.las"
trie["r12"]="r12.las"
trie["r001"]="r001.las"
trie["r13"]="r13.las"
t0 = trie
t1 = t0.children['r']
t2 = t1.children['1']
t3 = t2.children['2']
a=collect(path(trie, "1"))

t = Trie{Int}()

t["amy"] = 56
t["ann"] = 15
t["emma"] = 30
t["rob"] = 27
t["roger"] = 52
t["kevin"] = Int8(11)
t["bodfs"] = 23

function dfs(t)
	iter = DataStructures.TrieIterator(t,"rob")
	next = iterate(iter)
	while next !== nothing
		@show next[1]
		println()
	    (i, state) = next
		@show i.value
	    # body
	    next = iterate(iter,state)
	end
	@show next
end

dfs(t)
iter = DataStructures.TrieIterator(trie, "")
next = iterate(iter)




t0 = t
t1 = t0.children['r']
t2 = t1.children['o']
t3 = t2.children['b']
collect(path(t, "b")) == [t0]
collect(path(t, "rob")) == [t0, t1, t2, t3]
collect(path(t, "robb")) == [t0, t1, t2, t3]
collect(path(t, "ro")) == [t0, t1, t2]
collect(path(t, "roa")) == [t0, t1, t2]

t1 = t0.children['b']


using DataStructures
trie = DataStructures.Trie{String}()

trie["r"]="r.las"
trie["r0"]="r0.las"
trie["r00"]="r00.las"
trie["r1"]="r1.las"
trie["r12"]="r12.las"
trie["r001"]="r001.las"
trie["r13"]="r13.las"

delete2!(t::Trie, key) = (delete!(d.children, key); d)

trimasto = delete2!(trie,"r1")



t0 = deepcopy(trie)

delete!(t0.children,'r')

r=t0.children['r']

r.children

r0=r.children['0']

seen_prefix(t::Trie, str) = any(v -> v.is_key, path(t, str))

it=path(t0,"r12")

DataStructures.iterate(it,1)

DataStructures.iterate(it)

it=collect(path(r,"r12"))

figli2=DataStructures.iterate(figli, 1)


function dfs(t)
	if !isempty(t.children)
		@show collect(keys(t.children))

		for key in collect(keys(t.children))
			@show key
			if  t.children[key].value!="r0.las"
				@show t.children[key].value
				dfs(t.children[key])
			end
		end
	end
end

dfs(trie)

allnodes=keys(trie)

while isempty(allnodes)
	node = popfirst!(allnodes)
	@show allnodes

	if node=="r0"
		t=subtrie()
