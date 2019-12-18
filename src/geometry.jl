"""
	centroid
"""
centroid(points::Lar.Points) = sum(points,dims=2)/size(points,2)

"""
	distpointsphere
"""
function distpointsphere(p,params)::Float64
	center,radius = params
	return Lar.abs(Lar.norm(p-center) - radius)
end

function ispointinsphere(p,params,par)::Bool
	center,radius = params
	return Tesi.distpointsphere(p,params) <= radius
end

"""
	distpointcyl
"""
function ispointincyl(p,params,par)::Bool
	return Tesi.distpointcyl(p,params) <= par
end

function distpointcyl(p,params)::Float64
	W,C,r,height = params
	return Lar.abs(Tesi.distpointline(p,W,C)-r)
end

"""
	distpointellipsoid  #TODO da finire e verificare se effettivamente serve

"""
function distpointellipsoid(p,params,par)::Bool
	center, radii, rot = params
	diff = p-center
	y = zeros(3)
	for i in 1:3
		y[i]=Lar.dot(diff,rot[:,i])
	end
	x=Lar.norm(radii,y)
	return testsurf && testheight
end

"""
	distpointline
"""
function distpointline(p,W,C)
	x0 = copy(p)
	x1 = copy(C[:,1])
	x2 = C[:,1]+W
	d = Lar.norm(Lar.cross(x0-x1,x0-x2))/Lar.norm(x2-x1)
	return d
end

"""
	distpointplane(p::Array{Float64,1},plane::NTuple{4,Float64})::Float64

Computes distance from a point `p` to a `plane`.
"""
function distpointplane(p::Array{Any,1},axis,centroid)::Float64
    return Lar.abs(Lar.dot(axis,p)-Lar.dot(axis,centroid))/Lar.norm(axis)
end

"""
	isinplane(p::Array{Float64,1},plane::NTuple{4,Float64},par::Float64)::Bool

Checks if a point `p` in near enough to the `plane`.
"""
function isinplane(p::Array{Float64,1},axis,centroid,par::Float64)::Bool
    return distpointplane(p,axis,centroid)<=par
end

"""
	subtractaverage(points::Lar.Points)

Compute the average of the data points and traslate data.
"""
function subtractaverage(points::Lar.Points)
	m,npoints = size(points)
	centroid = Tesi.centroid(points)
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
