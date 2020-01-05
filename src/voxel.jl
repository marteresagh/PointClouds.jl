
function voxeldict(V,p)
	npoints = size(V,2)
	dict = DataStructures.SortedDict{Array{Int64,1},Int64}()
	for i in 1:npoints
		point = V[:,i]
		coord =  floor.(Int,point/p)
		if haskey(dict,coord)
			dict[coord]+=1
		else
			dict[coord]=1
		end
	end
	return dict
end



function extracttriangles(W,CW)
	points = convert(Array{Float64,2},W') # points by rows
	vertices=Vector{Float32}()
	FV = Array{Int64,1}[]
	for cell in CW
		ch = QHull.chull(points[cell,:])
		verts = ch.vertices
		trias = ch.simplices
		vdict = Dict(zip(verts, 1:length(verts)))
		fdict = Dict(zip(1:length(cell), cell))
		faces = [[vdict[u],vdict[v],vdict[w]] for (u,v,w) in trias]
		triangles = [[fdict[v1],fdict[v2],fdict[v3]] for (v1,v2,v3) in faces]
		append!(FV,triangles)
	end

	return W,unique(FV)
end

function voxel(V,p,N)
	m,n = size(V)
	dict = Tesi.voxeldict(V,p)
	newV = zeros(m)
	CV = Array{Int64,1}[]
	i = 1
	quad = vcat(Lar.filterByOrder(size(V,1))...)
	for (k,v) in dict
		if v > N
			for j in quad
				newV = hcat(newV,k.+j)
			end
			push!(CV,[i:(i+2^m-1)...])
			i=i+2^m
		end
	end
	W,CW = Lar.simplifyCells(newV[:,2:end],CV)

	W,FW = Tesi.extracttriangles(W,CW)


	return W, (FW, CW)
end
