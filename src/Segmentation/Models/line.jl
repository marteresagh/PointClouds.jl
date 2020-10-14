mutable struct Line
	direction::Array{Float64,1}
	centroid::Array{Float64,1}
end

struct LineDataset
    points::PointCloud
    line::Line
end
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
    return direction,centroid
end

"""
Orthogonal distance.
"""
function distpointtoline(p::Array{Float64,1},line::Line)
	v = p - line.centroid
	p_star = v - Lar.dot(line.direction,v)*line.direction
	return Lar.norm(p_star)
end
"""
Check if point is close enough to model.
"""
function isclosetoline(p::Array{Float64,1},line::Line,par::Float64)
	return PointClouds.distpointtoline(p,line) < par
end

"""
Find seed point randomly.
"""
function seedpointforlinefitting(V::Lar.Points,threshold::Float64)
	"""
	Return index of point in V with minor residual.
	"""
	function minresidualline(V::Lar.Points,line::Line)
		return findmin([PointClouds.distpointtoline(V[:,i],line) for i in 1:size(V,2)])[2]
	end
	kdtree = KDTree(V)
	randindex = rand(1:size(V,2))

	idxs, dists = knn(kdtree, V[:,randindex], 10, false)
	filter = [dist<=threshold for dist in dists]
	idxseeds = idxs[filter]

	seeds = V[:,idxseeds]

	direction,centroid = PointClouds.linefit(seeds)
	line = Line(direction,centroid)
	minresidual = minresidualline(seeds,line)
	seed = idxseeds[minresidual]

	return seed,direction,centroid
end

function LineDetectionFromRandomInitPoint(PC::PointCloud, par::Float64,threshold::Float64)

	# Init
	listPoint = Array{Float64,2}[]

	# firt sample
	index, direction, centroid = PointClouds.seedpointforlinefitting(PC.points,threshold)
	R = [index]
	lineDetected = Line(direction,centroid)


	# PointClouds.flushprintln("========================================================")
	# PointClouds.flushprintln("= Detection of Plane starting from Random Point $index =")
	# PointClouds.flushprintln("========================================================")

	pcOnLine = searchPointsOnLine(PC, R, lineDetected, par, threshold)

	return LineDataset(pcOnLine, lineDetected)
end


function searchPointsOnLine(PC::PointCloud, R, lineDetected::Line, par::Float64, threshold::Float64)
	kdtree = KDTree(PC.points)
	seeds = copy(R)
	visitedverts = copy(R)
	listPoint = nothing
	while !isempty(seeds)
		tmp = Int[]
		N = PointClouds.neigbhborsOf(seeds,kdtree,PC,visitedverts,threshold)
		#filter = [dist<=threshold for dist in dists]
		#N = idxs[filter]
		for i in N
			p = PC.points[:,i]
			if PointClouds.isclosetoline(p,lineDetected,par)
				push!(tmp,i)
				push!(R,i)
				#@show length(R)
			end
			push!(visitedverts,i)
		end
		listPoint = PC.points[:,R]
		direction, centroid = PointClouds.linefit(listPoint)
		lineDetected.direction = direction
		lineDetected.centroid = centroid
		seeds = tmp
		#setdiff!(seeds,seed)
	end
	listRGB = PC.rgbs[:,R]
	return PointCloud(length(R), listPoint, listRGB)
end


function LinesDetectionRandom(PC::PointCloud, par::Float64, threshold::Float64, failed::Int64, N::Int64)

	# 1. - initialization
	PCcurrent = deepcopy(PC)
	LINES = LineDataset[]
	linedetected = nothing

	f = 0
	i = 0

	# find lines
	PointClouds.flushprintln("======= Start search =======")
	search = true
	while search
		found = false

		while !found && f < failed
			try
				#PointClouds.flushprintln("ECCOMI")
				linedetected = PointClouds.LineDetectionFromRandomInitPoint(PCcurrent,par,threshold)

				# VALIDITY
				pointsonline = linedetected.points
				#@show linedetected
				@assert  pointsonline.n > N "not valid"  #da automatizzare
				# line = linedetected.line
				# E,_ = PointClouds.DrawLine(pointsonline.points, line, 0.0)
				# dist = Lar.norm(E[:,1]-E[:,2])
				# rho = pointsonline.n/dist
				# PointClouds.flushprintln("rho = $rho")
				# @assert  rho > N "not valid"  #da automatizzare

				found = true

			catch y

				f = f+1
				PointClouds.flushprintln("failed = $f")
				# if !isa(y, AssertionError)
				# 	notfound = false
				# end
			end
		end

		if found
			f = 0
			i = i+1
			PointClouds.flushprintln("$i lines found")
			push!(LINES,linedetected)
			deletePoints!(PCcurrent,linedetected.points)
		else
			search = false
		end

	end

	return LINES
end

"""
Lar model of fitting segment line.
"""
function DrawLine(pointsonline::Lar.Points, line::Line, u=0.02)

	max_value = -Inf
	min_value = +Inf

	for i in 1:size(pointsonline,2)
		p = pointsonline[:,i] - line.centroid
		value = Lar.dot(line.direction,p)

		if value > max_value
			max_value = value
		end
		if value < min_value
			min_value = value
		end
	end

	p_min = line.centroid + (min_value - u)*line.direction
	p_max = line.centroid + (max_value + u)*line.direction
	V = hcat(p_min,p_max)
	EV = [[1,2]]
    return V, EV
end


"""
Extract boundary of flat shape.
"""
function DrawLines(lines::Array{LineDataset,1}, u=0.2)
	out = Array{Lar.Struct,1}()
	for obj in lines
		V,EV = PointClouds.DrawLine(obj.points.points, obj.line, u)
		cell = (V,EV)
		push!(out, Lar.Struct([cell]))
	end
	out = Lar.Struct( out )
	V,EV = Lar.struct2lar(out)
	return V,EV
end

function neigbhborsOf(seeds,kdtree,PC,visitedverts,threshold) #TODO da copiare nel file buono
	idxs, dists = knn(kdtree, PC.points[:,seeds], 10, false, i -> i in visitedverts)
	N = Int[]
	for i in 1:length(idxs)
		filter = [dist<=threshold for dist in dists[i]]
		union!(N,idxs[i][filter])
	end
	return N
end
