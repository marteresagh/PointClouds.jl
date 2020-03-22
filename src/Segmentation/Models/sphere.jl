"""
	spherefit(points::Lar.Points)
"""
function spherefit(points::Lar.Points)

	center = nothing
	radius = nothing

	# 1. - translation centroid
	npoints = size(points,2)
	@assert npoints>=4 "spherefit: at least 4 points needed"
	centroid, Y = PointClouds.subtractaverage(points)

	# 2. - costruction matrix W upper triangle
	W = zeros(5,5)
	for i in 1:npoints
		r = Y[:,i]
		Y0Y0 = r[1]^2
		Y0Y1 = r[1]*r[2]
		Y0Y2 = r[1]*r[3]
		Y1Y1 = r[2]^2
		Y1Y2 = r[2]*r[3]
		Y2Y2 = r[3]^2
		RR = Y0Y0 + Y1Y1 + Y2Y2
		RRRR = RR^2
		Y0RR = r[1]*RR
		Y1RR = r[2]*RR
		Y2RR = r[3]*RR
		W[1,5] += RR
		W[2,2] += Y0Y0
		W[2,3] += Y0Y1
		W[2,4] += Y0Y2
		W[2,5] += Y0RR
		W[3,3] += Y1Y1
		W[3,4] += Y1Y2
		W[3,5] += Y1RR
		W[4,4] += Y2Y2
		W[4,5] += Y2RR
		W[5,5] += RRRR
	end
	W/=npoints
	W[1,1] = 1.

	# 3. - lower triangle
	W[5,1] = W[1,5]
	W[3,2] = W[2,3]
	W[4,2] = W[2,4]
	W[5,2] = W[2,5]
	W[4,3] = W[3,4]
	W[5,3] = W[3,5]
	W[5,4] = W[4,5]

	W = map(Lar.approxVal(16), W)
	eigvals = Lar.eigvals(W)
	eigvecs = Lar.eigvecs(W)

	# 4. - compute params
	f0 = eigvecs[1,1]
	f1 = [eigvecs[2,1],eigvecs[3,1],eigvecs[4,1]]
	f2 = eigvecs[5,1]

	b0 = f0 - Lar.dot(f1,centroid) + f2*Lar.dot(centroid,centroid)
	b1 = f1 - 2*f2*centroid
	b2 = f2

	@assert b2!=0 "spherefit: not a sphere"
	discr = Lar.dot(b1,b1)-4*b0*b2
	if discr>=0
		center = -b1/(2*b2)
		radius = sqrt(discr/(4*b2^2))
	end

	return center,radius
end


"""
	larmodelsphere(center,radius)(shape = [64,64])
"""
function larmodelsphere(params)
	center,radius = params
	function larmodelsphere0(shape = [64,64])
		return Lar.apply(Lar.t(center...),Lar.sphere(radius)(shape))
	end
	return larmodelsphere0
end
