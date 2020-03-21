using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFHALF"
level = 7
allfile = PointClouds.filelevel(fname,level)

_,_,_,_,_,spacing = PointClouds.readJSON(fname)
spacing = spacing/2^level

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Voriginal)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.5 #da variare
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);

objs = Lar.lar2obj(V, FV)

open("./modello.obj", "w") do f
    write(f, objs)
end

function splitarray(DT)
	if length(DT)>10^6
		splitDT=[]
		l=length(DT)
		for i=0:div(l,10^6)-1
			t=i*10^6+1
			f=(i+1)*10^6
			push!(splitDT,DT[t:f])
		end
		t=div(l,10^6)*10^6+1
		push!(splitDT,DT[t:end])
	end
	return splitDT
end

function filtrationsplit(splitDT)
	filtrtot=[]
	for i in 1:length(splitDT)
		@show "======================================================"
		@show i
		@show "======================================================"
		filtration = AlphaStructures.alphaFilter(V, splitDT[i]);
		push!(filtrtot,filtration)
	end
	return filtrtot
end

function FVunion(filtrtot,α)
	FVtot=[]
	for i=1:length(filtrtot)
		VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtrtot[i], α);
		push!(FVtot,FV)
	end
	return union(FVtot...)
end


splitDT=splitarray(DT)
filtrtot = filtrationsplit(splitDT)
α = 0.04
FV=FVunion(filtrtot,α)

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);

#=
open("FV.jl", "w") do f
	write(f, "[")
	for simplex in FV
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
