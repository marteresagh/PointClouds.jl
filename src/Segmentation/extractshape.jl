"""
	extractplaneshape(P,params,α)

Return boundary of 2D α-shapes of `P` projected on plane defined by params.
"""
function extractplaneshape(P,params,α)
	axis,centroid = params

	# 1. projection points on plane
	PointClouds.pointsproj(P,params)

	# 2. rotate points on XY plane
	mrot = hcat(Lar.nullspace(Matrix(axis')),axis)
	W = Lar.inv(mrot)*(P)

	# 3. triangulation
	W1 = W[[1,2],:]
	DT = PointClouds.delaunayMATLAB(W1)
	filtration = AlphaStructures.alphaFilter(W1, DT);
	_, _, FV = AlphaStructures.alphaSimplex(W1, filtration, α);

	# 4. extract boundary
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.FV2EV,FV)))))
	Mbound = Lar.u_boundary_2(FV,EV)
	ev = (Mbound'*ones(length(FV))).%2
	EV = EV[Bool.(ev)]

	return P,EV
end


"""
	extractshape(P,params,α)

Return α-shapes of `P` projected on shape defined by params.
"""
function extractshape(P,params,α)
	PointClouds.pointsprojcyl(P,params)
	DT = PointClouds.delaunayMATLAB(P)
	filtration = AlphaStructures.alphaFilter(P, DT);
	_, _, FP, TP = AlphaStructures.alphaSimplex(P, filtration, α)
	return P,FP
end
