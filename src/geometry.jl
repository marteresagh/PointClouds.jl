"""
	centroid
"""
centroid(points::Lar.Points) = sum(points,dims=2)/size(points,2)


################################################################################ Residual
#TODO da modificare tutto in params
"""
	resplane(point, params)
"""

function resplane(point, axis, centroid)
	return Lar.abs(Lar.dot(point,axis)-Lar.dot(axis,centroid))
end

"""
	rescyl
"""
function rescyl(point, params)
	direction,center,radius, height = params
	r2 = radius^2
	y = point-center
	rp = y'*(Matrix{Float64}(Lar.I, 3, 3)-Lar.kron(direction,direction'))*y
	return Lar.abs(rp[1]-r2)
end

"""
	ressphere
"""
function ressphere(point, params)
	center, radius = params
	r2 = radius^2
	y = point-center
	rp = Lar.norm(y)^2
	return Lar.abs(rp[1]-r2)
end

"""
	rescone
"""
function rescone(point, params)
	coneVertex, coneaxis, radius, height = params
	cosalpha = height/(sqrt(height^2+radius^2))
	y = point-coneVertex
	rp = y'*(Matrix{Float64}(Lar.I, 3, 3)-Lar.kron(coneaxis/cosalpha,(coneaxis/cosalpha)'))*y
	return Lar.abs(rp[1])
end

"""
	restorus
"""
function restorus(point, params)
	C, N, rM, rm = params
	D =  point - C
	DdotD = Lar.dot(D,D)
	NdotD = Lar.dot(N,D)
	sum = DdotD + rM^2-rm^2
	res=sum^2 - 4*rM^2*(DdotD-NdotD^2)
	return Lar.abs(res)
end

################################################################################ distance point shape
"""
	isinsphere(p,params,par)::Bool

Checks if a point `p` in near enough to the `sphere`.
"""
function isinsphere(p,params,par)::Bool
	center,radius = params
	return PointClouds.ressphere(p,params) <= radius
end

"""
	isincyl(p,params,par)::Bool

Checks if a point `p` in near enough to the `cylinder`.
"""
function isincyl(p,params,par)::Bool
	return PointClouds.rescyl(p,params) <= par
end


"""
	isinplane(p::Array{Float64,1},plane::NTuple{4,Float64},par::Float64)::Bool

Checks if a point `p` in near enough to the `plane`.
"""
function isinplane(p::Array{Float64,1},axis,centroid,par::Float64)::Bool
    return PointClouds.resplane(p,axis,centroid)<=par
end

################################################################################ utilities
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

################################################################################ projection
"""
	projection(e,v)
e è la normale della superficie e v è il punto da proiettare
"""
function projection(e,v)
	p = v-Lar.dot(e,v)*e
	return p
end

"""
	pointsproj(V,N,C)

proiezione di tutti i punti sul piano ortogonale a N
"""
function pointsproj(V,N,C)
	npoints = size(V,2)
	for i in 1:npoints
		V[:,i] = PointClouds.projection(N,V[:,i]-C) + C
	end
	return convert(Lar.Points,V)
end

"""
	pointsprojcyl(V,params)

proiezione di tutti i punti sul cilindro
"""
function pointsprojcyl(V,params)
	axis,C,r,height = params
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-C
		c0 = Lar.dot(axis,p)*(axis)
		N = (p-c0)/Lar.norm(p-c0)
		c=r*N
		V[:,i] = PointClouds.projection(N,p-c) + c + C
	end
	return convert(Lar.Points,V)
end


"""
	pointsprojsphere(V,C,r)

proiezione di tutti i punti sulla sfera
"""
function pointsprojsphere(V,C,r)
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-C
		N = p/Lar.norm(p)
		c = r*N
		V[:,i] = PointClouds.projection(N,p-c) + c + C
	end
	return convert(Lar.Points,V)
end

"""
	pointsprojcone(V,axis,apex,angle)
"""
function pointsprojcone(V,axis,apex,angle)
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-apex
		c0 = Lar.dot(axis,p)*(axis)
		N = (p-c0)/Lar.norm(p-c0)
		c=Lar.dot(axis,c0)*tan(angle)*N
		V[:,i] = PointClouds.projection(N,p-c) + c + apex
	end
	return convert(Lar.Points,V)
end



"""
	 AABBdetection(aabb::Tuple{Array{Float64,1},Array{Float64,1}},AABB::Tuple{Array{Float64,1},Array{Float64,1}})::Bool

Compute collision detection of two AABB.

"""
function AABBdetection(aabb,AABB)::Bool
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
