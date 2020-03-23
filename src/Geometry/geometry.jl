"""
	centroid(points::Lar.Points)

Average of points.
"""
centroid(points::Union{Lar.Points,Array{Float64,1}}) = sum(points,dims=2)/size(points,2)

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
	#Y = map(Lar.approxVal(16), Y)
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
 	height()
"""
function height(direction:: Array{Float64,1}, V::Lar.Points)
	hmin = +Inf
	hmax = -Inf

	for i in 1:size(V,2)
		h = Lar.dot(direction,V[:,i])
		if h > hmax
			hmax = h
		elseif h < hmin
			hmin = h
		end
	end

	return hmax-hmin
end


"""
Compute collision detection of two AABB.
"""
function  AABBdetection(aabb::Tuple{Array{Float64,2},Array{Float64,2}},AABB::Tuple{Array{Float64,2},Array{Float64,2}})::Bool
	A=hcat(aabb...)
	B=hcat(AABB...)
	@assert size(A,1) == size(B,1) "AABBdetection: not same dimension"
	dim = size(A,1)
	m=1
	M=2
	# 1. - axis x AleftB = A[1,max]<B[1,min]  ArightB = A[1,min]>B[1,max]
	# 2. - axis y AfrontB = A[2,max]<B[2,min]  AbehindB = A[2,min]>B[2,max]
	if dim == 3
		# 3. - axis z AbottomB = A[3,max]<B[3,min]  AtopB = A[3,min]>B[3,max]
		return !( A[1,M]<=B[1,m] || A[1,m]>=B[1,M] ||
				 A[2,M]<=B[2,m] ||A[2,m]>=B[2,M] ||
				  A[3,M]<=B[3,m] || A[3,m]>=B[3,M] )

	end
	return !( A[1,M]<=B[1,m] || A[1,m]>=B[1,M] ||
			 A[2,M]<=B[2,m] || A[2,m]>=B[2,M] )
end

"""
	flat(allplanes)

"""
function flat(allplanes)
	for i in 1:length(allplanes)
		params = allplanes[i][2]
		allplanes[i][1]=PointClouds.pointsproj(allplanes[i][1],params)
	end
end


"""
 	CAT(args)
"""
function CAT(args)
	return reduce( (x,y) -> append!(x,y), args; init=[] )
end
