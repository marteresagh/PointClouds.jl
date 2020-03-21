# Torus fit

"""
	axisrotation(points,normals)

estimate axis rotation
"""
#this function estimates axis rotation from four sample
function axisrotation(points,normals)
	@assert size(points,2) >= 4 "axisrotation: too few points"
	n0xn1 = Lar.cross(normals[:,1],normals[:,2])
	a01 = Lar.dot(n0xn1,normals[:,3])
	b01 = Lar.dot(n0xn1,normals[:,4])
	a0 = Lar.dot(Lar.cross(points[:,3]-points[:,2],normals[:,1]),normals[:,3])
	b0 = Lar.dot(Lar.cross(points[:,4]-points[:,2],normals[:,1]),normals[:,4])
	a1 = Lar.dot(Lar.cross(points[:,1]-points[:,3],normals[:,2]),normals[:,3])
	b1 = Lar.dot(Lar.cross(points[:,1]-points[:,4],normals[:,2]),normals[:,4])
	a = Lar.dot(Lar.cross(points[:,1]-points[:,3],points[:,2]-points[:,1]),normals[:,3])
	b = Lar.dot(Lar.cross(points[:,1]-points[:,4],points[:,2]-points[:,1]),normals[:,4])
	cc = b01 / a01
	ccc = b0 - a0*cc
	c = -(b1-a1*cc)/ccc
	d = (-b + a * cc) / ccc
	p = (a0 * c + a1 + a01 * d) / (2 * a01 * c)
	q = (a + a0 * d) / (a01 * c)
	rt = p * p - q
	if rt < -1e-8
		return false
	end
	if rt < 0
		rt = 0
	end
	t1 = -p + sqrt(rt)
	t2 = -p - sqrt(rt)
	s1 = c * t1 + d
	s2 = c * t2 + d

	pos1 = points[:,1]+s1*normals[:,1]
	dir1 =  pos1 - (points[:,2]+t1*normals[:,2])
	dir1 /=Lar.norm(dir1)

	pos2 = points[:,1]+s2*normals[:,1]
	dir2 =  pos2 - (points[:,2]+t2*normals[:,2])
	dir2 /= Lar.norm(dir2)

	return (pos1,dir1),(pos2,dir2) #N,C,r0,r1
end

function spinimage(points,posdir)
	pos,dir = posdir
	out = []
	for i = 1:size(points,2)
		s = points[:,i] - pos
		spin2 = Lar.dot(s,dir)
		spin1 = Lar.norm(s-spin2*dir)
		push!(out,[spin1,spin2])
	end
	return hcat(out...)
end

function fitcircle(points)
	dim,npoints = size(points)
	@assert dim == 2 "fitcircle: dimension"
	centroid = PointClouds.centroid(points)
	M00 = 0.
	M01 = 0.
	M11 = 0.
	R=[0.,0.]
	for i in 1:npoints
		Y = points[:,i]-centroid
		Y0Y0 = Y[1]^2
		Y0Y1 = Y[1]*Y[2]
		Y1Y1 = Y[2]^2
		M00 += Y0Y0
		M01 += Y0Y1
		M11 += Y1Y1
		R += (Y0Y0+Y1Y1)*Y
	end
	R/=2
	det = M00*M11-M01^2
	if det != 0
		center=[ centroid[1]+(M11*R[1]-M01*R[2])/det,
				 centroid[2]+(M00*R[2]-M01*R[1])/det]
		rsqr = 0
		for i in 1:npoints
			delta = points[:,i]-center
			rsqr += Lar.dot(delta,delta)
		end
		rsqr /= npoints
		radius = sqrt(rsqr)

	else
		center = [0,0]
		radius = 0
	end
	return center,radius
end


function initialtorus(points,normals)
	N1, N2 = PointClouds.axisrotation(points,normals)
	pos1,dir1=N1
	pos2,dir2=N2
	spin1 = PointClouds.spinimage(points,N1)
	spin2 = PointClouds.spinimage(points,N2)
	minorcenter1, minorradius1 = PointClouds.fitcircle(spin1)
	minorcenter2, minorradius2 = PointClouds.fitcircle(spin2)
	if minorradius1 != 0.
		majorradius1 = minorcenter1[1]
		distsum1=0.
		for i=1:size(spin1,2)
			distsum1 += (Lar.norm(spin1[:,i]-minorcenter1)-minorradius1)^2
		end
	end
	if minorradius2 != 0.
		majorradius2 = minorcenter2[1]
		distsum2=0.
		for i=1:size(spin2,2)
			distsum2 += (Lar.norm(spin2[:,i]-minorcenter2)-minorradius2)^2
		end
	end

	if distsum1 < distsum2
		N = dir1
		rminor = minorradius1
		rmajor = majorradius1
		center = pos1 + minorcenter1[2]*N
	else
		N = dir2
		rminor = minorradius2
		rmajor = majorradius2
		center = pos2 + minorcenter2[2]*N
	end

	return N,center, rmajor, rminor
end


"""
	torusfit(points)

torus fit with LM algorithm to minimizer.
"""
function torusfit(points,normals)

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
	N0,C0,r00,r10 = PointClouds.initialtorus(points,normals)

	initial = ones(7)
	initial[1:3] = C0
	if Lar.abs(N0[3])<1.
		initial[4] = atan(N0[2],N0[1])
		initial[5] = acos(N0[3])
	else
		initial[4] = 0.
		initial[5] = 0.
	end
	initial[6] = r00^2
	initial[7] = r00^2-r10^2


	R1 = LsqFit.OnceDifferentiable(ft(points), jt(points), zeros(7), zeros(npoints); inplace = false)

	results = LsqFit.levenberg_marquardt(R1, initial; maxIter=1000)
	#@show LsqFit.OptimBase.converged(results)

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


"""
	larmodeltorus(center,radius)(shape = [36,1])
"""
function larmodeltorus(params)
	direction,center,r0,r1 = params
	function larmodeltorus0(shape = [36,36])
		toro = Lar.toroidal(r1,r0)(shape)
		matrixaffine = hcat(Lar.nullspace(Matrix(direction')),direction)
		mrot = vcat(hcat(matrixaffine,[0,0,0]),[0.,0.,0.,1.]')
		return Lar.apply(Lar.t(center...),Lar.apply(mrot,toro))
	end
	return larmodeltorus0
end
