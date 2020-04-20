using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
using DataStructures
GL=ViewerGL
include("../viewfunction.jl")


# raggio minimo
function radiusequilater(spacing)
	p=(3*spacing)/2
	S= sqrt(p*((p-spacing)^3))
	r=(spacing^3)/(4*S)
	return r
end

#filtro solo triangoli e tetraedrei
function eliminaspigoli(filtration)
	triangledict=DataStructures.SortedDict{Array{Int64,1},Float64}()
	tetradict=DataStructures.SortedDict{Array{Int64,1},Float64}()

	for (k,v) in filtration
		if length(k)==3
			insert!(triangledict,k,v)
		elseif length(k)==4
			insert!(tetradict,k,v)
		else
			continue
		end
	end
	return triangledict,tetradict
end


#TODO devo filtrare i punti. in unione al primo livello si creano punti molto vicini forse dovuti a doppi dati
#nella cava level 1 tolgo 10000 triangoli inutili

# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CUPOLA"
level = 0
allfile = PointClouds.filelevel(fname,level)
_,_,_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Voriginal)

DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);


## studio sugli alpha

#Studio dell'alpha ottimale per i triangoli
spacing = spacing/(2^level)
t,T = eliminaspigoli(filtration)
alphatriangle = sort(unique(values(t)))
rminimo = radiusequilater(spacing) #
approxvalue = [i for i in unique(Lar.approxVal(7).(alphatriangle)) if i <=spacing*2 && i>=rminimo]

# open("alphascupola1.txt", "w") do f
# 	for v in approxvalue
# 		write(f, "$v \n")
# 	end
# end



α = spacing+0*10^-2 #da variare
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);


## Obj example


filename = "examples/TESI/Torus_star.obj";
V,EVs,FVs = Lar.obj2lar(filename);

DT= PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V,DT);
α = Inf
VV,EV,FV,TV = AlphaStructures.alphaSimplex(V,filtration,α)

EV = unique(sort.(convert(Array{Array{Int64,1},1}, collect(Set(cat(map(PointClouds.FV2EV,FV)))))))
GL.VIEW(
	[
		GL.GLGrid(V,FV,GL.COLORS[6],0.7)
	#	GL.GLPoints(convert(Lar.Points,V'),GL.COLORS[6])
	#	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
		GL.GLGrid(V,EV,GL.COLORS[3],0.7)
	]
);


#=
open("DT.jl", "w") do f
	write(f, "[")
	for simplex in DT
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
