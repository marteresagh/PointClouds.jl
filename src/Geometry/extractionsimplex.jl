function FV2EV( v )
	edges = [
		[v[1], v[2]], [v[1], v[3]], [v[2], v[3]]]
end

function CV2FV( v )
	faces = [
		[v[1], v[2], v[3], v[4]], [v[5], v[6], v[7], v[8]],
		[v[1], v[2], v[5], v[6]], [v[3], v[4], v[7], v[8]],
		[v[1], v[3], v[5], v[7]], [v[2], v[4], v[6], v[8]]]
end

function CV2EV( v )
	edges = [
		[v[1], v[2]], [v[3], v[4]], [v[5], v[6]], [v[7], v[8]], [v[1], v[3]], [v[2], v[4]],
		[v[5], v[7]], [v[6], v[8]], [v[1], v[5]], [v[2], v[6]], [v[3], v[7]], [v[4], v[8]]]
end


"""
	extractionmodel(V::Lar.Points,FV::Lar.Cells,rgb,points::Lar.Points)

Return subset model of (V,FV) filter by `points`.
"""
function extractionmodel(V::Lar.Points,FV::Lar.Cells,rgb,points::Lar.Points)
	cscFV = Lar.characteristicMatrix(FV)
	tokeep = [PointClouds.matchcolumn(points[:,i],V) for i in 1:size(points,2)] # index of points to keep
	todel = setdiff(collect(1:cscFV.n), tokeep) # index of point to delete
    face = cscFV[:,tokeep]
	FVremained = [Lar.findnz(face[k,:])[1] for k=1:size(face,1) if length(Lar.findnz(face[k,:])[1])>=3] #face remained
	Vremained = V[:,tokeep] #points remained
	rgbremained = rgb[:,tokeep]
	return Vremained,FVremained,rgbremained
end

"""
	deletepoints(V::Lar.Points,FV::Lar.Cells,points::Lar.Points)

Return LAR remained model after removing points.
"""
function deletepoints(V::Lar.Points,FV::Lar.Cells,rgb,points::Lar.Points)
	npoints=size(V,2)
	cscFV = Lar.characteristicMatrix(FV)
	todel = [PointClouds.matchcolumn(points[:,i],V) for i in 1:size(points,2)] # index of points to delete
	tokeep = setdiff(collect(1:cscFV.n), todel)
    cscFV0 = cscFV[:,tokeep]

	faceind = 1:cscFV0.m
	vertinds = 1:cscFV.n
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

    Vremained = V[:, tokeep]
	FVremained = Lar.cop2lar(cscFV[:, tokeep])
	rgbremained = rgb[:,tokeep]

	return Vremained,FVremained,rgbremained
end
