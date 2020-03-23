using Random

@testset "TORUS" begin
	@testset "Parameters of fitting torus" begin
		Random.seed!()
		# random points on cone
		s = rand(10:20)
		r=rand(4:8)
		R=rand(9:20)
		V,CV=Lar.toroidal(r,R)([s,s])
		# cone
		normals = PointClouds.computenormals(V,CV)
		params = PointClouds.torusfit(V,normals)

		@test isapprox(R,params[3],atol=1)
		@test isapprox(r,params[4],atol=1)
	end

	@testset "Points residual" begin
		Random.seed!()
		# random points on cone
		s = rand(20:40)
		r=rand(4:8)
		r2=rand(4:8)
		R=rand(9:20)
		V,_=Lar.toroidal(r,R)([s,s])
		V2,_=Lar.toroidal(r2,R)([s,s])
		# first torus
		params = ([0,0,1],[0,0,0],R,r)
		# second torus
		params2 = ([0,0,1],[0,0,0],R,r2)

		dist = Lar.abs(params[4]-params2[4]) #dist between first and second torus
		npoints = size(V,2)
		# distances between points on second plane and first torus
		res21=[PointClouds.restorus(V2[:,i],params) for i in 1:npoints]
		# distances between points on first plane and second torus
		res12=[PointClouds.restorus(V[:,i],params2) for i in 1:npoints]

		@test isapprox.(res21,dist,atol=1e-3)==[1 for i in 1:npoints]
		@test isapprox.(res21,res12,atol=1e-3)==[1 for i in 1:npoints]

	end

	@testset "Points projected on torus" begin
		s = rand(20:40)
		r = rand(4:8)
		r2 = rand(4:8)
		R = rand(9:20)
		#torus
		V,_ = Lar.toroidal(r,R)([s,s])
		params = ([0,0,1],[0,0,0],R,r)

		npoints = size(V,2)
		V = PointClouds.AlphaStructures.matrixPerturbation(V,atol=0.1)
		PointClouds.projectpointson(V,params,"torus") #poits projected on torus
		res = [PointClouds.restorus(V[:,i],params) for i in 1:npoints]
		@test isapprox.(res,0,atol=1e-3)==[1 for i in 1:npoints]
	end
end
