using LinearAlgebraicRepresentation #AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL

## image julia
using LinearAlgebraicRepresentation #AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using Images
using ViewerGL
GL = ViewerGL

RGBtensor=ones(3,2000,2000)

save("otherview.png", colorview(RGB, RGBtensor))

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
bbin = tightBB
bbin = "C:/Users/marte/Documents/FilePotree/cava.json"
bbin = (hcat([458117.67; 4.49376852e6; 196.67]), hcat([458452.44; 4.49417179e6; 237.5]))
GSD = 0.3
PO = "XY+"
outputimage = "prova$PO.jpg"
@time PointClouds.orthoprojectionimage(txtpotreedirs, outputimage, bbin, GSD, PO, nothing, nothing )
"295370.8436816006 4.781124438537028e6 225.44601794335938 295632.16918208887 4.781385764037516e6 486.77151843164063" #colombella
"458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" #cava

"295370.8436816006 4781124.438537028 225.44601794335939 295632.16918208889 4781376.7190012 300.3583829030762"
julia --track-allocation=user extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt prova.png "295400.8436816006 4.781124438537028e6 225.44601794335938 295500.16918208887 4.7813767190012e6 300.3583829030762" 0.3 XY+

"295400.8436816006 4.781124438537028e6 225.44601794335938 295500.16918208887 4.7813767190012e6 300.3583829030762"

julia extractpointcloud.jl C:/Users/marte/Documents/FilePotree/directory.txt -o C:/Users/marte/Documents/FilePotree/prova.png --bbin "458117.68 4.49376853e6 196.68 458452.43 4.49417178e6 237.49" --gsd 0.3 --po XY+ --quote 211 --thickness 2


## tree structures for file .hrc
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using DataStructures

txtpotreedirs = "C:/Users/marte/Documents/FilePotree/directory.txt"
potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
file = "C:\\Users\\marte\\Documents\\FilePotree\\json.json"
bbin = tightBB
GSD = 0.3
PO = "XY+"
outputimage = "prova$PO.jpg"
@time PointClouds.orthoprojectionimage(txtpotreedirs, outputimage, bbin, GSD, PO, 211.100, 2.0, true)



## allinea piano medio con piano  OK
## aggiornare il json volume
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.05),Lar.apply(Lar.r(pi/4,0,0)*Lar.r(0,pi/3,0),Lar.cuboid([1,1,0.1],true)))

p3 = rand(3,7)

params1 = PointClouds.planefit(p3)
axisref,centroidref = params1
params2 = PointClouds.planefit(V)
axissource,centroidsource = params2

Vplane,FVplane = PointClouds.larmodelplane(V,params2)
Vplaneref,FVplaneref = PointClouds.larmodelplane(p3,params1)

rot = PointClouds.rotoTraslation(params2,params1)
alignebox = Lar.apply(rot,(V,EV))

GL.VIEW(
	[
		GL.GLGrid(alignebox...,GL.Point4d(1,1,1,1))
		GL.GLGrid(Vplane,FVplane,GL.Point4d(1,1,1,1))
		GL.GLGrid(Vplaneref,FVplaneref,GL.Point4d(1,1,1,1))

		GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)


#prova reale

pianovolume = "C:/Users/marte/Documents/FilePotree/piano-volume.json"

p3 = [	291260.822 291266.726 291266.038;
		4630323.935 4630326.879 4630326.534;
		105.593 105.251 106.865]

V,EV,FV = PointClouds.getmodel(pianovolume)


params1 = PointClouds.planefit(p3)
axisref,centroidref = params1
params2 = PointClouds.planefit(V)
axissource,centroidsource = params2

Vplane,FVplane = PointClouds.larmodelplane(V,params2)
Vplaneref,FVplaneref = PointClouds.larmodelplane(p3,params1)

rot = PointClouds.rotoTraslation(params2,params1)
alignebox = Lar.apply(Lar.t(-centroidsource...),Lar.apply(rot,(V,FV)))
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
level = 1
allfile = PointClouds.filelevel(fname,level,false)
_,_,_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
spacing = spacing/2^level

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Voriginal)

GL.VIEW(
	[
		GL.GLGrid(Lar.apply(Lar.t(-centroidsource...),(Voriginal,VV))...,GL.Point4d(1,1,1,1))
		GL.GLGrid(alignebox...,GL.Point4d(1,1,1,1))
		#GL.GLGrid(Vplane,FVplane,GL.Point4d(1,1,1,1))
		#GL.GLGrid(Vplaneref,FVplaneref,GL.Point4d(1,1,1,1))

		GL.GLGrid(Lar.apply(Lar.t(-centroidsource...),(V,FV))...,GL.Point4d(1,1,1,1))
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)


## descrizione poligono estruso
using JSON
file = "C:/Users/marte/Documents/FilePotree/poligon.json"

pos = [458248.400, 4494143.514, 328.906]
tar = [458289.258, 4493982.125, 220.795]
camera = (pos,tar)

function viewcoordinatesystem(camera)
    position,target = camera
	up = [0,0,1.]
	dir = target-position
	x = dir/Lar.norm(dir)
	if x != [0,0,1] && x != [0,0,-1]
		y = Lar.cross(x,up)
		z = Lar.cross(y,x)
	end
    return [y';z';-x']
end

using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
viewcoordinatesystem(camera)


function coordsystemcamera(file::String)
    mat = PointClouds.cameramatrix(file)
    return convert{Array{Float64,2},mat[1:3,1:3]'}
end

function vertspolygonfromareaJSON(file::String)
	dict=Dict{String,Any}[]
	open(file, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	features = dict["features"]
	for feature in features
		type = feature["geometry"]["type"]
		if type == "Polygon"
			points = feature["geometry"]["coordinates"]
			V = hcat(points[1][1:end-1]...)
			return V
		end
	end
end
V = vertspolygonfromareaJSON(file)
axis,centroid = PointClouds.planefit(V)

function polygon(file::String)
	verts = vertspolygonfromareaJSON(file)
	EV = [[i,i+1] for i in 1:size(verts,2)-1]
	push!(EV,[size(verts,2),1])
	axis,centroid = PointClouds.planefit(verts)
	if Lar.dot(axis,Lar.cross(verts[:,1]-centroid[:,1],verts[:,2]-centroid[:,1]))<0
		axis = -axis
	end
	PointClouds.projectpointson(verts,(axis,centroid),"plane")
	return verts,EV
end



include("viewfunction.jl")
V,EV=polygon(file)
GL.VIEW(
	[
		viewnormals(centroid,axis)
		GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
	]
)



## save file
using LasIO

fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\SCALE\\data\\r\\r.las"
header,pointdata = LasIO.FileIO.load(fname)
LasIO.FileIO.save("prova.las",header,pointdata[1:9135])
s="prova.las"

header_n = header.records_count
n = length(pointdata)
msg = "number of records in header ($header_n) does not match data length ($n)"
@assert header_n == n msg

# write header
write(s, LasIO.magic(LasIO.format"LAS"))
write(s, header)

    # write points
for p in pointdata
    write(s, p)
end

h1,p1 = LasIO.FileIO.load(s)
outputlas = splitext(outputimage)[1]*".las"
