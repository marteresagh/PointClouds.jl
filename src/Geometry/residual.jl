"""
	resplane(point, params)
"""
function resplane(point::Array{Float64,1},params)
	axis,centroid = params
	return Lar.abs(Lar.dot(point,axis)-Lar.dot(axis,centroid))
end

"""
	rescyl
"""
function rescyl(point::Array{Float64,1}, params)
	direction,center,radius, height = params
	p = point-center
	c0 = Lar.dot(direction,p)*(direction)
	return Lar.abs(Lar.norm(p-c0)-radius)
end

"""
	ressphere
"""
function ressphere(point::Array{Float64,1}, params)
	center, radius = params
	rp = Lar.norm(point-center)
	return Lar.abs(rp-radius)
end

"""
	rescone
"""
function rescone(point::Array{Float64,1}, params)
	apex, axis, angle, height = params
	p = point-apex
	c0 = Lar.dot(axis,p)*(axis)
	l=Lar.abs(Lar.norm(p-c0)-Lar.dot(axis,c0)*tan(angle))
	return l*cos(angle)
end

"""
	restorus
"""
function restorus(point::Array{Float64,1}, params)
	direction,center,r0,r1 = params
	p = point-center
	c0 = Lar.dot(direction,p)*(direction)
	N = (p-c0)/Lar.norm(p-c0)
	c1 = r0*N
	axis = (p-c1)/Lar.norm(p-c1)
	c=c1+r1*axis
	return Lar.norm(p-c)
end

################################################################################ distance point shape
"""
	isinsphere(p,params,par)::Bool

Checks if a point `p` in near enough to the `sphere`.
"""
function isinsphere(p::Array{Float64,1},params,par::Float64)::Bool
	center,radius = params
	return PointClouds.ressphere(p,params) <= par
end

"""
	isincyl(p,params,par)::Bool

Checks if a point `p` in near enough to the `cylinder`.
"""
function isincyl(p::Array{Float64,1},params,par::Float64)::Bool
	return PointClouds.rescyl(p,params) <= par
end


"""
	isinplane(p::Array{Float64,1},plane::NTuple{4,Float64},par::Float64)::Bool

Checks if a point `p` in near enough to the `plane`.
"""
function isinplane(p::Array{Float64,1},params,par::Float64)::Bool
    return PointClouds.resplane(p,params) <= par
end


"""
	isincone(p::Array{Float64,1},plane::NTuple{4,Float64},par::Float64)::Bool

Checks if a point `p` in near enough to the `cone`.
"""
function isincone(p::Array{Float64,1},params,par::Float64)::Bool
    return PointClouds.rescone(p,params) <= par
end

"""
	isintorus(p::Array{Float64,1},plane::NTuple{4,Float64},par::Float64)::Bool

Checks if a point `p` in near enough to the `cone`.
"""
function isintorus(p::Array{Float64,1},params,par::Float64)::Bool
    return PointClouds.restorus(p,params) <= par
end

"""
Return residual.
"""
function residual(V::Lar.Points,params,shape::String)
	if shape == "plane"
		return findmax([PointClouds.resplane(V[:,i],params) for i in 1:size(V,2)])
	elseif shape == "cylinder"
		return findmax([PointClouds.rescyl(V[:,i],params) for i in 1:size(V,2)])
	elseif shape == "sphere"
		return findmax([PointClouds.ressphere(V[:,i],params) for i in 1:size(V,2)])
	elseif shape == "cone"
		return findmax([PointClouds.rescone(V[:,i],params) for i in 1:size(V,2)])
	elseif shape == "torus"
		return findmax([PointClouds.restorus(V[:,i],params) for i in 1:size(V,2)])
	end
end
