
"""
	loadlas(fname::String...)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read more than one file `.las` and extrapolate the LAR model and the color of each point.

"""
function loadlas(fname::String...)::Tuple{Lar.Points,Array{Array{Int64,1},1},Array{LasIO.N0f16,2}}
	Vtot = Array{Float64,2}(undef, 3, 0)
	rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
	for name in fname
		V,VV = PointClouds.las2lar(name)
		rgb = PointClouds.lascolor(name)
		Vtot = hcat(Vtot,V)
		rgbtot = hcat(rgbtot,rgb)
	end
	return Vtot,[[i] for i in 1:size(Vtot,2)],rgbtot
end

"""
	las2lar(fname::String)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read data from a file `.las`:
- generate the LAR model `(V,VV)`
- extrapolate color associated to each point
"""
function las2lar(fname::String)::Tuple{Lar.Points,Array{Array{Int64,1},1}}
	header, laspoints = LasIO.FileIO.load(fname)
	npoints = length(laspoints)
	x = [LasIO.xcoord(laspoints[k], header) for k in 1:npoints]
	y = [LasIO.ycoord(laspoints[k], header) for k in 1:npoints]
	z = [LasIO.zcoord(laspoints[k], header) for k in 1:npoints]
	return vcat(x',y',z'), [[i] for i in 1:npoints]
end

"""
	las2aabb(fname::String)

Return the AABB of the file `fname`.

"""
function las2aabb(fname::String)
	header,p = LasIO.FileIO.load(fname)
	#header = read(fname, LasIO.LasHeader)
	AABB = LasIO.boundingbox(header)
	return reshape([AABB.xmin;AABB.ymin;AABB.zmin],(3,1)),reshape([AABB.xmax;AABB.ymax;AABB.zmax],(3,1))
end


"""
	lascolor(fname::String)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read data from a file `.las`:
- extrapolate color associated to each point.
"""
function lascolor(fname::String)::Array{LasIO.N0f16,2}
	header, laspoints = LasIO.FileIO.load(fname)
	npoints = length(laspoints)
	type = LasIO.pointformat(header)
	if type != LasPoint0 && type != LasPoint1
		r = LasIO.ColorTypes.red.(laspoints)
		g = LasIO.ColorTypes.green.(laspoints)
		b = LasIO.ColorTypes.blue.(laspoints)
		return vcat(r',g',b')
	end
	return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end
