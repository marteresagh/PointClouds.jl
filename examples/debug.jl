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
PO = "XZ+"
outputimage = "Vista_"*PO*"_GSD_"*"$GSD"*".png"
@time PointClouds.orthoprojectionimage(txtpotreedirs, outputimage, bbin, GSD, PO)
"295370.8436816006 4.781124438537028e6 225.44601794335938 295632.16918208887 4.781385764037516e6 486.77151843164063" #colombella
"458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" #cava

"295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781376.7190012 300.3583829030762"
julia extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt prova.png "295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781376.7190012 300.3583829030762" 0.3 XY+




using LinearAlgebraicRepresentation #AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.apply(Lar.r(0,0,0),Lar.cuboid([4,4,4],true)))
tightAABB = (hcat([0,0,0.]),hcat([1,1,1.]))
modelAABB = PointClouds.getmodel(tightAABB)
model = V,EV,FV
GL.VIEW(
	[
		#GL.GLPoints(convert(Lar.Points,V[:,4]'))
		GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
		GL.GLGrid(modelAABB[1],modelAABB[2],GL.Point4d(1,1,1,1))
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)

modelsdetection(model,tightAABB)
#parallelepipedo
function modelsdetection(model,octree)
	verts,edges,faces = model
	aabbmodel = Lar.boundingbox(verts)
	if PointClouds.AABBdetection(aabbmodel,octree)
		#ci sono 3 casi se i due bounding box si incontrano:
		# 1. octree è tutto interno  return 2
		# 1. octree esterno return 0
		# 1. octree intersecato ma non contenuto return 1
		Voctree,EVoctree,FVoctree = PointClouds.getmodel(octree)
		inter = PointClouds.testinternalpoint(verts,edges,faces).([Voctree[:,i] for i in 1:size(Voctree,2)])
		test = length.(inter).%2
		if test == ones(size(Voctree,2)) || test == [1, 0, 1, 0, 1, 0, 1, 0] #quest ultimo se si sovrappongono
			return 2 # full model
		elseif !separatingaxis(model, tightAABB)
			return 0
		else
			return 1
		end
	else
		return 0 # no intersection
	end
end


function separatingaxis(model,tightAABB)
	V,EV,FV = PointClouds.getmodel(tightAABB)
	verts,edges,faces = model
	axis_x = (verts[:,5]-verts[:,1])/Lar.norm(verts[:,5]-verts[:,1])
	axis_y = (verts[:,2]-verts[:,1])/Lar.norm(verts[:,2]-verts[:,1])
	axis_z = (verts[:,3]-verts[:,1])/Lar.norm(verts[:,3]-verts[:,1])
	coordsystem = [axis_x';axis_y';axis_z']
	newverts = coordsystem*verts
	newV = coordsystem*V
	newaabb = [extrema(newverts[i,:]) for i in 1:3]
	newAABB = [extrema(newV[i,:]) for i in 1:3]
	aabb = (hcat([newaabb[1][1],newaabb[2][1],newaabb[3][1]]),hcat([newaabb[1][2],newaabb[2][2],newaabb[3][2]]))
	AABB = (hcat([newAABB[1][1],newAABB[2][1],newAABB[3][1]]),hcat([newAABB[1][2],newAABB[2][2],newAABB[3][2]]))
	return PointClouds.AABBdetection(aabb,AABB)
end
