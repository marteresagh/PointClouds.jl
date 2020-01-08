# ```
# finalizzare la procedura
#
# """
# 	findallplane(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64,N=1::Int64)
#
# Finds `N` planes with more than `NOTPLANE` points in LAR model `(V,FV)`.
# """
# function findallplane(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64,N=1::Int64)
# 	# 1. - initialization
# 	Vremained = copy(V)
# 	FVremained = copy(FV)
# 	allplanes = [[],[]]
#
# 	i = 0 # number of plane found
#
# 	while i < N
# 		pointsonplane = nothing
# 		plane = nothing
# 		println("number of points remained: $(size(Vremained,2))")
#
# 		while isnothing(pointsonplane)
# 			pointsonplane,plane = PointClouds.planeshape(Vremained,FVremained,par,NOTPLANE)
# 		end
#
# 		i = i+1
# 		println("$i planes found")
# 		Vplane, FVplane = PointClouds.larmodelplane(pointsonplane,plane)
# 		push!(allplanes[1],Vplane)
# 		push!(allplanes[2],FVplane)
# 		Vremained,FVremained = PointClouds.modelremained(Vremained,FVremained,pointsonplane)
#
# 	end
#
# 	return allplanes,Vremained,FVremained
# end


"""
	findshape(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64)

Returns all the points `pointsonshape` liyng on the `plane` found.

"""
function findshape(V::Lar.Points,FV::Lar.Cells,par::Float64,shape::String;index=0,NOTSHAPE=10::Int64)

	# 1. list of adjacency verteces
	EV = Lar.simplexFacets(FV)
   	adj = Lar.verts2verts(EV)

	# 2. first samples
	if index==0
		index = rand(1:size(V,2))
	end
	@show index
	visitedverts = [index]
	idxneighbors = PointClouds.findnearestof([index],visitedverts,adj)
	index = union(index,idxneighbors)
	pointsonshape = V[:,index]
	if shape == "plane"
		params = PointClouds.planefit(pointsonshape)
	elseif shape == "cylinder"
		params = PointClouds.cylinderfit(pointsonshape)
	end
	visitedverts = copy(index)
	idxneighbors = PointClouds.findnearestof(index,visitedverts,adj)

	# 4. check if this neighbors are other points of plane
    while !isempty(idxneighbors)

	    for i in idxneighbors
            p = V[:,i]

			if shape == "plane"
				axis,centroid = params
				if PointClouds.isinplane(p,axis,centroid,par)
					push!(index,i)
	            end
			elseif shape == "cylinder"
				if PointClouds.isincyl(p,params,par)
					push!(index,i)
	            end
			end

            push!(visitedverts,i)

        end

		pointsonshape = V[:,index]
		if shape == "plane"
			params = PointClouds.planefit(pointsonshape)
		elseif shape == "cylinder"
			params = PointClouds.cylinderfit(pointsonshape)
		end

        idxneighbors = PointClouds.findnearestof(index,visitedverts,adj)
    end

	if size(pointsonshape,2) <= NOTSHAPE
		println("findshape: not valid")
		return nothing, nothing
	end
    return  pointsonshape,params
end


"""
	 findnearestof(indeces::Array{Int64,1},visitedvertex::Array{Int64,1},adj::Array{Array{Int64,1},1})

Returns indeces neighbors list of `indverts`, removing verteces already visited.
"""
function findnearestof(indverts::Array{Int64,1},visitedverts::Array{Int64,1},adj::Array{Array{Int64,1},1})
	return setdiff(union(adj[indverts]...),visitedverts)
end


"""
	extractionmodel(V::Lar.Points,FV::Lar.Cells,pointsonplane::Lar.Points)

model triangulate of pointonplane
"""
function extractionmodel(V::Lar.Points,FV::Lar.Cells,rgb,pointsonplane::Lar.Points)
	cscFV = Lar.characteristicMatrix(FV)
	tokeep = [PointClouds.matchcolumn(pointsonplane[:,i],V) for i in 1:size(pointsonplane,2)] # index of points to keep
	todel = setdiff(collect(1:cscFV.n), tokeep) # index of point to delete
    face = cscFV[:,tokeep]
	FVremained = [Lar.findnz(face[k,:])[1] for k=1:size(face,1) if length(Lar.findnz(face[k,:])[1])>=3] #face remained
	Vremained = V[:,tokeep] #points remained
	rgbremained = rgb[:,tokeep]
	return Vremained,FVremained,rgbremained
end

"""
	modelremained(V::Lar.Points,FV::Lar.Cells,pointsonplane::Lar.Points)

Returns LAR model remained after removing points on plane.
"""
function modelremained(V::Lar.Points,FV::Lar.Cells,rgb,pointsonplane::Lar.Points)
	cscFV = Lar.characteristicMatrix(FV)
	todel = [PointClouds.matchcolumn(pointsonplane[:,i],V) for i in 1:size(pointsonplane,2)] # index of points to delete
	tokeep = setdiff(collect(1:cscFV.n), todel) # index of point to keep
    face = cscFV[:,tokeep]
	FVremained = [Lar.findnz(face[k,:])[1] for k=1:size(face,1) if length(Lar.findnz(face[k,:])[1])>=3] #face remained
	Vremained = V[:,tokeep] #points remained
	rgbremained = rgb[:,tokeep]
	return Vremained,FVremained,rgbremained
end

"""
	extractplaneshape(P,axis,centroid,α)

"""
function extractplaneshape(P,params,α)
	axis,centroid = params
	PointClouds.pointsproj(P,axis,centroid)
	mrot = hcat(Lar.nullspace(Matrix(axis')),axis)
	W = Lar.inv(mrot)*(P)
	W1 = W[[1,2],:]
	DT = PointClouds.mat2DT(W1)
	filtration = AlphaStructures.alphaFilter(W1, DT);
	_, _, FV = AlphaStructures.alphaSimplex(W1, filtration, α);

	#convex hull
	# ch = QHull.chull(convert(Lar.Points,W1'))
	# verts = ch.vertices
	# EV = ch.simplices


	#o boundary
	EV = Lar.simplexFacets(FV)
	Mbound = Lar.u_boundary_2(FV,EV)
	ev = (Mbound'*ones(length(FV))).%2
	EV = EV[Bool.(ev)]



	return P,EV
end

"""
	extractshape(P,params,α)
"""
function extractshape(P,params,α)
	PointClouds.pointsprojcyl(P,params)
	DT = PointClouds.mat3DT(P)
	filtration = AlphaStructures.alphaFilter(P, DT);
	_, _, FP, TP = AlphaStructures.alphaSimplex(P, filtration, α)
	return P,FP
end
