function ProjectPointsOnPlane(V::Lar.Points,plane::Plane)
	return PointClouds.pointsproj(V,(plane.normal,plane.centroid))
end

"""
Shape reconstruction of an extracted region.
"""
function shapeof( planeDetected::PlaneDetected, file::String, LOD, α)
	allfile = PointClouds.filelevel(file,LOD)
	pp = planeDetected.plane
	V,VV,rgb = PointClouds.loadlas(allfile...)
	PointClouds.ProjectPointsOnPlane(V,pp)
	# rotate points on XY plane
	mrot = hcat(Lar.nullspace(Matrix(pp.normal')),pp.normal)
	W = Lar.inv(mrot)*(V)

	# alpha shape
	DT = PointClouds.delaunayMATLAB(W[[1,2],:])
	filtration = AlphaStructures.alphaFilter(W[[1,2],:], DT);
	_, _, FV = AlphaStructures.alphaSimplex(W[[1,2],:], filtration, α);
	return V, FV
end

"""
Extract boundary of flat shape.
"""
function boundaryflatshape(V, FV)
	#V,FV = shapeof( planeDetected::PlaneDetected, file::String, α)

	# extract boundary
	EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.FV2EV,FV)))))
	Mbound = Lar.u_boundary_2(FV,EV)
	ev = (Mbound'*ones(length(FV))).%2
	EV = EV[Bool.(ev)]

	return V,EV
end
