using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("../viewfunction.jl")
#fname = "examples/PointCloud/pointCloud/CUPOLA/r.las"
fname = "examples/fit/CASALETTO/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Vtot)
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

#0.1 0.4 2.
p = 0.4 #spacing cupola 0.4, spacing casaletto 0.27404680848121645,
W,CW = PointClouds.voxel(V,p,0)

GL.VIEW(
	[
		#GL.GLGrid(W,FW,GL.COLORS[2],1)
		GL.GLLar2gl(W,CW)
	]
)


#=

open("V.jl", "w") do f
	n=size(W,2)
	write(f, "[ ")
	for i in 1:n
		x = W[1,i]
		write(f, "$x ")
	end
	write(f, ";\n")
	for i in 1:n
		y = W[2,i]
		write(f, "$y ")
	end
	write(f, ";\n")
	for i in 1:n
		z = W[3,i]
		write(f, "$z ")
	end
	write(f, "]")
end



open("CV.jl", "w") do f
	write(f, "[")
	for simplex in CW
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
#
# include("../../V.jl")
# include("../../CV.jl")
#
# using QHull
# V,(VV,EV,FV)=Lar.cuboidGrid([1,2],true)
#
# ch=QHull.chull(convert(Lar.Points,V'))
# FV=ch.simplices
#
# mCV=Lar.lar2cop(CV)
# bound = mCV*mCV'
#
# GL.VIEW(
# 	[
# 		#GL.GLGrid(W,FW,GL.COLORS[2],1)
# 		GL.GLLar2gl(V,CV)
# 	]
# )
