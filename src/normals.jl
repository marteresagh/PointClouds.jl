"""
	computenormals(V,FV)

Estimation of normals.
"""
function computenormals(V::Lar.Points, FV::Lar.Cells, start::Int=1)::Lar.Points

	# 1. find list of neighbor
	EV = unique(sort.(convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.FV2EV,FV)))))))
	VV = Lar.verts2verts(EV)
	@show "adiacenti calcolati"
	# DFS definition
	function DFS(v::Int, u::Int)
	# u father of v
		number[v] = i
		if i == 1 #normal of first point
			indneigh = VV[v]
			neigh = V[:,[v,indneigh...]]
			normals[:,v],_ = PointClouds.planefit(neigh)
		end
		i += 1
		#@show i
		for w in VV[v]
			if number[w] == 0  # w is not visited
				indneigh = VV[w]
				neigh = V[:,[w,indneigh...]]
				normals[:,w],_ = PointClouds.planefit(neigh)
				if Lar.dot(normals[:,v],normals[:,w]) < 0 # flip normal
						normals[:,w] = -normals[:,w]
				end
				DFS(w, v)
			# else
			# 	@show "novicini da visitare"
			end
		end
	end

	# 2. initialization
	number = zeros(Int, length(VV))
	normals = similar(V)
	i = 1
	DFS(start, 1)
	return normals
end


"""
	flipnormals(normals)

Flip all normals.
"""
flipnormals(normals::Lar.Points) = -normals
