
function BoxCalculation(Vertices)
	Minx=minimum(Vertices[1,:])
	Maxx=maximum(Vertices[1,:])
	Miny=minimum(Vertices[2,:])
	Maxy=maximum(Vertices[2,:])
	dx=Maxx-Minx
	dy=Maxy-Miny
	Box=dx*dy
	if size(Vertices,1)==3
		Minz=minimum(Vertices[3,:])
		Maxz=maximum(Vertices[3,:])
		dz=Maxz-Minz
		Box=Box*dz
	end
	return Box
end

@testset "cone" begin
	@test BoxCalculation(PointClouds.cone(1,5,2*pi)()[1])==20
	@test BoxCalculation(PointClouds.cone(2,2,pi)()[1])==16
	@test BoxCalculation(PointClouds.cone(1,4,pi)()[1])==8

	@test size(PointClouds.cone(3.4,20,pi/7)()[1],2)==38
	@test length(PointClouds.cone(3.4,20,pi/7)()[2])==72
end
