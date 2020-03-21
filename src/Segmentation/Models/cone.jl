#TODO da velocizzare
"""
	initialcone(points)
"""
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


"""

	conefit(points)

"""
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
	results = LsqFit.levenberg_marquardt(R1, initial)#; show_trace=true)
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


"""
	larmodelcone(center,radius)(shape = [36,1])
"""
function larmodelcone(apex,direction,angle,height)
	radius = height*tan(angle)
	function larmodelcone0(shape = [36,1])
		cone = PointClouds.cone(radius,height)(shape)
		matrixaffine = hcat(Lar.nullspace(Matrix(direction')),direction)
		mrot = vcat(hcat(matrixaffine,[0,0,0]),[0.,0.,0.,1.]')
		return Lar.apply(Lar.t(apex...),Lar.apply(mrot,cone))
	end
	return larmodelcone0
end
