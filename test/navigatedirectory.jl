
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
