using Random

@testset "PLANE" begin
	@testset "Parameters of fitting plane" begin
		Random.seed!()
		## random points on plane
		npoints = 100
		xslope = rand(1:20)
		yslope = rand(1:20)
		off = rand(1:20)
		xs = rand(npoints)
		ys = rand(npoints)
		zs = Float64[]
		for i in 1:npoints
		    push!(zs, xs[i]*xslope + ys[i]*yslope + off)
		end

		#plane
		V = convert(Lar.Points, hcat(xs,ys,zs)')
		params = PointClouds.planefit(V)

		@test isapprox(Lar.abs.(params[1]./params[1][3]),Lar.abs.([xslope,yslope,1]),atol=1e-3)
		@test isapprox(Lar.abs.(Lar.dot(params[1]./params[1][3],params[2])),off,atol=1e-3)
	end


	@testset "Points residual" begin
		Random.seed!()
		## random points
		npoints = rand(3:20)
		xslope = rand(1:20); yslope = rand(1:20); off = rand(1:20);	off2 = rand(1:20)
		xs1 = rand(npoints); ys1 = rand(npoints); zs1 = Float64[]
		xs2 = rand(npoints); ys2 = rand(npoints); zs2 = Float64[]
		for i in 1:npoints
		    push!(zs1, xs1[i]*xslope + ys1[i]*yslope + off)
			push!(zs2, xs2[i]*xslope + ys2[i]*yslope + off2)
		end

		#first plane
		V = convert(Lar.Points, hcat(xs1,ys1,zs1)')
		params = PointClouds.planefit(V)
		#second plane
		V2 = convert(Lar.Points, hcat(xs2,ys2,zs2)')
		params2 = PointClouds.planefit(V2)

		c=Lar.dot(params[1],params2[2]-params[2])*params[1]+params[2] #projection centroid on other axis plane
		dist=Lar.norm(params[2]-c) #dist between first and second plane

		# distances between points on second plane and first plane
		res21=[PointClouds.resplane(V2[:,i],params) for i in 1:npoints]
		# distances between points on first plane and second plane
		res12=[PointClouds.resplane(V[:,i],params2) for i in 1:npoints]

		@test isapprox.(res21,dist,atol=1e-3)==[1 for i in 1:npoints]
		@test isapprox.(res21,res12,atol=1e-3)==[1 for i in 1:npoints]

	end


	@testset "Points projected on plane" begin
		Random.seed!()
		## random points on plane
		npoints = rand(3:20)
		xslope = rand(1:20)
		yslope = rand(1:20)
		off = rand(1:20)
		xs = rand(npoints)
		ys = rand(npoints)
		zs = Float64[]
		for i in 1:npoints
		    push!(zs, xs[i]*xslope + ys[i]*yslope + rand()*off) # points perturbation
		end

		#plane
		V = convert(Lar.Points, hcat(xs,ys,zs)')
		params = PointClouds.planefit(V)

		PointClouds.projectpointson(V,params,"plane") #poits projected on plane
		res=[PointClouds.resplane(V[:,i],params) for i in 1:npoints]
		@test isapprox.(res,0,atol=1e-3)==[1 for i in 1:npoints]
	end

	@testset "Assertion error" begin
			# few points
			P = [
				0.0 0.0
				2.0 0.0
				0.0 0.0
			];
		 	@test_throws AssertionError PointClouds.surfacefitparams(P,"plane")

			# Aligned points
			P = [
				0.0 0.0 0.0 0.0
				2.0 1.0 3.0 5.0
				0.0 0.0 0.0 0.0
			];
		 	@test_throws AssertionError PointClouds.surfacefitparams(P,"plane")

	end
end
