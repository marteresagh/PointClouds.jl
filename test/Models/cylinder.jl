using Random

@testset "CYLINDER" begin
	@testset "Parameters of fitting cylinder" begin
		Random.seed!()
		## random points on cylinder
		npoints = rand(5:20)
		H=rand(4:30)
		R=rand(1:20)
		V = Array{Float64,1}[]
		#theta = random.random()*2*math.pi
		for i in 1:npoints
    		theta = rand()*2*pi
		    z = rand()*H
		    x = R*cos(theta)
		    y = R*sin(theta)
			push!(V,[x,y,z])
		end

		# cylinder
		V = hcat(V...)
		params = PointClouds.cylinderfit(V)

		@test isapprox(R,params[3],atol=1e-3)
		@test params[4]<=H
	end


	@testset "Points residual" begin
		Random.seed!()
		## random points on cylinder
		npoints = rand(5:20)
		H=rand(4:30)
		R=rand(1:20)
		R2=rand(1:20)
		V = Array{Float64,1}[]
		V2 = Array{Float64,1}[]
		#theta = random.random()*2*math.pi
		for i in 1:npoints
    		theta = rand()*2*pi
		    z = rand()*H
		    x = R*cos(theta)
		    y = R*sin(theta)
			x2 = R2*cos(theta)
		    y2 = R2*sin(theta)
			push!(V,[x,y,z])
			push!(V2,[x2,y2,z])
		end

		#first cylinder
		V = hcat(V...)
		params = PointClouds.cylinderfit(V)
		#second cylinder
		V2 = hcat(V2...)
		params2 = PointClouds.cylinderfit(V2)

		dist=Lar.abs(params[3]-params2[3]) #dist between first and second cylinder

		# distances between points on second plane and first cylinder
		res21=[PointClouds.rescyl(V2[:,i],params) for i in 1:npoints]
		# distances between points on first plane and second cylinder
		res12=[PointClouds.rescyl(V[:,i],params2) for i in 1:npoints]

		@test isapprox.(res21,dist,atol=1e-3)==[1 for i in 1:npoints]
		@test isapprox.(res21,res12,atol=1e-3)==[1 for i in 1:npoints]

	end


	@testset "Points projected on cylinder" begin
		Random.seed!()
		## random points on cylinder
		npoints = rand(5:20)
		H=rand(4:30)
		R=rand(1:20)
		V = Array{Float64,1}[]
		#theta = random.random()*2*math.pi
		for i in 1:npoints
			theta = rand()*2*pi
			z = rand()*H
			x = R*cos(theta)
			y = R*sin(theta)
			push!(V,[x,y,z])
		end

		#cylinder
		V = hcat(V...)
		params = PointClouds.cylinderfit(V)

		PointClouds.projectpointson(V,params,"cylinder") #poits projected on cylinder
		res=[PointClouds.rescyl(V[:,i],params) for i in 1:npoints]
		@test isapprox.(res,0,atol=1e-3)==[1 for i in 1:npoints]
	end

	@testset "Assertion error" begin
		# few points
		P = [
			0.0 0.0
			2.0 0.0
			0.0 0.0
		];
	 	@test_throws AssertionError PointClouds.surfacefitparams(P,"cylinder")

		# random aligned points
		V=Array{Float64,1}[]
		for i in 1:30
			t=rand()
			p=t.+(1-t)*[rand(1:4),rand(1:4),rand(1:4)]
			push!(V,p)
	 	end
		P=hcat(V...)
	 	@test_throws AssertionError PointClouds.surfacefitparams(P,"cylinder")

	end
end
