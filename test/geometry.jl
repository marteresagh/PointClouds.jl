if VERSION < VersionNumber("1.0.0")
	using Base.Test
else
	using Test
end


@testset "centroid" begin
	V,CV = Lar.cuboid([1,1])
	@test PointClouds.centroid(V)==hcat([0.5;0.5])
	V,CV = Lar.cuboid([1,1,1])
	@test PointClouds.centroid(V)==hcat([0.5;0.5;0.5])
end

@testset "residuals" begin
	@testset "plane" begin
		params=([0.,0.,1.],[0.,0.,0.])
		V=[0. 1. 2.; 0. 3. 4.; 5. 3. 6.]
		@test PointClouds.resplane(V[:,1],params)==5.
		@test PointClouds.resplane(V[:,2],params)==3.
		@test PointClouds.resplane(V[:,3],params)==6.
	end

	@testset "cylinder" begin
		direction = [0.,0.,1.]
		center = [0.,0.,0.]
		radius = 3.
		height = 2.
		params = (direction,center,radius, height)
		V = [5. 3. 2.; 7. 0. 4.; 8. 0. 6.]
		@test PointClouds.rescyl(V[:,1],params)==65.
		@test PointClouds.rescyl(V[:,2],params)==0.
		@test PointClouds.rescyl(V[:,3],params)==11.
	end

	@testset "sphere" begin
		params = ([1.,0.,0.],3.)
		V = [4. 5. 2.; 0. 0. 4.; 0. 0. 6.]
		@test PointClouds.ressphere(V[:,1],params)==0.
		@test PointClouds.ressphere(V[:,2],params)==7.
		@test PointClouds.ressphere(V[:,3],params)==44.
	end

	@testset "cones" begin
		#TODO
	end

	@testset "torus" begin
		#TODO
	end

end

@testset "projection" begin
	@testset "plane" begin
		npoints = 200
		xslope = 1.
		yslope = 0.
		off = 5.

		# generation random data
		xs = rand(npoints)
		ys = rand(npoints)
		zs = []

		for i in 1:npoints
		    push!(zs, xs[i]*xslope + ys[i]*yslope + off)
		end

		V = convert(Lar.Points, hcat(xs,ys,zs)')

		params=PointClouds.planefit(V)
		res = max([PointClouds.resplane(V[:,i],params) for i in 1:size(V,2)]...)
		#@test isapprox(res, 0, atol=1e-3)
	end

	@testset "cylinder" begin
		C=[1.,2.,1.]
		r=5.
		V,FV = Lar.apply(Lar.t(C...),Lar.sphere(r)([16,16]))
		params=(C,r)
		res = max([PointClouds.ressphere(V[:,i],params) for i in 1:size(V,2)]...)
		@test isapprox(res, 0, atol=1e-3)
	end

	@testset "sphere" begin
		C=[1.,2.,1.]
		r=5.
		V,FV = Lar.apply(Lar.t(C...),Lar.sphere(r)([16,16]))
		params=(C,r)
		res = max([PointClouds.ressphere(V[:,i],params) for i in 1:size(V,2)]...)
		@test isapprox(res, 0, atol=1e-3)
	end

	@testset "cones" begin
		#TODO
	end

	@testset "torus" begin
		#TODO
	end
end


@testset "utilities" begin

	@testset "matchcolumn" begin
		a = [1,2,3]
		c = [2,3,7]
		B = [1 4 5; 2 7 8; 3 5 9]
		@test PointClouds.matchcolumn(a,B) == 1
		@test PointClouds.matchcolumn(c,B) == nothing
	 end

	 @testset "findnearestof" begin
	 	adj = [[2,8],[1,3,4,8],[1,2,4,5,6],[2,3,5,8],[3,4,6,7],[3,5,7],[5,6],[1,2,4]]
		indverts = [3,4]
		visitedverts = [1,2,3,4]
		@test PointClouds.findnearestof(indverts,visitedverts,adj) == [5,6,8]

		indverts = [7]
		visitedverts = [7,5,6]
		@test isempty(PointClouds.findnearestof(indverts,visitedverts,adj))
	 end

end
