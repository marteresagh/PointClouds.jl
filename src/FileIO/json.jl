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
