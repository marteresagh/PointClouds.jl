if VERSION < VersionNumber("1.0.0")
	using Base.Test
else
	using Test
end


function random3cells(shape,npoints)
	pointcloud = rand(3,npoints).*shape
	grid = DataStructures.DefaultDict{Array{Int,1},Int}(0)

	for k = 1:size(pointcloud,2)
		v = map(Int∘trunc,pointcloud[:,k])
		if grid[v] == 0 # do not exists
			grid[v] = 1
		else
			grid[v] += 1
		end
	end

	out = Array{Lar.Struct,1}()
	for (k,v) in grid
		V = k .+ [
		 0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0;
		 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0;
		 0.0  1.0  0.0  1.0  0.0  1.0  0.0  1.0]
		cell = (V,[[1,2,3,4,5,6,7,8]])
		push!(out, Lar.Struct([cell]))
	end
	out = Lar.Struct( out )
	V,CV = Lar.struct2lar(out)
	return pointcloud,V,CV
end


@testset "extraction model" begin
	V,CV = Lar.cuboidGrid([2,1,1])
	FV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.CV2FV,CV)))))
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.CV2EV,CV)))))
	@test length(FV)==11
	@test length(EV)==20
	V,FVouter = PointClouds.extractsurfaceboundary(V,CV)
	@test length(FVouter)==10

	V,CV = Lar.cuboidGrid([5,3,2])
	FV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.CV2FV,CV)))))
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.CV2EV,CV)))))
	@test length(FV)==121
	@test length(EV)==162
	V,FVouter = PointClouds.extractsurfaceboundary(V,CV)
	@test length(FVouter)==62

end

@testset "sparse matrix" begin
	pointcloud,V,CV = random3cells([40,12,5],400)
	VV = [[v] for v=1:size(V,2)]
	FV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.CV2FV,CV)))))
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.CV2EV,CV)))))
	nV = size(V,2)
	nEV = length(EV)
	nFV = length(FV)
	nCV = length(CV)

	@test PointClouds.K(VV) == Matrix(Lar.I,nV,nV)
	@test size(PointClouds.K(EV)) == (nEV,nV)
	@test size(PointClouds.K(FV)) == (nFV,nV)
	@test size(PointClouds.K(CV)) == (nCV,nV)
end
