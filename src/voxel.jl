function K(CV::Lar.Cells)
	I = vcat( [ [k for h in CV[k]] for k=1:length(CV) ]...)
	J = vcat(CV...)
	Vals = [1 for k=1:length(I)]
	return sparse(I,J,Vals)
end

function voxelgrid(V::Lar.Points,p::Float64)
	npoints = size(V,2)
	dict = DataStructures.SortedDict{Array{Int64,1},Int64}()
	for i in 1:npoints
		point = V[:,i]
		coord =  floor.(Int,point/p) # poi moltiplica tutto per il passo
		if haskey(dict,coord)
			dict[coord]+=1
		else
			dict[coord]=1
		end
	end
	return dict
end

function pointclouds2cubegrid(V::Lar.Points,p::Float64,N::Int64)#RINOMINA COME voxelization
	grid = PointClouds.voxelgrid(V,p)
	out = Array{Lar.Struct,1}()

	for (k,v) in grid
		if v >= N
			V = k .+ [
			 0.0  0.0  0.0  0.0  1.0  1.0  1.0  1.0;
			 0.0  0.0  1.0  1.0  0.0  0.0  1.0  1.0;
			 0.0  1.0  0.0  1.0  0.0  1.0  0.0  1.0]
			cell = (V.*p,[[1,2,3,4,5,6,7,8]])
			push!(out, Lar.Struct([cell]))
		end
	end
	out = Lar.Struct( out )
	V,CV = Lar.struct2lar(out)
	return V,CV
end


function voxeloriented(allplanes,p,N)
	n = length(allplanes)
	out = Array{Lar.Struct,1}()
	for i in 1:n
		model = (allplanes[i][1], [[i] for i in 1:size(allplanes[i][1],2)])
		axis,centroid = allplanes[i][2]
		rot = hcat(Lar.nullspace(Matrix(axis')),axis)
		matrixaffine = vcat(hcat(rot,[0.,0.,0.]),[0.,0.,0.,1.]')
		shape = Lar.Struct([Lar.inv(matrixaffine),Lar.t(-centroid...),model])
		model=Lar.struct2lar(shape)
		W,CW = PointClouds.pointclouds2cubegrid(model[1],p,N)
		shape = Lar.Struct([Lar.t(centroid...),matrixaffine,(W,CW)])# viene rimpicciolito per il passo devi mantenere le stesse dimensioni
		push!(out,shape)
	end
	out=Lar.Struct(out)
	V,CV = Lar.struct2lar(out)
	return V,CV
end


function extractsurfaceboundary(V::Lar.Points,CV::Lar.Cells)
	VV = [[v] for v=1:size(V,2)]
	EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.CV2EV,CV)))))
	FV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.CV2FV,CV)))))

	# M_0 = K(VV)
	# M_1 = K(EV)
	M_2 = K(FV)
	M_3 = K(CV)

	# ∂_1 = M_0 * M_1'
	# ∂_2 = (M_1 * M_2') .÷ 2 #	.÷ sum(M_1,dims=2)
	s = sum(M_2,dims=2)
	∂_3 = (M_2 * M_3')
	∂_3 = ∂_3 ./	s
	∂_3 = ∂_3 .÷ 1	#	.÷ sum(M_2,dims=2)

	S2 = sum(∂_3,dims=2)
	inner = [k for k=1:length(S2) if S2[k]==2]
	outer = setdiff(collect(1:length(FV)), inner)
	return V,FV[outer]
end
