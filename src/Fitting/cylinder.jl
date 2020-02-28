"""
	preprocess
"""
function preprocess(points::Lar.Points)
	#1. - translate centroid
	npoints = size(points,2)
	centroid,Y = PointClouds.subtractaverage(points)

	#2. - compute mu
	x = Y[1,:]
	y = Y[2,:]
	z = Y[3,:]
	products = hcat(map(e->e^2,x),2*x.*y,2*x.*z,map(e->e^2,y),2*y.*z,map(e->e^2,z))
	mu = vcat(sum(products, dims=1)...)
	mu /= npoints

	#3. - compute F0,F1,F2
	F0 = zeros(3,3)
	F1 = zeros(3,6)
	F2 = zeros(6,6)

	for i in 1:npoints
		r = Y[:,i]
		delta = products[i,:] - mu
		F0 += kron(r,r')
		F1 += kron(r,delta')
		F2 += kron(delta,delta')
	end

	F0 /= npoints
	F1 /= npoints
	F2 /= npoints
	return  centroid, Y, mu, F0, F1, F2
end

"""
	G(Y,mu,F0,F1,F2,W)

funzione da minimizzare
"""
function G(Y,mu,F0,F1,F2,W)
	npoints = size(Y,2)
	P = Lar.I(3) - kron(W,W')
	S = [0 -W[3] W[2]; W[3] 0 -W[1]; -W[2] W[1] 0]
	A = P*F0*P
	hatA = -(S*A*S)
	hatAA = hatA*A
	trace = Lar.tr(hatAA)
	Q = hatA/trace
	p = [P[1,1],P[1,2],P[1,3],P[2,2],P[2,3],P[3,3]]
	alpha = F1*p
	beta = Q*alpha
	error = (Lar.dot(p,F2*p)-4*Lar.dot(alpha,beta)+4*Lar.dot(beta,F0*beta))/npoints
	PC = beta
	rsqr = Lar.dot(p,mu)+Lar.dot(beta,beta)
	return PC,rsqr,error
end

"""
	cylinderfit(V::Lar.Points)

"""
function cylinderfit(V::Lar.Points)
	#1. - preprocess of data
	centroid, Y, mu, F0, F1, F2 = PointClouds.preprocess(V)

	#2. - find direction, center and radius that minimize function G()
	minerror = Inf
	W = zeros(3)
	C = zeros(3)
	r = 0.
	jmax = 64
	imax = 64
	for j = 0:jmax
		phi = pi/2 * j/jmax
		csphi = cos(phi)
		snphi = sin(phi)
		for i = 0:imax-1
			theta = 2*pi*i/imax
			cstheta = cos(theta)
			sntheta = sin(theta)
			currentW = [cstheta*snphi, sntheta * snphi, csphi]
			currentC,currentRsqr,error = PointClouds.G(Y,mu,F0,F1,F2,currentW)
			if error < minerror
				minerror = error
				W = currentW
				C = currentC
				r = sqrt(currentRsqr)
			end
		end
	end
	#3. - translate center
	C += centroid

	#4. - find height
	height = height(W, Y)

	return W,C,r,height
end


"""
	larmodelcyl(center,radius)(shape = [36,1])
"""
function larmodelcyl(direction,center,radius,height)
	function larmodelcyl0(shape = [36,1])
		cyl0 = Lar.cylinder(radius,height)(shape)
		centroid = PointClouds.centroid(cyl0[1])
		cyl = Lar.apply(Lar.t(-centroid...),cyl0)
		matrixaffine = hcat(Lar.nullspace(Matrix(direction')),direction)
		mrot = vcat(hcat(matrixaffine,[0,0,0]),[0.,0.,0.,1.]')
		return Lar.apply(Lar.t(center...),Lar.apply(mrot,cyl))
	end
	return larmodelcyl0
end
