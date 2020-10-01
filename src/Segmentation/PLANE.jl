mutable struct Plane
    normal::Array{Float64,1}
    centroid::Array{Float64,1}
end

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

function PlaneDetectionRandom(V::Lar.Points, FV::Lar.Cells, par::Float64)

    # Init
    EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.FV2EV,FV)))))
    adj = Lar.verts2verts(EV)
    R = Int64[]
    listPoint = Array{Float64,2}[]
	PlaneDetected = Plane([0,0,0.],[0.,0.,0.])

    # firt sample
    index, normal, centroid = PointClouds.SeedPointForPlaneDetection(V,adj)

	PlaneDetected.normal = normal
	PlaneDetected.centroid = centroid
    push!(R,index)

    println("=================================================")
    println("= Detection of Plane starting from Random Point =")
    println("=================================================")

    seeds = [index]
    visitedverts = copy(seeds)
    while !isempty(seeds)
        for seed in seeds
            N = PointClouds.findnearestof([seed],visitedverts,adj)
            for i in N
                p = V[:,i]
                if PointClouds.IsNearToPlane(p,PlaneDetected,par)
                    push!(seeds,i)
                    push!(R,i)
                end
                push!(visitedverts,i)
            end
            setdiff!(seeds,seed)
        end
        listPoint = V[:,R]
        normal, centroid = PointClouds.PlaneFromPoints(listPoint)
		PlaneDetected.normal = normal
		PlaneDetected.centroid = centroid
    end

    return listPoint, PlaneDetected
end


function PlaneDetectionFromGivenPoints(V::Lar.Points, FV::Lar.Cells, givenPoints::Lar.Points, par::Float64)

	# Init
	EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.FV2EV,FV)))))
	adj = Lar.verts2verts(EV)
	R = Int64[]
	listPoint = Array{Float64,2}[]
	PlaneDetected = Plane([0,0,0.],[0.,0.,0.])

	# firt sample
	normal, centroid = PointClouds.PlaneFromPoints(givenPoints)

	for i in 1:size(givenPoints,2)
		index = PointClouds.matchcolumn(givenPoints[:,i],V)
		push!(R,index)
	end

	PlaneDetected.normal = normal
	PlaneDetected.centroid = centroid

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
				if PointClouds.IsNearToPlane(p,PlaneDetected,par)
					push!(seeds,i)
					push!(R,i)
				end
				push!(visitedverts,i)
			end
			setdiff!(seeds,seed)
		end
		listPoint = V[:,R]
		normal, centroid = PointClouds.PlaneFromPoints(listPoint)
		PlaneDetected.normal = normal
		PlaneDetected.centroid = centroid
	end

	return listPoint, PlaneDetected
end

function IsNearToPlane(p::Array{Float64,1},plane::Plane,par::Float64)::Bool
    return PointClouds.DistPointPlane(p,plane) <= par
end

function DistPointPlane(point::Array{Float64,1},plane::Plane)
	return Lar.abs(Lar.dot(point,plane.normal)-Lar.dot(plane.normal,plane.centroid))
end

function SeedPointForPlaneDetection(V::Lar.Points,adj::Array{Array{Int64,1},1})

	"""
	Return index of point in V with minor residual.
	"""
	function minresidual(V::Lar.Points,plane::Plane)
			return findmin([PointClouds.DistPointPlane(V[:,i],plane) for i in 1:size(V,2)])[2]
	end

	randindex = rand(1:size(V,2))

	idxneighbors = PointClouds.findnearestof([randindex],[randindex],adj)
	idxseeds = union(randindex,idxneighbors)
	seeds = V[:,idxseeds]

	normal,centroid = PointClouds.PlaneFromPoints(seeds)
	plane = Plane(normal,centroid)
	minresidual = minresidual(seeds,plane)
	seed = idxseeds[minresidual]

	return seed,normal,centroid
end

"""
"""
function DrawPlane(listPoint::Lar.Points, plane::Plane, AABB)
    V = PointClouds.intersectAABBplane(AABB,plane.normal,plane.centroid)
	#triangulate vertex projected in plane XY
 	FV = PointClouds.DTprojxy(V)
    return V, sort.(FV)
end