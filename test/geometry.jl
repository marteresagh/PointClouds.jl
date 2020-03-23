
@testset "GEOMETRY" begin

	@testset "centroid" begin
		V,CV = Lar.cuboid([1,1])
		@test PointClouds.centroid(V)==hcat([0.5;0.5])
		V,CV = Lar.cuboid([1,1,1])
		@test PointClouds.centroid(V)==hcat([0.5;0.5;0.5])
	end

	@testset "AABB detection" begin
		A = ([0.,0.,0.],[1.,1.,1.])

		B = ([0.5,0.5,0.5],[1.5,1.5,1.5])
		@test PointClouds.AABBdetection(A,B)

		B = ([0.,0.,0.],[1.,1.,1.])
		@test PointClouds.AABBdetection(A,B)

		B = ([0.2,0.2,0.2],[0.6,0.6,0.6])
		@test PointClouds.AABBdetection(A,B)

		B = ([1.,1.,1.],[2.,2.,2.])
		@test !PointClouds.AABBdetection(A,B)

		B = ([1.5,1.5,1.5],[2.5,2.5,2.5])
		@test !PointClouds.AABBdetection(A,B)

	end

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
