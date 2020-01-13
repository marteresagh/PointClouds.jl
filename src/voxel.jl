
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
	CV = Array{Int64,1}[]
	i = 0
	quad = vcat(Lar.filterByOrder(size(V,1))...)

	for (k,v) in dict
		if v > N
			for j in quad
				newV = hcat(newV,k.+j)
			end
			push!(CV,[i+1:(i+2^m)...])
			i=i+2^m
		end
	end

	return newV[:,2:end],sort.(CV)

end

function voxel(V,p,N)
	T,CT = PointClouds.voxel0(V,p,N)
	W,CW = Lar.simplifyCells(T,CT)

	#estrai bordo come estraggo le facce?
	# ch=QHull.chull(convert(Lar.Points,W'))
	# FW=ch.simplices
	#
	# Mbound = Lar.u_boundary_3(CW,FW)
	# fv=(Mbound'*ones(length(CW))).%2
	# FVb=FW[Bool.(fv)]

	return W,CW
end
