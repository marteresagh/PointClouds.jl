################################################################################ Torus fit
#TODO: stima dei parametri iniziali ancora da migliorare


"""
	initialtorus(points)

stime dei valori iniziali.
"""
#input anche le normali
function _initialtorus(points,normals)

	return N,C,r0,r1
end


#TODO da modificare
function initialtorus(points)
	npoints=size(points,2)
	plane,C = PointClouds.planefit(points)
	N = collect(plane[1:3])

	a0 = 0.
	a1 = 0.
	a2 = 0.
	b0 = 0.
	c0 = 0.
	c1 = 0.
	c2 = 0.
	c3 = copy(npoints)

	for i in 1:npoints
		delta = C-points[:,i]
		dot = Lar.dot(N, delta)
		L = Lar.dot(delta, delta)
		L2 = L^2
		L3 = L^3
		S = 4*(L-dot^2)
		S2 = S^2
		a2 += S
		a1 += S*L
		a0 += S*L2
		b0 += S2
		c2 += L
		c1 += L2
		c0 += L3
	end

	d1 = copy(a2)
	d0 = copy(a1)

	a1*=2
	c2*=3
	c1*=3

	#invB0 = 1/b0
	e0 = a0/b0
	e1 = a1/b0
	e2 = a2/b0

	f0 = c0 - d0 * e0
    f1 = c1 - d1 * e0 - d0 * e1
    f2 = c2 - d1 * e1 - d0 * e2
    f3 = c3 - d1 * e2

	roots = Polynomials.roots(Poly([f0,f1,f2,f3]))
	@show roots

	hmin = Inf
	umin = 0.
	vmin = 0.

	for element in roots
		if imag(element) == 0.
			v = real(element)
			if v > 0.
				u = e0 + v*(e1 + v*e2)
				if u > v
					h = 0.
					for i in 1:npoints
						delta = C-points[:,i]
						dot = Lar.dot(N, delta)
						L =  Lar.dot(delta, delta)
						S = 4* (L - dot^2)
						sum = v + L
						term = sum^2 - S*u
						h+= term^2
					end
					if h<hmin
						hmin = h
						umin = u
						vmin = v
					end
				end
			end
		end
	end

	if hmin == Inf
		println("no fitting")
		return N,C,nothing,nothing
	end
	r0 = sqrt(umin)
	r1 = sqrt(umin-vmin)
	return N,C,r0,r1
end


"""
	mattorusfit(points)

codice matlab per gauss_newton minimizer per tori.
"""
function mattorusfit(points)
	a0,x0,r0,s0 = PointClouds.initialtorus(points)
	tolp=1.e-12;
	tolg=1.e-12;
  	x,y,z = PointClouds.lar2matlab(points)
	X = [x y z]
	@mput X
	@mput x0
	@mput a0
	@mput r0
	@mput s0
	@mput tolp
	@mput tolg
	mat"[x0n, an, rn, sn, d, sigmah, conv, Vx0n, Van, urn, usn, GNlog, a, R0, R] = lstorus(X,x0, a0, r0, s0, tolp, tolg)"
	@mget x0n
	@mget an
	@mget rn
	@mget sn

	return x0n, an ,rn, sn
end

"""
	torusfit(points)

torus fit with LM algorithm to minimizer.
"""
function torusfit(points)

	# [f1,f2,f3,..]
	# p = (C0,C1,C2,theta,phi,u,v)
	function ft(points)
		function ft0(p)
			csTheta = cos(p[4])
			snTheta = sin(p[4])
			csPhi = cos(p[5])
			snPhi = sin(p[5])
			C = p[1:3]
			N = [csTheta*snPhi, snTheta*snPhi, csPhi]
			u = p[6]
			v = p[7]
			fi = []
			for i in 1:size(points,2)
				D =  C - points[:,i]
				DdotD = Lar.dot(D,D)
				NdotD = Lar.dot(N,D)
				sum = DdotD + v
				push!(fi,sum^2 - 4*u*(DdotD-NdotD^2))
			end
			return fi
		end
		return ft0
	end

	#[df1/dp[1] df1/dp[2] df1/dp[3] df1/dp[4] df1/dp[5] df1/dp[6];
   	#df2/dp[1] df2/dp[2] df2/dp[3] df2/dp[4] df2/dp[5] df2/dp[6];
   	#  ...]
	function jt(points)
		function jt0(p)
			csTheta = cos(p[4])
			snTheta = sin(p[4])
			csPhi = cos(p[5])
			snPhi = sin(p[5])
			C = p[1:3]
			N = [csTheta*snPhi, snTheta*snPhi, csPhi]
			u = p[6]
			v = p[7]
			i=1
			D = C - points[:,i]
			DdotD = Lar.dot(D,D)
			NdotD = Lar.dot(N,D)
			sum = DdotD + v
			dNdTheta = [-snTheta * snPhi, csTheta * snPhi, 0.]
			dNdPhi = [ csTheta * csPhi, snTheta * csPhi, -snPhi ]
			temp = 4*sum*D-8*u*(D - NdotD*N)

			jt = hcat(temp[1],temp[2],temp[3],
						8*u*Lar.dot(dNdTheta,D),
						8*u*Lar.dot(dNdPhi,D),
						 -4*u*(DdotD-NdotD^2),
						 2*sum)

			for i = 2:size(points,2)
				D = C - points[:,i]
				DdotD = Lar.dot(D,D)
				NdotD = Lar.dot(N,D)
				sum = DdotD + v
				dNdTheta = [-snTheta * snPhi, csTheta * snPhi, 0.]
				dNdPhi = [ csTheta * csPhi, snTheta * csPhi, -snPhi ]
				temp = 4*sum*D-8*u*(D - NdotD*N)

				ji = hcat(temp[1],temp[2],temp[3],
							8*u*Lar.dot(dNdTheta,D),
							8*u*Lar.dot(dNdPhi,D),
							 -4*u*(DdotD-NdotD^2),
							 2*sum)
				jt = vcat(jt,ji)
			end
			return jt
		end
		return jt0
	end



	npoints = size(points,2)
	N0,C0,r00,r10 = PointClouds.initialtorus(points)

	initial = ones(7)

	# initial[1:3] = C0
	# if Lar.abs(N0[3])<1.
	# 	initial[4] = atan(N0[2],N0[1])
	# 	initial[5] = acos(N0[3])
	# else
	# 	initial[4] = 0.
	# 	initial[5] = 0.
	# end
	# initial[6] = r00^2
	# initial[7] = r00^2-r10^2

	R1 = LsqFit.OnceDifferentiable(ft(points), jt(points), zeros(7), zeros(npoints); inplace = false)

	results = LsqFit.levenberg_marquardt(R1, initial; maxIter=1000, show_trace=true)
	@show LsqFit.OptimBase.converged(results)

	C = LsqFit.OptimBase.minimizer(results)[1:3]
	theta = LsqFit.OptimBase.minimizer(results)[4]
	phi = LsqFit.OptimBase.minimizer(results)[5]
	csTheta = cos(theta)
	snTheta = sin(theta)
	csPhi = cos(phi)
	snPhi = sin(phi)

	N = [csTheta*snPhi, snTheta*snPhi, csPhi]
	u = LsqFit.OptimBase.minimizer(results)[6]
	v = LsqFit.OptimBase.minimizer(results)[7]
	r0 = sqrt(u)
	r1 = sqrt(u-v)


	return N,C,r0,r1
end
