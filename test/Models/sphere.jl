using Random

@testset "SPHERE" begin
	@testset "Parameters of fitting sphere" begin
		Random.seed!()
		## random points on sphere
		npoints = rand(4:20)
		r = rand(1:20)
		V = Array{Float64,1}[]
		for i in 1:npoints
			p=[rand(),rand(),rand()]
			p/=Lar.norm(p)
		    push!(V, r*p)
		end

		# sphere
		V = hcat(V...)
		params = PointClouds.spherefit(V)

		@test isapprox(r,params[2],atol=1e-3)
		@test isapprox(params[1],[0,0,0],atol=1e-3)
	end

	@testset "Points residual" begin
		Random.seed!()
		## random points on sphere
		npoints = rand(4:20)
		r = rand(1:20)
		r2 = rand(1:20)
		V = Array{Float64,1}[]
		V2 = Array{Float64,1}[]
		for i in 1:npoints
			p=[rand(),rand(),rand()]
			p/=Lar.norm(p)
			push!(V, r*p)
			push!(V2, r2*p)
		end

		#first sphere
		V = hcat(V...)
		params = PointClouds.spherefit(V)
		#second sphere
		V2 = hcat(V2...)
		params2 = PointClouds.spherefit(V2)

		dist=Lar.abs(params[2]-params2[2]) #dist between first and second sphere

		# distances between points on second plane and first sphere
		res21=[PointClouds.ressphere(V2[:,i],params) for i in 1:npoints]
		# distances between points on first plane and second sphere
		res12=[PointClouds.ressphere(V[:,i],params2) for i in 1:npoints]

		@test isapprox.(res21,dist,atol=1e-3)==[1 for i in 1:npoints]
		@test isapprox.(res21,res12,atol=1e-3)==[1 for i in 1:npoints]

	end

	@testset "Points projected on sphere" begin
		Random.seed!()
		## random points on sphere
		npoints = rand(4:20)
		r = rand(1:20)
		V = Array{Float64,1}[]
		for i in 1:npoints
			p=[rand(),rand(),rand()]
			p/=Lar.norm(p)
		    push!(V, r*p)
		end

		#sphere
		V = hcat(V...)
		V=PointClouds.AlphaStructures.matrixPerturbation(V,atol=0.1)
		params = PointClouds.spherefit(V)

		PointClouds.projectpointson(V,params,"sphere") #poits projected on sphere
		res=[PointClouds.ressphere(V[:,i],params) for i in 1:npoints]
		@test isapprox.(res,0,atol=1e-3)==[1 for i in 1:npoints]
	end

	@testset "Assertion error" begin
			# few points
			P = [
				0.0 0.0
				2.0 0.0
				0.0 0.0
			];
		 	@test_throws AssertionError PointClouds.surfacefitparams(P,"sphere")

			# Aligned points
			P = [
				0.0 0.0 0.0 0.0
				2.0 1.0 3.0 5.0
				0.0 0.0 0.0 0.0
			];
		 	@test_throws AssertionError PointClouds.surfacefitparams(P,"sphere")

	end
end
