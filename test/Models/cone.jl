using Random
# V=Array{Float64,1}[]
# #theta=rand()*2*pi
# for i in 1:npoints
# 	theta=rand()*2*pi
# 	v=rand()
# 	P=[v/H*R*cos(theta);v/H*R*sin(theta);v]
# 	push!(V,P)
# end
# V=hcat(V...)
@testset "CONE" begin
	@testset "Parameters of fitting cone" begin
		Random.seed!()
		# random points on cone
		s = rand(20:40)
		H=rand(4:30)
		R=rand(1:20)
		V,_=PointClouds.cone(R,H)([s,s])
		# cone
		params = PointClouds.conefit(V)
		@test isapprox(params[4]*tan(params[3]),R,atol=1)
		@test isapprox(H,params[4],atol=1e-3)
	end


	@testset "Points projected on cone" begin
		Random.seed!()
		# random points on cone
		s = rand(20:40)
		H=rand(4:30)
		R=rand(1:20)
		V,_=PointClouds.cone(R,H)([s,s])
		params = PointClouds.conefit(V)

		V=PointClouds.AlphaStructures.matrixPerturbation(V,atol=0.1)
		npoints=size(V,2)
		PointClouds.projectpointson(V,params,"cone") #poits projected on cone
		res=[PointClouds.rescone(V[:,i],params) for i in 1:npoints]
		@test isapprox.(res[2:end],0,atol=1e-3)==[1 for i in 2:npoints]
	end

	@testset "Assertion error" begin
		# few points
		P = [
			0.0 0.0
			2.0 0.0
			0.0 0.0
		];
	 	@test_throws AssertionError PointClouds.surfacefitparams(P,"cone")

		# random aligned points
		V=Array{Float64,1}[]
		a=rand(1:4)
		b=rand(1:4)
		c=rand(1:4)
		for i in 1:30
			t=rand()
			p=t.+(1-t)*[a,b,c]
			push!(V,p)
	 	end
		P=hcat(V...)
	 	@test_throws AssertionError PointClouds.surfacefitparams(P,"cone")

	end
end
