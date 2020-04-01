"""
	readJSON(path::String)

Read a file `.json`.
"""
function readJSON(path::String)
	dict=Dict{String,Any}[]
	open(path * "\\cloud.js", "r") do f
	    dict=JSON.parse(f)  # parse and transform data
	end
	dictAABB = dict["boundingBox"]
	scale = dict["scale"]
	npoints = dict["points"]
	AABB=([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]],
			[dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]])
	octreeDir = dict["octreeDir"]
	hierarchyStepSize = dict["hierarchyStepSize"]
	spacing = dict["spacing"]
	return scale,npoints,AABB,octreeDir,hierarchyStepSize,spacing
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
	volumemodel(path::String)

Return LAR model of Potree volume tools.
"""
function volumemodel(path::String)
	position, scale, rotation = PointClouds.volumeJSON(path)
	V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.cuboid([1,1,1],true))
	mybox = (V,CV,FV,EV)
	scalematrix = Lar.s(scale["x"],scale["y"],scale["z"])
	rx = Lar.r(rotation["x"],0,0); ry = Lar.r(0,rotation["y"],0); rz = Lar.r(0,0,rotation["z"])
	rot = rx * ry * rz
	trasl = Lar.t(position["x"],position["y"],position["z"])
	model = Lar.Struct([trasl,rot,scalematrix,mybox])
	return Lar.struct2lar(model) #V,CV,FV,EV
end