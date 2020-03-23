"""
Generate  cluster  of  points  with  the  same  color.
"""
function colorsegmentation(V::Lar.Points, FV::Lar.Cells, Vrgb::Lar.Points, par::Float64; index=0)

	# 1. list of adjacency verteces
	EV = convert(Array{Array{Int64,1},1}, collect(Set(PointClouds.CAT(map(PointClouds.FV2EV,FV)))))
   	adj = Lar.verts2verts(EV)

	# 2. first samples #TODO implementare la nuova versione per la ricerca del primo seed point
	if index==0
		index = rand(1:size(V,2))
	end
	@show index
	visitedverts = [index]
	seeds=[index]
	idxneighbors = PointClouds.findnearestof(seeds,visitedverts,adj)

	# 4. check if this neighbors are other points of plane
    while !isempty(idxneighbors)

	    for i in idxneighbors
			color = PointClouds.centroidrgb(Vrgb[:,visitedverts])
            query = Vrgb[:,i]

			if Lar.norm(color-query)<=par
				push!(seeds,i)
	        end

            push!(visitedverts,i)

        end

        idxneighbors = PointClouds.findnearestof(seeds,visitedverts,adj)
    end

    return  V[:,seeds],Vrgb[:,seeds]
end

"""
Centroid RGB https://sighack.com/post/averaging-rgb-colors-the-right-way  DA STUDIARE
"""
function centroidrgb(rgb)
	n=size(rgb,2)
	r2=map(x->x^2,rgb[1,:])
	g2=map(x->x^2,rgb[2,:])
	b2=map(x->x^2,rgb[3,:])

	sr=sum(r2)
	sg=sum(g2)
	sb=sum(b2)

	return [sqrt(sr/n),sqrt(sg/n),sqrt(sb/n)]
end
