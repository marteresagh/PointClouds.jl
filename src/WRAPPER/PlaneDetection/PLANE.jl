function PlaneFromPoints(points::Lar.Points)

	npoints = size(points,2)
	@assert npoints>=3 "PlaneFromPoints: at least 3 points needed"
	centroid,V = PointClouds.subtractaverage(points)

	# Matrix
	xx = 0.; xy = 0.; xz = 0.;
	yy = 0.; yz = 0.; zz = 0.;

	for i in 1:npoints
		r = V[:,i]
		xx+=r[1]^2
		xy+=r[1]*r[2]
		xz+=r[1]*r[3]
		yy+=r[2]^2
		yz+=r[2]*r[3]
		zz+=r[3]^2
	end

	Dx = yy*zz-yz^2
	Dy = xx*zz-xz^2
	Dz = xx*yy-xy^2
	Dmax = max(Dx,Dy,Dz)
	@assert Dmax>0 "PlaneFromPoints: not a plane"
	if Dmax==Dx
		a = Dx
		b = xz*yz - xy*zz
		c = xy*yz - xz*yy
	elseif Dmax==Dy
		a = xz*yz - xy*zz
		b = Dy
		c = xy*xz - yz*xx
	elseif Dmax==Dz
		a = xy*yz - xz*yy
		b = xy*xz - yz*xx
		c = Dz
	end
	N = [a/Dmax,b/Dmax,c/Dmax]
	N/=Lar.norm(N)
	#plane = (a/Dmax,b/Dmax,c/Dmax,Lar.dot([a,b,c],centroid)/Dmax)
	return N, centroid
end

function PlaneDetectionFromRandomInitPoint(V::Lar.Points, par::Float64,threshold::Float64,failed::UInt16)

	# Init
	kdtree = KDTree(V)

	R = Int64[]
	listPoint = Array{Float64,2}[]

	# firt sample
	index, normal, centroid = PointClouds.SeedPointForPlaneDetection(V,threshold)
	planeDetected = Plane(normal,centroid)
	push!(R,index)

	PointClouds.flushprintln("========================================================")
	PointClouds.flushprintln("= Detection of Plane starting from Random Point $index =")
	PointClouds.flushprintln("========================================================")

	seeds = [index]
	visitedverts = copy(seeds)
	while !isempty(seeds)
		for seed in seeds
			idxs, dists = knn(kdtree, V[:,seed], 10, false, i -> i in visitedverts)
			filter = [dist<=threshold for dist in dists]
			N = idxs[filter]
			for i in N
				p = V[:,i]
				if PointClouds.IsNearToPlane(p,planeDetected,par)
					push!(seeds,i)
					push!(R,i)
				end
				push!(visitedverts,i)
			end
			setdiff!(seeds,seed)
		end
		listPoint = V[:,R]
		normal, centroid = PointClouds.PlaneFromPoints(listPoint)
		planeDetected.normal = normal
		planeDetected.centroid = centroid
	end

	return PlaneDataset(listPoint, planeDetected)
end



function PlaneDetectionFromGivenPoints(V::Lar.Points, FV::Lar.Cells, givenPoints::Lar.Points, par::Float64)

	# Init
	adj = listAdjacency(FV)
	R = Int64[]
	listPoint = Array{Float64,2}[]
	planeDetected = Plane([0,0,0.],[0.,0.,0.])
	kdtree = KDTree(V)

	# first sample
	normal, centroid = PointClouds.PlaneFromPoints(givenPoints)

	for i in 1:size(givenPoints,2)
		idxs, dists = knn(kdtree,givenPoints[:,i], 2, true)
		push!(R,idxs[1])
	end

	planeDetected.normal = normal
	planeDetected.centroid = centroid

	println("=================================================")
	println("= Detection of Plane starting from given Points =")
	println("=================================================")

	seeds = copy(R)
	visitedverts = copy(seeds)
	while !isempty(seeds)
		for seed in seeds
			N = PointClouds.findnearestof([seed],visitedverts,adj)
			for i in N
				p = V[:,i]
				if PointClouds.IsNearToPlane(p,planeDetected,par)
					push!(seeds,i)
					push!(R,i)
				end
				push!(visitedverts,i)
			end
			setdiff!(seeds,seed)
		end
		listPoint = V[:,R]
		normal, centroid = PointClouds.PlaneFromPoints(listPoint)
		planeDetected.normal = normal
		planeDetected.centroid = centroid
	end

	return PlaneDataset(listPoint, planeDetected)
end

function IsNearToPlane(p::Array{Float64,1},plane,par::Float64)::Bool
	return PointClouds.DistPointPlane(p,plane) <= par
end

function DistPointPlane(point::Array{Float64,1},plane)
	return Lar.abs(Lar.dot(point,plane.normal)-Lar.dot(plane.normal,plane.centroid))
end

function SeedPointForPlaneDetection(V::Lar.Points, threshold::Float64)
	"""
	Return index of point in V with minor residual.
	"""
	function minresidual(V::Lar.Points,plane::Plane)
		return findmin([PointClouds.DistPointPlane(V[:,i],plane) for i in 1:size(V,2)])[2]
	end

	kdtree = KDTree(V)
	randindex = rand(1:size(V,2))

	idxs, dists = knn(kdtree, V[:,randindex], 10, false)
	filter = [dist<=threshold for dist in dists]
	idxseeds = idxs[filter]
	seeds = V[:,idxseeds]

	normal,centroid = PointClouds.PlaneFromPoints(seeds)
	plane = Plane(normal,centroid)
	minresidual = minresidual(seeds,plane)
	seed = idxseeds[minresidual]

	return seed,normal,centroid
end

"""
"""
function DrawPlane(plane::Plane, AABB)
	V = PointClouds.intersectAABBplane(AABB,plane.normal,plane.centroid)
	#triangulate vertex projected in plane XY
	FV = PointClouds.DTprojxy(V)
	return V, sort.(FV)
end

"""
"""
function DrawPlanes(planes::Array{PlaneDataset,1}, AABB, u=0.2)
	out = Array{Lar.Struct,1}()
	for obj in planes
		pp = obj.plane
		if !isnothing(AABB)
			V = PointClouds.intersectAABBplane(AABB,pp.normal,pp.centroid)
		else
			bb = Lar.boundingbox(obj.points).+([-u,-u,-u],[u,u,u])
			V = PointClouds.intersectAABBplane(bb,pp.normal,pp.centroid)
		end
		#triangulate vertex projected in plane XY
		FV = PointClouds.DTprojxy(V)
		cell = (V,sort.(FV))
		push!(out, Lar.Struct([cell]))
	end
	out = Lar.Struct( out )
	V,FV = Lar.struct2lar(out)
	return V, FV
end


"""
Iterative shape detection.
"""
function RandomPlanesDetection(V::Lar.Points, N::Int, par::Float64, spacing::Float64, validPoints::Int64)

	# 1. - initialization
	Vcurrent = copy(V)
	PLANES = PlaneDataset[]

	i = 0
	# find N shapes
	while i < N
		global planedetected
		notfound = true
		while notfound
			try
				planedetected = PlaneDetectionFromRandomInitPoint(V,par,spacing)
				if size(planedetected.points,2) > validPoints
					notfound = false
				end
			catch y
				if !isa(y, AssertionError)
					notfound = false
				end
			end
		end

		i = i+1
		println("$i planes found")
		push!(PLANES,planedetected)

		# delete points of region found from current model
		tokeep = setdiff([1:size(Vcurrent,2)...],[PointClouds.matchcolumn(planedetected.points[:,i],Vcurrent) for i in 1:size(planedetected.points,2)])
		Vcurrent = Vcurrent[:,tokeep]
	end

	return PLANES
end



function PlanesDetectionRandom(PC::PointCloud, par::Float64, threshold::Float64, failed::Int64)

	# 1. - initialization
	PCcurrent = deepcopy(PC)
	PLANES = PlaneDataset[]
	planedetected = nothing

	f = 0
	i = 0
	# find N shapes
	search = true
	while search

		found = false

		while !found || f < failed
			try
				planedetected = PlaneDetectionFromRandomInitPoint(PCcurrent,par,threshold)
				pointsonplane = planedetected.points
				@assert  pointsonplane.n > validPoints "not valid"

				found = true

			catch y
				f=f+1
				# if !isa(y, AssertionError)
				# 	notfound = false
				# end
			end
		end

		if found
			i = i+1
			println("$i planes found")
			push!(PLANES,planedetected)

			# # delete points of region found from current model
			# tokeep = setdiff([1:size(Vcurrent,2)...],[PointClouds.matchcolumn(planedetected.points[:,i],Vcurrent) for i in 1:size(planedetected.points,2)])
			# Vcurrent = Vcurrent[:,tokeep]
			f = 0
			deletePoints!(PCcurrent,planedetected.points)
		else
			search = false
		end

	end

	return PLANES
end


function deletePoints!(PCcurrent::PointCloud, todel::PointCloud)
	tokeep = setdiff([1:PCcurrent.n...],[PointClouds.matchcolumn(todel.points[:,i], PCcurrent.points) for i in 1:todel.n])

	PCcurrent.n = length(tokeep)
	PCcurrent.points = PCcurrent.points[:,tokeep]
	PCcurrent.rgbs = PCcurrent.rgbs[:,tokeep]
end
