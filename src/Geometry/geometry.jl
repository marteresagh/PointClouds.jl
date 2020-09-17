"""
	centroid(points::Lar.Points)

Average of points.
"""
centroid(points::Union{Lar.Points,Array{Float64,1}}) = (sum(points,dims=2)/size(points,2))[:,1]

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

"""
Check if point is in a aabb
"""
function isinbox(aabb,p)
	min=aabb[1]
	max=aabb[2]
	return (  p[1]>=min[1] && p[1]<=max[1] &&
			  p[2]>=min[2] && p[2]<=max[2] &&
			   p[3]>=min[3] && p[3]<=max[3] )
end


"""
Find the rotation matrix that aligns vec1 to vec2
vec1: A 3d "source" vector,
vec2: A 3d "reference" vector,
Return affine transformation matrix (4x4) which when applied to vec1, aligns it with vec2.
"""
function rotation_matrix_from_vectors(vec1, vec2)
	#alcuni spunti
	#https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
    v = Lar.cross(vec1, vec2)
    c = Lar.dot(vec1, vec2)
    s = Lar.norm(v)
    kmat = [0 -v[3] v[2]; v[3] 0 -v[1]; -v[2] v[1] 0]
    rotation_matrix = Matrix(Lar.I,3,3) + kmat + kmat^2* ((1 - c) / (s ^ 2))
    return vcat(hcat(rotation_matrix,[0,0,0]),[0.,0.,0.,1.]')
end

function rotoTraslation(planesource,planeref)
	axref, centref = planeref
	axsour, centsour = planesource
	rotation_matrix = PointClouds.rotation_matrix_from_vectors(axref,axsour)

	rototrasl = Lar.t(centref...)*rotation_matrix'*Lar.t(-centsour...)
	return rototrasl
end

function alignbox2plane(pointofplane::Lar.Points, boxmodel)
	planeref = PointClouds.planefit(pointofplane)
	V, EV, FV = boxmodel
	planesource = PointClouds.planefit(V)
	return PointClouds.rotoTraslation(planesource,planeref)
end
