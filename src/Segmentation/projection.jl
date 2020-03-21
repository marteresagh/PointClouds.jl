"""
	projection(e,v)
e è la normale della superficie e v è il punto da proiettare
"""
function projection(e,v)
	p = v - Lar.dot(e,v)*e
	return p
end

"""
	pointsproj(V,parmas)

proiezione di tutti i punti sul piano ortogonale a N
"""
function pointsproj(V::Lar.Points,params)
	N,C = params
	npoints = size(V,2)
	for i in 1:npoints
		V[:,i] = PointClouds.projection(N, V[:,i] - C) + C
	end
	return convert(Lar.Points,V)
end

"""
	pointsprojcyl(V,params)

proiezione di tutti i punti sul cilindro
"""
function pointsprojcyl(V::Lar.Points,params)
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
function pointsprojsphere(V::Lar.Points,params)
	C,r=params
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
function pointsprojcone(V::Lar.Points,params)
	apex, axis, angle, height = params
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

"""
function pointsprojtorus(V,params)
	direction,center,r0,r1 = params
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-center
		c0 = Lar.dot(direction,p)*(direction)
		N = (p-c0)/Lar.norm(p-c0)
		c1 = r0*N
		axis = (p-c1)/Lar.norm(p-c1)
		c=c1+r1*axis
		V[:,i] = PointClouds.projection(axis,p-c) + c + center
	end
	return convert(Lar.Points,V)
end

function projectpointson(V::Lar.Points,params,shape::String)
	if shape == "plane"
		return PointClouds.pointsproj(V,params)
	elseif shape == "cylinder"
		return PointClouds.pointsprojcyl(V,params)
	elseif shape == "sphere"
		return PointClouds.pointsprojsphere(V,params)
	elseif shape == "cone"
		return PointClouds.pointsprojcone(V,params)
	elseif shape == "torus"
		return PointClouds.pointsprojtorus(V,params)
	end
end
