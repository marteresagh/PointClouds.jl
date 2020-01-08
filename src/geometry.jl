"""
	centroid
"""
centroid(points::Lar.Points) = sum(points,dims=2)/size(points,2)

"""
	distpointsphere
"""
function ispointinsphere(p,params,par)::Bool
	center,radius = params
	return PointClouds.ressphere(p,params) <= radius
end

"""
	distpointcyl
"""
function ispointincyl(p,params,par)::Bool
	return PointClouds.rescyl(p,params) <= par
end


"""
	isinplane(p::Array{Float64,1},plane::NTuple{4,Float64},par::Float64)::Bool

Checks if a point `p` in near enough to the `plane`.
"""
function isinplane(p::Array{Float64,1},axis,centroid,par::Float64)::Bool
    return resplane(p,axis,centroid)<=par
end

"""
	subtractaverage(points::Lar.Points)

Compute the average of the data points and traslate data.
"""
function subtractaverage(points::Lar.Points)
	m,npoints = size(points)
	centroid = PointClouds.centroid(points)
	affineMatrix = Lar.t(-centroid...)
	V = [points; fill(1.0, (1,npoints))]
	Y = (affineMatrix * V)[1:m,1:npoints]
	Y = map(Lar.approxVal(16), Y)
	return centroid,Y
end

"""
	intersectAABBplane(AABB::Tuple{Array{Float64,2},Array{Float64,2}}, plane::NTuple{4,Float64})

Returns verteces of the intersection of a `plane` and an `AABB`.
"""
function intersectAABBplane(AABB::Tuple{Array{Float64,2},Array{Float64,2}}, axis,centroid)

    function pointint(i,j,lambda,allverteces)
        return allverteces[i]+lambda*(allverteces[j]-allverteces[i])
    end

	coordAABB = hcat(AABB...)

    allverteces = []
    for x in coordAABB[1,:]
        for y in coordAABB[2,:]
            for z in coordAABB[3,:]
                push!(allverteces,[x,y,z])
            end
        end
    end

    vertexpolygon = []
    for (i,j) in Lar.larGridSkeleton([1,1,1])(1)
        lambda = (Lar.dot(axis,centroid)-Lar.dot(axis,allverteces[i]))/Lar.dot(axis,allverteces[j]-allverteces[i])
        if lambda>=0 && lambda<=1
            push!(vertexpolygon,pointint(i,j,lambda,allverteces))
        end
    end
    return hcat(vertexpolygon...)
end

"""
	matchcolumn(a,B)

Finds index column of `a` in matrix `B`.
Returns `nothing` if `a` is not column of `B`.
"""
matchcolumn(a,B) = findfirst(j->all(i->a[i] == B[i,j],1:size(B,1)),1:size(B,2))


"""
 	heightquadric()

W direction of axis , Y points translate to center
"""
function heightquadric(W, Y)
	hmin = +Inf
	hmax = -Inf

	for i in 1:size(Y,2)
		h = Lar.dot(W,Y[:,i])
		if h > hmax
			hmax = h
		elseif h < hmin
			hmin = h
		end
	end

	return hmax-hmin
end
