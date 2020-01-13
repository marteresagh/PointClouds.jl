

function random3cells(shape,npoints)
	pointcloud = rand(3,npoints).*shape
	grid = DataStructures.DefaultDict{Array{Int,1},Int}(0)

	for k = 1:size(pointcloud,2)
		v = map(Int∘trunc,pointcloud[:,k])
		if grid[v] == 0 # do not exists
			grid[v] = 1
		else
			grid[v] += 1
		end
	end

	out = Array{Lar.Struct,1}()
	for (k,v) in grid
		V = k .+ [
		 0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0;
		 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0;
		 0.0  1.0  0.0  1.0  0.0  1.0  0.0  1.0]
		cell = (V,[[1,2,3,4,5,6,7,8]])
		push!(out, Lar.Struct([cell]))
	end
	out = Lar.Struct( out )
	V,CV = Lar.struct2lar(out)
end

function CV2FV( v::Array{Int64} )
	faces = [
		[v[1], v[2], v[3], v[4]], [v[5], v[6], v[7], v[8]],
		[v[1], v[2], v[5], v[6]],	[v[3], v[4], v[7], v[8]],
		[v[1], v[3], v[5], v[7]], [v[2], v[4], v[6], v[8]]]
end

function CV2EV( v::Array{Int64} )
	edges = [
		[v[1], v[2]], [v[3], v[4]], [v[5], v[6]], [v[7], v[8]], [v[1], v[3]], [v[2], v[4]],
		[v[5], v[7]], [v[6], v[8]], [v[1], v[5]], [v[2], v[6]], [v[3], v[7]], [v[4], v[8]]]
end

function K( CV )
	I = vcat( [ [k for h in CV[k]] for k=1:length(CV) ]...)
	J = vcat(CV...)
	Vals = [1 for k=1:length(I)]
	return sparse(I,J,Vals)
end

function voxelgrid(V,p)
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

function pointclouds2cubegrid(V,p,N)
	grid = PointClouds.voxelgrid(V,p)
	out = Array{Lar.Struct,1}()

	for (k,v) in grid
		if v > N
			V = k .+ [
			 0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0;
			 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0;
			 0.0  1.0  0.0  1.0  0.0  1.0  0.0  1.0]
			cell = (V,[[1,2,3,4,5,6,7,8]])
			push!(out, Lar.Struct([cell]))
		end
	end

	out = Lar.Struct( out )
	V,CV = Lar.struct2lar(out)
	VV = [[v] for v=1:size(V,2)]
	FV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(CV2FV,CV)))))
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(CV2EV,CV)))))

	return V,(VV,EV,FV,CV)
end


function extractsurfaceboundary(model)
	V,(VV,EV,FV,CV) = model

	M_0 = K(VV)
	M_1 = K(EV)
	M_2 = K(FV)
	M_3 = K(CV)

	∂_1 = M_0 * M_1'
	∂_2 = (M_1 * M_2') .÷ 2 #	.÷ sum(M_1,dims=2)
	s = sum(M_2,dims=2)
	∂_3 = (M_2 * M_3')
	∂_3 = ∂_3 ./	s
	∂_3 = ∂_3 .÷ 1	#	.÷ sum(M_2,dims=2)

	S2 = sum(∂_3,dims=2)
	inner = [k for k=1:length(S2) if S2[k]==2]
	outer = setdiff(collect(1:length(FV)), inner)
	return V,FV[outer]
end
