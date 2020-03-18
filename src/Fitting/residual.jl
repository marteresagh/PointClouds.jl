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
	r2 = radius^2
	y = point-center
	rp = y'*(Matrix{Float64}(Lar.I, 3, 3)-Lar.kron(direction,direction'))*y
	return Lar.abs(rp[1]-r2)
end

"""
	ressphere
"""
function ressphere(point::Array{Float64,1}, params)
	center, radius = params
	y = point-center
	rp = Lar.norm(y)
	return Lar.abs(rp-radius)
end

"""
	rescone
"""
function rescone(point::Array{Float64,1}, params)
	coneVertex, coneaxis, radius, height = params
	cosalpha = height/(sqrt(height^2+radius^2))
	y = point-coneVertex
	rp = y'*(Matrix{Float64}(Lar.I, 3, 3)-Lar.kron(coneaxis/cosalpha,(coneaxis/cosalpha)'))*y
	return Lar.abs(rp[1])
end

"""
	restorus
"""
function restorus(point::Array{Float64,1}, params)
	C, N, rM, rm = params
	D =  point - C
	DdotD = Lar.dot(D,D)
	NdotD = Lar.dot(N,D)
	sum = DdotD + rM^2-rm^2
	res = sum^2 - 4*rM^2*(DdotD-NdotD^2)
	return Lar.abs(res)
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
