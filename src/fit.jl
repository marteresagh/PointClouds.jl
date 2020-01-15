# ```
# finalizzare la procedura
#
"""
	findall(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64,N=1::Int64)


"""
function findall(V::Lar.Points,FV::Lar.Cells,Vrgb,N::Int,par::Float64,shape::String;index=0,NOTSHAPE=10::Int64,min=[0.,0.,0.],max=[1.,1.,1.])

	println("-----------------")
	println("find $N shapes")
	println("-----------------")


	# 1. - initialization
	Vcurrent = copy(V)
	FVcurrent = copy(FV)
	RGBcurrent = copy(Vrgb)
	allshapes = []

	i = 0 # number of plane found

	while i < N
		pointsonshape = nothing
		params = nothing
		println("number of points remained: $(size(Vcurrent,2))")

		while isnothing(pointsonshape)
			pointsonshape,params = PointClouds.findshape(Vcurrent,FVcurrent,RGBcurrent,par,shape;index=index,NOTSHAPE=NOTSHAPE::Int64,min=min,max=max)
		end

		i = i+1
		println("$i shapes found")
		push!(allshapes,[pointsonshape,params])
		Vcurrent,FVcurrent,RGBcurrent = PointClouds.deletepoints(Vcurrent,FVcurrent,RGBcurrent,pointsonshape)

	end

	return Vcurrent, FVcurrent,RGBcurrent,allshapes
end


"""
	findshape(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64)

Returns all the points `pointsonshape` liyng on the `plane` found.

"""
function findshape(V::Lar.Points,FV::Lar.Cells,Vrgb,par::Float64,shape::String;index=0,NOTSHAPE=10::Int64,min=[0.,0.,0.],max=[1.,1.,1.])

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
	# if punti allineati ??
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
				color = Vrgb[:,i]
				if PointClouds.isinplane(p,params,par) && PointClouds.testcolor(color,min,max)
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
		#println("findshape: not valid")
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
	deletepoints(V::Lar.Points,FV::Lar.Cells,pointsonplane::Lar.Points)

Returns LAR model remained after removing points on plane.
"""
function deletepoints(V::Lar.Points,FV::Lar.Cells,rgb,pointsonplane::Lar.Points)
	npoints=size(V,2)
	cscFV = Lar.characteristicMatrix(FV)
	todel = [PointClouds.matchcolumn(pointsonplane[:,i],V) for i in 1:size(pointsonplane,2)] # index of points to delete
	tokeep = setdiff(collect(1:cscFV.n), todel)
    cscFV0 = cscFV[:,tokeep]

	faceind = 1:cscFV0.m
	vertinds = 1:npoints
    keepface = Array{Int64, 1}()
	for i in faceind
    	if length(cscFV0[i, :].nzind) == 3
           push!(keepface, i)
       end
    end
   	cscFV=cscFV[keepface,:]
	isolatedpoints=Array{Int64, 1}()
	for i in vertinds
    	if length(cscFV[:, i].nzind) == 0
           push!(isolatedpoints, i)
       end
    end

   	union!(todel,isolatedpoints)
	tokeep = setdiff(vertinds, todel)

    FVremained = Lar.cop2lar(cscFV[:, tokeep])
    Vremained = V[:, tokeep]
	rgbremained = rgb[:,tokeep]

	return Vremained,FVremained,rgbremained
end
"""
	extractplaneshape(P,axis,centroid,α)

"""
function extractplaneshape(P,params,α)
	axis,centroid = params
	PointClouds.pointsproj(P,params)
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


"""
	filterbycolor(P,Prgb,min,max)


"""
function filterbycolor(P,Prgb,min,max)
    tokeep=[]
    for i in 1:size(Prgb,2)
        color = Prgb[:,i]
		if PointClouds.testcolor(color,min,max)
            push!(tokeep,i)
        end
    end
    return P[:,tokeep], Prgb[:,tokeep]
end


function testcolor(color,min,max)
	testmin = (color[1]>=min[1] && color[2]>=min[2] && color[3]>=min[3])
	testmax = (color[1]<=max[1] && color[2]<=max[2] && color[3]<=max[3])
	return testmin && testmax
end
