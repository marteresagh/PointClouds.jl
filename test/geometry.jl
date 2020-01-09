if VERSION < VersionNumber("1.0.0")
	using Base.Test
else
	using Test
end


@testset "centroid" begin
	#TODO
end

@testset "residuals" begin
	#TODO
end

@testset "projection" begin
	#TODO
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

	 @testset "plane residual" begin
		# plane = (1., 0., 0., 0.)
		# p = [-3.;0.;0.]
	 	# @test PointClouds.resplane(p,plane) == 3.
		# p = [0.001; 0.; 0.]
		# @test PointClouds.isinplane(p,plane,0.1)
		#
		# plane = (1., 1., 1., 0.)
		# p = [1.;1.;1.]
	 	# @test isapprox(PointClouds.resplane(p,plane), sqrt(3.))
		# p = [0.5; 0.5; 0.5]
		# @test !(PointClouds.isinplane(p,plane,0.1))
	 end

	 @testset "centroid" begin
		 #TODO
	 end

end
