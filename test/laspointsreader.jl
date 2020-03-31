using LasIO
const tf = dirname(@__FILE__)

@testset "LOAD FILE .las" begin

	@testset "lasPoint without color" begin
		fname = joinpath(tf, "lasfile/srs.las") #"test/lasfile/srs.las"
		V,VV,rgb = PointClouds.loadlas(fname)
		@test size(V) == (3,10)
		@test isempty(rgb)
	end

	@testset "lasPoint with color" begin
		fname = joinpath(tf, "lasfile/cava.las") #"test/lasfile/cava.las"
		V,VV,rgb = PointClouds.loadlas(fname)
		@test size(V) == size(rgb)
		@test typeof(V) == Lar.Points{Float64}
		@test typeof(rgb) == Array{LasIO.FixedPointNumbers.Normed{UInt16,16},2}
		V,VV,rgb = PointClouds.loadlas(fname,fname)
		@test size(V) == (3,5278*2) == size(rgb)
	end

	@testset "more file .las" begin
		fname =  joinpath(tf, "lasfile/srs.las") #"test/lasfile/srs.las"
		V,VV,rgb =  PointClouds.loadlas(fname,fname)
		@test size(V) == (3,20)
		V,VV,rgb = PointClouds.loadlas(fname,fname,fname)
		@test size(V) == (3,30)
	end

end
