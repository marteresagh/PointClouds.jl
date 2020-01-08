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
