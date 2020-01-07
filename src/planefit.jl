"""
	planefit(points::Lar.Points)

Returns fitting plane of `points`.
"""
function planefit(points::Lar.Points)

	npoints = size(points,2)
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
    @assert Dmax>0 "planefit: not a plane"
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

"""
	planeshape(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64)

Returns all the points `pointsonshape` liyng on the `plane` found.

"""
function planeshape(V::Lar.Points,FV::Lar.Cells,par::Float64;index=0,NOTPLANE=3::Int64)

	# 1. list of adjacency verteces
	EV = Lar.simplexFacets(FV)
   	adj = Lar.verts2verts(EV)

	# # 2. first three points
    # i = rand(1:length(FV))
	# index = copy(FV[i])
    # pointsonplane = V[:,index]
	# plane = PointClouds.planefit(pointsonplane)
	#
	# # 3. find neighbors of points on plane
	# visitedverts = copy(index)
	# idxneighbors = PointClouds.findnearestof(index,visitedverts,adj)

	# 2. first samples
	if index==0
		index = rand(1:size(V,2))
	end
	@show index
	visitedverts = [index]
	idxneighbors = PointClouds.findnearestof([index],visitedverts,adj)
	index = union(index,idxneighbors)
	pointsonplane = V[:,index]
	axis,centroid = PointClouds.planefit(pointsonplane)
	visitedverts = copy(index)
	idxneighbors = PointClouds.findnearestof(index,visitedverts,adj)

	# 4. check if this neighbors are other points of plane
    while !isempty(idxneighbors)

	    for i in idxneighbors
            p = V[:,i]

            if PointClouds.isinplane(p,axis,centroid,par)
				push!(index,i)
            end

			push!(visitedverts,i)

        end

		pointsonplane = V[:,index]
		axis,centroid = PointClouds.planefit(pointsonplane)
        idxneighbors = PointClouds.findnearestof(index,visitedverts,adj)
    end

	if size(pointsonplane,2) <= NOTPLANE
		println("planeshape: not a valid plane")
		return nothing, nothing
	end
    return  pointsonplane,axis,centroid
end


"""
	resplane(point, params)
"""

function resplane(point, axis, centroid)
	return Lar.dot(point,axis)-Lar.dot(axis,centroid)
end

"""
	larmodelplane(pointsonplane::Lar.Points, plane::NTuple{4,Float64}, u=0.01)

Returns the intersection polygon between the `plane` and the AABB of `pointsonplane`.
`u` enlarges the shape of AABB.
"""
function larmodelplane(pointsonplane::Lar.Points, axis,centroid, u=0.01)
	AABB = Lar.boundingbox(pointsonplane).+([-u,-u,-u],[u,u,u])
    V = PointClouds.intersectAABBplane(AABB,axis,centroid)
	#triangulate vertex projected in plane XY
 	FV = PointClouds.DTprojxy(V)
    return V, sort.(FV)
end
