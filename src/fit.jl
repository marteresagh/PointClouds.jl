# ```
# finalizzare la procedura


"""
	findallplane(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64,N=1::Int64)

Finds `N` planes with more than `NOTPLANE` points in LAR model `(V,FV)`.
"""
function findallplane(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTPLANE=3::Int64,N=1::Int64)
	# 1. - initialization
	Vremained = copy(V)
	FVremained = copy(FV)
	allplanes = [[],[]]

	i = 0 # number of plane found

	while i < N
		pointsonplane = nothing
		plane = nothing
		println("number of points remained: $(size(Vremained,2))")

		while isnothing(pointsonplane)
			pointsonplane,plane = Tesi.planeshape(Vremained,FVremained,par,NOTPLANE)
		end

		i = i+1
		println("$i planes found")
		Vplane, FVplane = Tesi.larmodelplane(pointsonplane,plane)
		push!(allplanes[1],Vplane)
		push!(allplanes[2],FVplane)
		Vremained,FVremained = Tesi.modelremained(Vremained,FVremained,pointsonplane)

	end

	return allplanes,Vremained,FVremained
end

"""
	 findnearestof(indeces::Array{Int64,1},visitedvertex::Array{Int64,1},adj::Array{Array{Int64,1},1})

Returns indeces neighbors list of `indverts`, removing verteces already visited.
"""
function findnearestof(indverts::Array{Int64,1},visitedverts::Array{Int64,1},adj::Array{Array{Int64,1},1})
	return setdiff(union(adj[indverts]...),visitedverts)
end


"""
	projection(e,v)
e è la normale della superficie e v è il punto da proiettare
"""
#TODO ad esempio sul cilindro come faccio a proiettare v sulla superficie?? quale normale uso??
function projection(e,v)
	p = v-Lar.dot(e,v)*e
	return p
end

"""
	proiezione di tutti i punti sul piano ortogonale a N
"""
function pointsproj(V,N,C)
	npoints = size(V,2)
	for i in 1:npoints
		V[:,i] = Tesi.projection(N,V[:,i]-C) + C
	end
	return convert(Lar.Points,V)
end

"""
	proiezione di tutti i punti sul cilindro
"""
function pointsprojcyl(V,axis,C,r)
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-C
		c0 = Lar.dot(axis,p)*(axis)
		N = (p-c0)/Lar.norm(p-c0)
		c=r*N
		V[:,i] = Tesi.projection(N,p-c) + c + C
	end
	return convert(Lar.Points,V)
end



"""
	proiezione di tutti i punti sulla sfera
"""
function pointsprojsphere(V,C,r)
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-C
		N = p/Lar.norm(p)
		c = r*N
		V[:,i] = Tesi.projection(N,p-c) + c + C
	end
	return convert(Lar.Points,V)
end


#TODO
"""
	proiezione di tutti i punti sul cono
"""
function pointsprojcone(V,axis,apex,angle)
	npoints = size(V,2)
	for i in 1:npoints
		p = V[:,i]-apex
		c0 = Lar.dot(axis,p)*(axis)
		N = (p-c0)/Lar.norm(p-c0)
		c=Lar.dot(axis,c0)*tan(angle)*N
		V[:,i] = Tesi.projection(N,p-c) + c + apex
	end
	return convert(Lar.Points,V)
end


"""
	extractionmodel(V::Lar.Points,FV::Lar.Cells,pointsonplane::Lar.Points)

model triangulate of pointonplane
"""
function extractionmodel(V::Lar.Points,FV::Lar.Cells,rgb,pointsonplane::Lar.Points)
	cscFV = Lar.characteristicMatrix(FV)
	tokeep = [Tesi.matchcolumn(pointsonplane[:,i],V) for i in 1:size(pointsonplane,2)] # index of points to keep
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
	todel = [Tesi.matchcolumn(pointsonplane[:,i],V) for i in 1:size(pointsonplane,2)] # index of points to delete
	tokeep = setdiff(collect(1:cscFV.n), todel) # index of point to keep
    face = cscFV[:,tokeep]
	FVremained = [Lar.findnz(face[k,:])[1] for k=1:size(face,1) if length(Lar.findnz(face[k,:])[1])>=3] #face remained
	Vremained = V[:,tokeep] #points remained
	rgbremained = rgb[:,tokeep]
	return Vremained,FVremained,rgbremained
end
