#TODO
# sistemare codice,
# rendere incrementale

# ```
# finalizzare la procedura
#
"""
	findall(V::Lar.Points,FV::Lar.Cells,Vrgb,
			N::Int,par::Float64,shape::String;
			NOTSHAPE=10::Int64,min=[0.,0.,0.],max=[1.,1.,1.])

Find `N` defined shapes in colored LAR model `(V,FV)`.
Discard shapes with `NOTSHAPE` number of points.
min max interval-> filter by color

"""
function findall(V::Lar.Points,FV::Lar.Cells,Vrgb,
	N::Int,par::Float64,shape::String;NOTSHAPE=10::Int64,min=[0.,0.,0.],max=[1.,1.,1.])

	println("-----------------")
	println("find $N shapes")
	println("-----------------")


	# 1. - initialization
	Vcurrent = copy(V)
	FVcurrent = copy(FV)
	RGBcurrent = copy(Vrgb)
	allshapes = []

	i = 0

	# 2. find N shapes
	while i < N
		pointsonshape = nothing
		params = nothing
		println("number of points remained: $(size(Vcurrent,2))")

		while isnothing(pointsonshape)
			pointsonshape,params = PointClouds.findshape(Vcurrent,FVcurrent,RGBcurrent,par,shape;NOTSHAPE=NOTSHAPE::Int64,min=min,max=max)
		end

		i = i+1
		println("$i shapes found")
		push!(allshapes,[pointsonshape,params])

		#3. remained model and repeat
		Vcurrent,FVcurrent,RGBcurrent = PointClouds.deletepoints(Vcurrent,FVcurrent,RGBcurrent,pointsonshape)

	end

	return Vcurrent, FVcurrent,RGBcurrent,allshapes
end


"""
	findshape(V::Lar.Points,FV::Lar.Cells,Vrgb,
				par::Float64,shape::String;
				index=0,NOTSHAPE=10::Int64,min=[0.,0.,0.],max=[1.,1.,1.])

Return all the points liyng on the shape found.

Option shape: (da finire con le altre forme)
- plane
- cylinder

min max interval-> filter by color

#TODO stackoverflowerror quando cicla tante volte. da risolvere
"""
function findshape(V::Lar.Points,FV::Lar.Cells,Vrgb,
		par::Float64,shape::String;
		index=0,NOTSHAPE=10::Int64,min=[0.,0.,0.],max=[1.,1.,1.])

	# 1. list of adjacency verteces
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.FV2EV,FV)))))
   	adj = Lar.verts2verts(EV)

	# 2. first samples #TODO implementare la nuova versione per la ricerca del primo seed point
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
	elseif shape == "sphere"
		params = PointClouds.spherefit(pointsonshape)
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
			elseif shape == "sphere"
				if PointClouds.isinsphere(p,params,par)
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
		elseif shape == "sphere"
			params = PointClouds.spherefit(pointsonshape)
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

Return indeces neighbors list of `indverts`, removing verteces already visited.
"""
function findnearestof(indverts::Array{Int64,1},visitedverts::Array{Int64,1},adj::Array{Array{Int64,1},1})
	return setdiff(union(adj[indverts]...),visitedverts)
end


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

	#convex hull
	# ch = QHull.chull(convert(Lar.Points,W1'))
	# verts = ch.vertices
	# EV = ch.simplices

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


"""
	filterbycolor(P,Prgb,min,max)

Filter points by color.
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
