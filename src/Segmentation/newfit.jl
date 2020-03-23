"""
Detect points on shape.
"""
function shapedetection(V::Lar.Points,FV::Lar.Cells,par::Float64,shape::String;VALID=10::Int64)

	# adjacency list
	EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.FV2EV,FV)))))
   	adj = Lar.verts2verts(EV)
	R = Int64[]
	pointsonshape=Array{Float64,2}[]

	# firt sample
	index,params = PointClouds.seedpoint(V,adj,shape)

	push!(R,index)

	println("============================================")
	println(" Detection of $shape starting from $index ")
	println("============================================")

	seeds = [index]
	visitedverts = copy(seeds)
	while !isempty(seeds)
		for seed in seeds
			N = PointClouds.findnearestof([seed],visitedverts,adj)
			for i in N
	            p = V[:,i]
				if PointClouds.isclosetomodel(p,params,par,shape)
					push!(seeds,i)
					push!(R,i)
				end
	            push!(visitedverts,i)
	        end
			setdiff!(seeds,seed)
		end
		pointsonshape = V[:,R]
		params = PointClouds.surfacefitparams(pointsonshape,shape)
	end

	@assert size(pointsonshape,2) >= VALID "shapedetection: uninteresting model"

    return  pointsonshape,params
end

"""
Check if point is close enough to model.
"""
function isclosetomodel(p::Array{Float64,1},params,par::Float64,shape::String)
	if shape == "plane"
		return PointClouds.isinplane(p,params,par)
	elseif shape == "cylinder"
		return PointClouds.isincyl(p,params,par)
	elseif shape == "sphere"
		return PointClouds.isinsphere(p,params,par)
	elseif shape == "cone"
		return PointClouds.isincone(p,params,par)
	elseif shape == "torus"
		return PointClouds.isintorus(p,params,par)
	end
end

"""
Return parameters of fitted model.
"""
function surfacefitparams(V::Lar.Points,shape::String)
	if shape == "plane"
		params = PointClouds.planefit(V)
	elseif shape == "cylinder"
		params = PointClouds.cylinderfit(V)
	elseif shape == "sphere"
		params = PointClouds.spherefit(V)
	elseif shape == "cone"
		params = PointClouds.conefit(V)
	end
	return params
end

"""
Find seed point randomly.
"""
function seedpoint(V::Lar.Points,adj::Array{Array{Int64,1},1},shape::String)

	"""
	Return index of point in V with minor residual.
	"""
	function minresidual(V::Lar.Points,params,shape::String)
		if shape == "plane"
			return findmin([PointClouds.resplane(V[:,i],params) for i in 1:size(V,2)])[2]
		elseif shape == "cylinder"
			return findmin([PointClouds.rescyl(V[:,i],params) for i in 1:size(V,2)])[2]
		elseif shape == "sphere"
			return findmin([PointClouds.ressphere(V[:,i],params) for i in 1:size(V,2)])[2]
		elseif shape == "cone"
			return findmin([PointClouds.rescone(V[:,i],params) for i in 1:size(V,2)])[2]
		elseif shape == "torus"
			return findmin([PointClouds.restorus(V[:,i],params) for i in 1:size(V,2)])[2]
		end
	end


	randindex = rand(1:size(V,2))

	idxneighbors = PointClouds.findnearestof([randindex],[randindex],adj)
	idxseeds = union(randindex,idxneighbors)
	seeds = V[:,idxseeds]

	params = PointClouds.surfacefitparams(seeds,shape)
	minresidual = minresidual(seeds,params,shape)
	seed = idxseeds[minresidual]

	return seed,params
end


"""
Return indices neighbors list of `indverts`, removing verteces already visited.
"""
function findnearestof(indverts::Array{Int64,1},visitedverts::Array{Int64,1},adj::Array{Array{Int64,1},1})
	return setdiff(union(adj[indverts]...),visitedverts)
end

"""
Iterative shape detection.
"""
function segmentation(V::Lar.Points,FV::Lar.Cells, N::Int, par::Float64,
    shape="rand"::String,VALID=10::Int64)

	# 1. - initialization
	Vcurrent = copy(V)
	FVcurrent = copy(FV)
	regions = []
    shapecurrent=shape

	i = 0

	# find N shapes
	while i < N

		notfound = true
		while notfound
			if shape == "rand"
 	        	shapecurrent = PointClouds.randomshape(["plane","sphere","cylinder","cone"])
 	       	end
			try
				pointsonshape,params = PointClouds.shapedetection(Vcurrent,FVcurrent,par,
				   shapecurrent;VALID=VALID)
				notfound = false
			catch y
				if !isa(y, AssertionError)
					notfound = false
				end
			end
		end


		i = i+1
		println("$i shapes found")
		push!(regions,[pointsonshape,params])

		# delete points of region found from current model
		Vcurrent,FVcurrent = PointClouds.deletepoints(Vcurrent,FVcurrent,pointsonshape)

	end

	return regions
end

"""
Return a random string in an array of strings.
"""
function randomshape(s::Array{String,1})::String
	return rand(s)
end
