
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


function voxel0(V,p,N)
	m,n = size(V)
	dict = PointClouds.voxeldict(V,p)
	newV = zeros(m)
	FV = Array{Int64,1}[]
	CV = Array{Int64,1}[]
	i = 0
	quad = vcat(Lar.filterByOrder(size(V,1))...)
	f0=sort.([[1,2,5,3],[1,3,7,4],[2,5,8,6],[4,6,8,7],[3,5,8,7],[1,2,6,4]])
	for (k,v) in dict
		if v > N
			for j in quad
				newV = hcat(newV,k.+j)
			end
			#@show newV
			fv=copy(f0)
			for j in 1:length(f0)
				fv[j]=f0[j].+i
			end
			push!(FV,fv...)
			push!(CV,[i+1:(i+2^m)...])
			#@show CV
			i=i+2^m
		end
	end

	return newV[:,2:end],sort.(FV),sort.(CV)

end

function voxel(V,p,N)
	T,FT,CT = PointClouds.voxel0(V,p,N)
	#aggiornare LAR
	 u_boundary_3(CV, FV) = (Lar.u_coboundary_2(CV, FV))'
	 W,FW,CW = PointClouds.simplcell(T,FT,CT)

	 FW=sort.(FW)
	 CW=sort.(CW)
	#estrai bordo
	 Mbound = u_boundary_3(CW,FW)
	 fv=(Mbound*ones(length(CW))).%2
	 FVb=FW[Bool.(fv)]
	#
	return W, FVb, CW
end

function simplcell(V,FV,CV)
	PRECISION = 5
	vertDict = DefaultDict{Array{Float64,1}, Int64}(0)
	index = 0
	W = Array{Float64,1}[]
	FW = Array{Int64,1}[]
	CW = Array{Int64,1}[]

	for incell in FV
		#@show incell
		outcell = Int64[]
		for v in incell
			vert = V[:,v]
			key = map(Lar.approxVal(PRECISION), vert)
			if vertDict[key]==0
				index += 1
				vertDict[key] = index
				push!(outcell, index)
				push!(W,key)
			else

				push!(outcell, vertDict[key])

			end
		end
		#@show W
		#@show outcell
		append!(FW, [[Set(outcell)...]])
	end

	for incell in CV
		#@show incell
		outcell = Int64[]
		for v in incell
			vert = V[:,v]
			key = map(Lar.approxVal(PRECISION), vert)
			if vertDict[key]==0
				index += 1
				vertDict[key] = index
				push!(outcell, index)
				push!(W,key)
			else

				push!(outcell, vertDict[key])

			end
		end
		#@show W
		#@show outcell
		append!(CW, [[Set(outcell)...]])
	end
	return hcat(W...),FW,CW
end
