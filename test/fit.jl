
#  #TODO da rivedere e concludere
# @testset "plane fit" begin
#
# 	@testset "plane through not aligned three points " begin
# 		pointsonplane = [0. 1. 0.; 0. 0. 1.; 0. 0. 0.]
# 		params = PointClouds.planefit(pointsonplane)
# 		@test plane == (1.,1.,1.,2.)
#
# 		pointsonplane = [2. 0. 0. 2.; 0. 2. 0. -2.; 0. 0. 2. 2.]
# 		plane1 = PointClouds.planefit(pointsonplane)
# 		@test plane1 == (1.,1.,1.,2.)
#
# 		pointsonplane = [-2. 2. 0.; 0. 0. 2. ; 0. 0. 0.]
# 		plane = PointClouds.planefit(pointsonplane)
# 		@test plane == (0.,0.,1.,0.)
# 	end
#
# 	@testset "fitting plane" begin
# 		npoints = 100
# 		xslope = 1
# 	   	off = 5
# 	   	xs = rand(npoints)
# 	   	ys = rand(npoints)
# 	   	zs = []
# 	   	for i in 1:npoints
# 	       	push!(zs,xs[i]*xslope +
# 	                 off+rand())
# 	   	end
# 	   	V = convert(Lar.Points,hcat(xs,ys,zs)')
# 		@test PointClouds.planefit(V)[1] == 1.
# 	end
#
# 	@testset "plane" begin
# 		V = [0.5 1. 2. 2.5 3. 4. 5. 2.; 0.001 0.001 0.003 -0.001 -0.001 -0.003 0. 2.; 1. 2. 0.5 5. 4. 1. 2. 5.]
# 		FV = [[1,2,3],[1,2,8],[2,3,4],[2,4,8],[3,4,5],[3,5,6],[5,6,7]]
# 		pointsonplane,plane = PointClouds.planeshape(V,FV,0.02,3)
# 		@test size(pointsonplane,2) == 7 || size(pointsonplane,2) == 4
# 		Vplane,FVplane = PointClouds.larmodelplane(pointsonplane,plane)
# 		@test size(Vplane,2) == 4 || size(Vplane,2) == 5
# 		@test length(FVplane) == 2 || length(FVplane) == 3
#
# 		pointsonplane,plane = PointClouds.planeshape(V,FV,0.02,10)
# 		@test pointsonplane == nothing
# 	end
#
# 	@testset "model remained" begin
# 		V = [0.5 1. 2. 2.5 3. 4. 5. 2.; 0.001 0.001 0.003 -0.001 -0.001 -0.003 0. 2.; 1. 2. 0.5 5. 4. 1. 2. 5.]
# 		FV = [[1,2,3],[1,2,8],[2,3,4],[2,4,8],[3,4,5],[3,5,6],[5,6,7]]
# 		Vremained,FVremained = PointClouds.modelremained(V,FV,V[:,[1,2]])
# 		@test size(Vremained,2) == 6
# 		@test FVremained == [[1,2,3],[1,3,4],[3,4,5]]
# 		Vremained,FVremained = PointClouds.modelremained(V,FV,V[:,[1:7...]])
# 		@test size(Vremained,2) == 1
# 		@test isempty(FVremained)
# 	end
#
# end
#
# @testset "quadric fit" begin
#
# 	@testset "sphere fit" begin
# 		c = [2.,5.,3.]
# 		r = 1.
# 		V,FV = Lar.apply(Lar.t(c...),Lar.sphere(r)([10,10]))
# 		center, radius = PointClouds.spherefit(V)
# 		@test isapprox(center,c)
# 		@test isapprox(radius,r,atol = 1.e-3)
#
# 		c = [-2.,15.,-3.]
# 		r = 1.4
# 		V,FV = Lar.apply(Lar.t(c...),Lar.sphere(r)([20,20]))
# 		center, radius = PointClouds.spherefit(V)
# 		@test isapprox(center,c)
# 		@test isapprox(radius,r,atol = 1.e-3)
# 	end
#
# end
