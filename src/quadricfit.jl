#TODO
# sistemare codice,
# rendere incrementale
#
################################################################################ Cylinder fit
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
	height = heightquadric(W, Y)

	return W,C,r,height
end

################################################################################ Sphere fit
"""
	spherefit(points::Lar.Points)
"""
function spherefit(points::Lar.Points)

	center = nothing
	radius = nothing

	#1. - translation centroid
	npoints = size(points,2)
	centroid, Y = PointClouds.subtractaverage(points)

	#2. - costruction matrix W upper triangle
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

	#3. - lower triangle
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

	#4. - compute params
	f0 = eigvecs[1,1]
	f1 = [eigvecs[2,1],eigvecs[3,1],eigvecs[4,1]]
	f2 = eigvecs[5,1]

	b0 = f0 - Lar.dot(f1,centroid) + f2*Lar.dot(centroid,centroid)
	b1 = f1 - 2*f2*centroid
	b2 = f2

	if b2!=0
		discr = Lar.dot(b1,b1)-4*b0*b2
		if discr>=0
			center = -b1/(2*b2)
			center = map(Lar.approxVal(16), center)
			radius = sqrt(discr/(4*b2^2))
			radius = map(Lar.approxVal(16), radius)
		end
	end

	return center,radius
end

################################################################################ Cone fit
#vedi se meglio questo o quello scritto in matlab

function initialcone(points)
	# da sistemare

	npoints = size(points,2)
	#1. - center pointcloud
	centroid, Y = PointClouds.subtractaverage(points)

	#2. - cone axis
	coneaxis = [0.,0.,0.]
	for i = 1:npoints
		diff = Y[:,i]
		coneaxis+=Lar.dot(diff,diff)*diff
	end
	coneaxis*=1/npoints
	coneaxis = map(Lar.approxVal(16),coneaxis/Lar.norm(coneaxis))

	#3. - compute a[i] = Lar.dot(U,X[i]-C) b[i]= Lar.dot(X[i]-C,X[i]-C)
	c10 = 0.
	c20 = 0.
	c30 = 0.
	c01 = 0.
	c02 = 0.
	c11 = 0.
	c21 = 0.

	for i in 1:npoints
		diff = Y[:,i]
		ai = Lar.dot(coneaxis,diff)
		bi = Lar.dot(diff,diff)
		c10 += ai
		c20 += ai^2
		c30 += ai^3
		c01 += bi
		c02 += bi^2
		c11 += ai*bi
		c21 += ai^2*bi
	end

	c10 *=1/npoints
	c20 *=1/npoints
	c30 *=1/npoints
	c01 *=1/npoints
	c02 *=1/npoints
	c11 *=1/npoints
	c21 *=1/npoints

	#4. - compute coeff p3(t) q3(t)
	e0 = 3*c10
	e1 = 2*c20 + c01
	e2 = c11
	e3 = 3*c20
	e4 = c30


	#5. - compute coeff of g(t)
	g0 = c11*c21 - c02*c30
	g1 = c01*c21 - 3*c02*c20 + 2*(c20*c21 - c11*(c30 - c11))
	g2 = 3*(c11 *(c01 - c20) + c10*(c21 - c02))
	g3 = c21 - c02 + c01*(c01 + c20) + 2*(c10*(c30 - c11) - c20^2)
	g4 = c30 - c11 + c10*(c01-c20)

	#6. - compute the roots of g(t)=0
	info = []

	roots = Polynomials.roots(Poly([g0,g1,g2,g3,g4]))
	for element in roots
		if imag(element) == 0.
			t = real(element)
			if t > 0.
				p3 = e2 + t*(e1 + t*(e0 + t))
				if p3 != 0.
					q3 = e4 + t*(e3 + t*(e0 + t))
					s = q3 / p3
					if s > 0 && s < 1
						error = 0.
						for i in 1:npoints
							diff = Y[:,i]
							ai = Lar.dot(coneaxis, diff)
							bi = Lar.dot(diff, diff)
							tpai = t+ai
							Fi = s*(bi + t*(2*ai+t))- tpai^2
							error += Fi^2
						end
						error *=1/npoints
						item = [s,t,error]
						push!(info,item)
					end
				end
			end
		end
	end
	minerror = Inf
	minitem = [0.,0.,minerror]
	for item in info
		if item[3] < minerror
			minitem = item
		end
	end

	if minitem[3]<Inf
		coneVertex = centroid - minitem[2]*coneaxis
		coneCosAngle = sqrt(minitem[1])
	else
		coneVertex = centroid
		coneCosAngle = sqrt(0.5)
	end

	return coneaxis, coneVertex, coneCosAngle  #cone axis e height ok cone vertex e angle da rivedere
end

function conefit(points)
	#p=(apex,direction)

	# [f1,f2,f3,..]
	function fc(points)
		function fc0(p)
			apex = [p[1],p[2],p[3]]
			W = [p[4],p[5],p[6]]
			fi = []
			for i in 1:size(points,2)
				delta = apex - points[:,i]
				push!(fi,Lar.dot(delta,delta) - Lar.dot(delta,W)^2)
			end
			return fi
		end
		return fc0
	end

	#[df1/dp[1] df1/dp[2] df1/dp[3] df1/dp[4] df1/dp[5] df1/dp[6];
   	#df2/dp[1] df2/dp[2] df2/dp[3] df2/dp[4] df2/dp[5] df2/dp[6];
   	#  ...]
	function jc(points)
		function jc0(p)
			apex = [p[1],p[2],p[3]]
			W = [p[4],p[5],p[6]]
			i=1
			delta = apex - points[:,i]
			jt = hcat(2*(delta - Lar.dot(delta,W)*W)', -2*(Lar.dot(delta,W)*delta)')
			for i = 2:size(points,2)
				delta = apex - points[:,i]
				ji = hcat(2*(delta - Lar.dot(delta,W)*W)', -2*(Lar.dot(delta,W)*delta)')
				jt = vcat(jt,ji)
			end
			return jt
		end
		return jc0
	end


	npoints = size(points,2)
	coneaxis, coneVertex, coneCosAngle = PointClouds.initialcone(points)

	initial = vcat(coneVertex,coneaxis.*1/coneCosAngle)[:,1]
	R1 = LsqFit.OnceDifferentiable(fc(points), jc(points),zeros(6),zeros(npoints); inplace = false)
	results = LsqFit.levenberg_marquardt(R1, initial; show_trace=true)
	@show LsqFit.OptimBase.converged(results)
	coneVertex = LsqFit.OptimBase.minimizer(results)[1:3]

	coneaxis = Lar.approxVal(10).(LsqFit.OptimBase.minimizer(results)[4:6])

	# invconeaxis = map(e->1/e,coneaxis)
	# coneCosAngle =  Lar.min(push!(Lar.abs.(invconeaxis),1.0)...)
	#
	# coneAngle = Lar.acos(coneCosAngle)  #TODO ancora non ci siamo con l'angolo ma possiamo cmq provare a calcolarlo in un altro modo

	coneaxis/=Lar.norm(coneaxis)
	otherdirection = Lar.nullspace(Matrix(coneaxis'))[:,1]
	height = -Inf
	radius = -Inf
	for i in 1:npoints
		p = points[:,i] - coneVertex
		h = Lar.dot(coneaxis,p)
		r = Lar.dot(otherdirection,p)
		if Lar.abs(h) > height
			height = Lar.abs(h)
		end
		if Lar.abs(r) > radius
			radius = Lar.abs(r)
		end
	end
	angle = atan(radius/height)
	#radius = height*tan(coneAngle)

	return coneVertex, coneaxis, angle, height
end


################################################################################ Lar Model
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

"""
	larmodelsphere(center,radius)(shape = [64,64])
"""
function larmodelsphere(center,radius)
	function larmodelsphere0(shape = [64,64])
		return Lar.apply(Lar.t(center...),Lar.sphere(radius)(shape))
	end
	return larmodelsphere0
end

"""
	larmodelcone(center,radius)(shape = [36,1])
"""
function larmodelcone(direction,apex,angle,height)
	radius = height*tan(angle)
	function larmodelcone0(shape = [36,1])
		cone = PointClouds.cone(radius,height)(shape)
		matrixaffine = hcat(Lar.nullspace(Matrix(direction')),direction)
		mrot = vcat(hcat(matrixaffine,[0,0,0]),[0.,0.,0.,1.]')
		return Lar.apply(Lar.t(apex...),Lar.apply(mrot,cone))
	end
	return larmodelcone0
end

"""
	larmodelcone(center,radius)(shape = [36,1])
"""
function larmodeltorus(direction,center,r0,r1)
	function larmodeltorus0(shape = [36,36])
		toro = Lar.toroidal(r0,r1)(shape)
		matrixaffine = hcat(Lar.nullspace(Matrix(direction')),direction)
		mrot = vcat(hcat(matrixaffine,[0,0,0]),[0.,0.,0.,1.]')
		return Lar.apply(Lar.t(center...),Lar.apply(mrot,toro))
	end
	return larmodeltorus0
end

################################################################################ Residual
"""
	rescyl
"""
function rescyl(point,params)
	direction,center,radius, height = params
	r2 = radius^2
	y = point-center
	rp = y'*(Matrix{Float64}(Lar.I, 3, 3)-Lar.kron(direction,direction'))*y
	return Lar.abs(rp[1]-r2)
end


"""
	ressphere
"""
function ressphere(point,center,radius)
	r2 = radius^2
	y = point-center
	rp = Lar.norm(y)^2
	return Lar.abs(rp[1]-r2)
end

"""
	rescone
"""
function rescone(point,coneVertex, coneaxis, radius, height)
	cosalpha = height/(sqrt(height^2+radius^2))
	y = point-coneVertex
	rp = y'*(Matrix{Float64}(Lar.I, 3, 3)-Lar.kron(coneaxis/cosalpha,(coneaxis/cosalpha)'))*y
	return Lar.abs(rp[1])
end

"""
	restorus
"""
function restorus(point,C, N, rM, rm)
	D =  point - C
	DdotD = Lar.dot(D,D)
	NdotD = Lar.dot(N,D)
	sum = DdotD + rM^2-rm^2
	res=sum^2 - 4*rM^2*(DdotD-NdotD^2)
	return Lar.abs(res)
end
