"""
	readcloudJSON(path::String)

Read a file `.json`.
"""
function readcloudJSON(path::String)
	dict=Dict{String,Any}[]
	open(path * "\\cloud.js", "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	dictAABB = dict["boundingBox"]
	dicttightBB = dict["tightBoundingBox"]
	AABB = (hcat([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]]),
			hcat([dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]]))
	tightBB = (hcat([dicttightBB["lx"],dicttightBB["ly"],dicttightBB["lz"]]),
				hcat([dicttightBB["ux"],dicttightBB["uy"],dicttightBB["uz"]]))

	scale = dict["scale"]
	npoints = dict["points"]
    typeofpoints = dict["pointAttributes"]
	octreeDir = dict["octreeDir"]
	hierarchyStepSize = dict["hierarchyStepSize"]
	spacing = dict["spacing"]
	return typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing
end


"""
	volumeJSON(path::String)

Read a file `.json` of volume model.


# Example of a volume file json structure.

```
{
   "clip":true,
   "name":"name",
   "scale":{
      "x":1.,
      "y":1.,
      "z":1.
   },
   "position":{
   	  "x":0.,
	  "y":0.,
	  "z":0.
   },
   "rotation":{
      "x":0.,
      "y":0.,
      "z":0.
   },
   "permitExtraction":true
}
```
"""
function volumeJSON(path::String)
	dict = Dict{String,Any}[]

	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end

	return dict["position"],dict["scale"],dict["rotation"]
end


"""
	volumemodelfromjson(path::String)

Return LAR model of Potree volume tools.
"""
function volumemodelfromjson(path::String)
	@assert isfile(path) "volumemodelfromjson: $path not an existing file"

	position, scale, rotation = PointClouds.volumeJSON(path)
	V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.cuboid([1,1,1],true))
	mybox = (V,CV,FV,EV)
	scalematrix = Lar.s(scale["x"],scale["y"],scale["z"])
	rx = Lar.r(2*pi+rotation["x"],0,0); ry = Lar.r(0,2*pi+rotation["y"],0); rz = Lar.r(0,0,2*pi+rotation["z"])
	rot = rx * ry * rz
	trasl = Lar.t(position["x"],position["y"],position["z"])
	model = Lar.Struct([trasl,rot,scalematrix,mybox])
	return Lar.struct2lar(model) #V,CV,FV,EV
end


"""
Save file .JSON of the boundingbox in path.
"""
function savebbJSON(path::String, aabb::Tuple{Array{Float64,2},Array{Float64,2}})
	@assert isdir(path) "savebbJSON: $path not a valid directory"
	min,max = (aabb[1],aabb[2])
	name = splitdir(path)[2]*".json"
	scale = DataStructures.OrderedDict{String,Any}("x"=>max[1]-min[1], "y"=>max[2]-min[2], "z"=>max[3]-min[3])
	position = DataStructures.OrderedDict{String,Any}("x"=>(max[1]+min[1])/2, "y"=>(max[2]+min[2])/2, "z"=>(max[3]+min[3])/2)
	rotation = DataStructures.OrderedDict{String,Any}("x"=>0., "y"=>0., "z"=>0.)
	data = DataStructures.OrderedDict{String,Any}("clip"=>true, "name"=>name,
			"scale"=>scale,"position"=>position,"rotation"=>rotation,
			"permitExtraction"=>true)
	open(joinpath(path,name),"w") do f
  		JSON.print(f, data,4)
	end
end


"""
camera parameters from JSON.
"""
function cameraparameters(path::String)
	dict=Dict{String,Any}[]
	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	position = dict["position"]
	target = dict["target"]
	return position, target
end


"""
camera parameters from JSON.
"""
function cameramatrix(path::String)
	dict = Dict{String,Any}[]
	open(path, "r") do f
	    dict = JSON.parse(f)  # parse and transform data
	end
	mat = dict["object"]["matrix"]
	return [mat[1] mat[5] mat[9] mat[13];
			mat[2] mat[6] mat[10] mat[14];
			mat[3] mat[7] mat[11] mat[15];
			mat[4] mat[8] mat[12] mat[16]]
end

"""
extract verteces from area tools.
"""
function vertspolygonfromareaJSON(file::String)
	dict = Dict{String,Any}[]
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


"""
create polygon model.
"""
function polygon(file::String)
	verts = vertspolygonfromareaJSON(file)
	EV = [[i,i+1] for i in 1:size(verts,2)-1]
	push!(EV,[size(verts,2),1])
	axis,centroid = PointClouds.planefit(verts)
	if Lar.dot(axis,Lar.cross(verts[:,1]-centroid,verts[:,2]-centroid))<0
		axis = -axis
	end
	PointClouds.projectpointson(verts,(axis,centroid),"plane")
	return verts,EV
end
