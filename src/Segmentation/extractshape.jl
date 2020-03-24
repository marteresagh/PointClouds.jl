
"""
Shape reconstruction of an extracted region.
"""
function shapeof(region, α; extractbound = false)
	shape, points, params = region
	PointClouds.projectpointson(points,params,shape)
	if shape == "plane"
		axis,centroid = params
		# rotate points on XY plane
		mrot = hcat(Lar.nullspace(Matrix(axis')),axis)
		W = Lar.inv(mrot)*(points)

		# alpha shape
		DT = PointClouds.delaunayMATLAB(W[[1,2],:])
		filtration = AlphaStructures.alphaFilter(W[[1,2],:], DT);
		_, _, FV = AlphaStructures.alphaSimplex(W[[1,2],:], filtration, α);
		return points, FV
	else
		DT = PointClouds.delaunayMATLAB(points)
	   	filtration = AlphaStructures.alphaFilter(points, DT);
	   	_, _, FV, _ = AlphaStructures.alphaSimplex(points, filtration, α)
	   return points, FV
	end
end

"""
Extract boundary of flat shape.
"""
function boundaryflatshape(region,α)
	shape, points, params = region

	@assert shape == "plane" "boundaryflatshape: is not flat region"
	axis,centroid = params
	#  projection points on plane
	PointClouds.projectpointson(points,params,shape)
	# rotate points on XY plane
	mrot = hcat(Lar.nullspace(Matrix(axis')),axis)
	W = Lar.inv(mrot)*(points)

	# triangulation
	DT = PointClouds.delaunayMATLAB( W[[1,2],:])
	filtration = AlphaStructures.alphaFilter( W[[1,2],:], DT);
	_, _, FV = AlphaStructures.alphaSimplex( W[[1,2],:], filtration, α);

	# extract boundary
	EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.FV2EV,FV)))))
	Mbound = Lar.u_boundary_2(FV,EV)
	ev = (Mbound'*ones(length(FV))).%2
	EV = EV[Bool.(ev)]

	return points,EV
end
