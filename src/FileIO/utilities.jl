"""
Read file line by line.
"""
function getdirectories(filepath::String)
	return readlines(filepath)
end

"""
	boxmodelfromjson(volume::String)

Read volume model from a file JSON.
"""
function boxmodelfromjson(volume::String)
	V,CV,FV,EV = PointClouds.volumemodelfromjson(volume)
	return V,EV,FV
end

"""
	boxmodelfromaabb(aabb::Tuple{Array{Float64,2},Array{Float64,2}})

Return LAR model of the aligned axis box defined by `aabb`.
"""
function boxmodelfromaabb(aabb::Tuple{Array{Float64,2},Array{Float64,2}})
	min,max = aabb
	V = [	min[1]  min[1]  min[1]  min[1]  max[1]  max[1]  max[1]  max[1];
		 	min[2]  min[2]  max[2]  max[2]  min[2]  min[2]  max[2]  max[2];
		 	min[3]  max[3]  min[3]  max[3]  min[3]  max[3]  min[3]  max[3] ]
	EV = [[1, 2],  [3, 4], [5, 6],  [7, 8],  [1, 3],  [2, 4],  [5, 7],  [6, 8],  [1, 5],  [2, 6],  [3, 7],  [4, 8]]
	FV = [[1, 2, 3, 4],  [5, 6, 7, 8],  [1, 2, 5, 6],  [3, 4, 7, 8],  [1, 3, 5, 7],  [2, 4, 6, 8]]
	return V,EV,FV
end

"""
	getmodel()

Return LAR model (V,EV,FV) of a box, aligned or not to axes.
"""
function getmodel(bbin::String)
	return PointClouds.boxmodelfromjson(bbin)
end

function getmodel(bbin::Tuple{Array{Float64,2},Array{Float64,2}})
	return PointClouds.boxmodelfromaabb(bbin)
end
