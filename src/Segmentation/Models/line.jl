
# function linefit(points::Lar.Points)
#
# 	npoints = size(points,2)
# 	@assert npoints>=2 "linefit: at least 2 points needed"
# 	centroid = PointClouds.centroid(points)
#
# 	xxSum = 0
# 	xhSum = 0
#
# 	for i in 1:npoints
# 		diff = points[:,i] - centroid
# 		xxSum += diff[1]^2
# 		xhSum += diff[1]*diff[2]
# 	end
#
# 	if xxSum > 0
# 		barX = centroid[1]
# 		barH = centroid[2]
# 		barA = xhSum / xxSum
# 	else
# 		barX = 0
# 		barH = 0
# 		barA = 0
# 	end
#
#     return barA, centroid[2]-barA*centroid[1]
# end

"""
Returns best line fitting `points`.
Line description:
- centroid
- direction
"""
function linefit(points::Lar.Points)

	npoints = size(points,2)
	@assert npoints>=2 "linefit: at least 2 points needed"
	centroid = PointClouds.centroid(points)

	C = zeros(2,2)
	for i in 1:npoints
		diff = points[:,i] - centroid
		C += diff*diff'
	end


	#Lar.eigvals(C)
	eigvectors = Lar.eigvecs(C)
	direction = eigvectors[:,2]
    return centroid, direction
end

"""

"""
function larmodelsegment(pointsonline::Lar.Points, params)
	centroid,direction = params
	max_value = -Inf
	min_value = +Inf
	
	for i in 1:size(pointsonline,2)
		p = pointsonline[:,i] - centroid
		value = Lar.dot(direction,p)

		if value > max_value
			max_value = value
		end
		if value < min_value
			min_value = value
		end
	end

	p_min = centroid + min_value*direction
	p_max = centroid + max_value*direction
	V = hcat(p_min,p_max)
	EV = [[1,2]]
    return V, EV
end


"""
Detect points on shape.
"""
function linedetection(V::Lar.Points,EV::Lar.Cells,par::Float64;VALID=5::Int64)

	# adjacency list
   	adj = Lar.verts2verts(EV)
	R = Int64[]
	pointsonline = Array{Float64,2}[]

	# firt sample
	index,params = PointClouds.seedpointforlinefitting(V,adj)

	push!(R,index)

	seeds = [index]
	visitedverts = copy(seeds)
	while !isempty(seeds)
		for seed in seeds
			N = PointClouds.findnearestof([seed],visitedverts,adj)
			for i in N
	            p = V[:,i]
				if PointClouds.isclosetoline(p,params,par)
					push!(seeds,i)
					push!(R,i)
				end
	            push!(visitedverts,i)
	        end
			setdiff!(seeds,seed)
		end
		pointsonline = V[:,R]
		params = PointClouds.linefit(pointsonline)
	end

	@assert size(pointsonline,2) >= VALID "shapedetection: uninteresting model"

    return  pointsonline,params
end


"""
Orthogonal distance.
"""
function distpointtoline(p::Array{Float64,1},params)
	centroid, direction = params
	v = p - centroid
	p_star = v - Lar.dot(direction,v)*direction
	return Lar.norm(p_star)
end
"""
Check if point is close enough to model.
"""
function isclosetoline(p::Array{Float64,1},params,par::Float64)
	return PointClouds.distpointtoline(p,params) < par
end

"""
Find seed point randomly.
"""
function seedpointforlinefitting(V::Lar.Points,adj::Array{Array{Int64,1},1})

	"""
	Return index of point in V with minor residual.
	"""
	function minresidualline(V::Lar.Points,params)
		return findmin([PointClouds.distpointtoline(V[:,i],params) for i in 1:size(V,2)])[2]
	end

	randindex = rand(1:size(V,2))

	idxneighbors = PointClouds.findnearestof([randindex],[randindex],adj)
	idxseeds = union(randindex,idxneighbors)
	seeds = V[:,idxseeds]

	params = PointClouds.linefit(seeds)
	minresidual = minresidualline(seeds,params)
	seed = idxseeds[minresidual]

	return seed,params
end


"""
Iterative shape detection.
"""
function linessegmentation(V::Lar.Points,EV::Lar.Cells, N::Int, par::Float64;VALID=10::Int64)

	# 1. - initialization
	Vcurrent = copy(V)
	EVcurrent = copy(EV)
	lines = []

	i = 0

	# find N lines
	while i < N
		global pointsonline,params
		notfound = true
		while notfound
			try
				pointsonline,params = PointClouds.linedetection(Vcurrent,EVcurrent,par;VALID=VALID)
				notfound = false
			catch y
				if !isa(y, AssertionError)
					notfound = false
				end
			end
		end

		i = i+1
		println("$i lines found")
		push!(lines,[pointsonline,params])

		# delete points of region found from current model
		Vcurrent,EVcurrent = PointClouds.deletepointstomodel(Vcurrent,EVcurrent,pointsonline)
	end

	return lines
end


"""
Return LAR remained model after removing points.
"""
function deletepointstomodel(V::Lar.Points,EV::Lar.Cells,pointstodel::Lar.Points)
	npoints = size(V,2)
	cscEV = Lar.characteristicMatrix(EV)
	todel = [PointClouds.matchcolumn(pointstodel[:,i],V) for i in 1:size(pointstodel,2)] # index of points to delete
	tokeep = setdiff(collect(1:cscEV.n), todel)
    cscEV0 = cscEV[:,tokeep]

	edgeind = 1:cscEV0.m
	vertinds = 1:cscEV.n
    keepedges = Array{Int64, 1}()
	for i in edgeind
    	if length(cscEV0[i, :].nzind) == 2
           push!(keepedges, i)
       end
    end
   	cscEV = cscEV[keepedges,:]
	isolatedpoints = Array{Int64, 1}()
	for i in vertinds
    	if length(cscEV[:, i].nzind) == 0
           push!(isolatedpoints, i)
       end
    end

   	union!(todel,isolatedpoints)
	tokeep = setdiff(vertinds, todel)

    Vremained = V[:, tokeep]
	EVremained = Lar.cop2lar(cscEV[:, tokeep])

	return Vremained,EVremained
end


"""
Extract boundary of flat shape.
"""
function drawlines(lines)
	out = Array{Lar.Struct,1}()
	for line in lines
		pointsonline, params = line
		V,EV = PointClouds.larmodelsegment(pointsonline, params)
		cell = (V,EV)
		push!(out, Lar.Struct([cell]))
	end
	out = Lar.Struct( out )
	V,EV = Lar.struct2lar(out)
	return V,EV
end
