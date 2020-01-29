using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

# generation random points on plane
npoints = 4000
xslope = 3.
yslope = 0.
off = 5.

xs = rand(npoints)
ys = rand(npoints)
zs = Float64[]

for i in 1:npoints
    push!(zs, xs[i]*xslope + ys[i]*yslope + off)
end

V = convert(Lar.Points, hcat(xs,ys,zs)')
FV=PointClouds.DTprojxy(V)


# other examples
# V,FV = Lar.cylinder(1.,2)([100,10])
#
# V,FV = Lar.apply(Lar.t(1.,2.,1.),Lar.sphere(5.)([64,64]))
#
#V,FV = Lar.toroidal(2,4,2*pi,pi/4)([64,64])


# compute normals

function computenormals(V,FV)
	#per i vicini uso la triangolazione FV
	EV = convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.FV2EV,FV)))))

   	adj = Lar.verts2verts(EV)

	# TODO da risolvere il movimento sui vertici vicini

	# g5 = SimpleGraph(size(V,2))
	# for edge in EV
	# 	add_edge!(g5,edge[1],edge[2])
	# end
	# spanningtree,_ = LightGraphs.dfs_parents(g5) #prova a trovare un altra funzione
	#spanningtree,_ = Lar.depth_first_search(EV) #prova a trovare un altra funzione

	normals=similar(V)
	#orderedvertex=unique(vcat(spanningtree...))
 	for t in 1:length(spanningtree)
		if t%1000==0
			println(t," visited verteces")
		end
		i = spanningtree[t]
		# calcolo normale del primo
		indneigh=adj[i]
		neigh=V[:,[i,indneigh...]]
		normals[:,i],_ = PointClouds.planefit(neigh)

		if t!=1
			if Lar.dot(normals[:,spanningtree[t-1]],normals[:,i])<0
				normals[:,i]=-normals[:,i]
			end
		end
	end

	return normals
end


normals = computenormals(V,FV)
GL.VIEW([viewnormals(V,normals)...,GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))])
