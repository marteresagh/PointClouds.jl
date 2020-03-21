using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("../viewfunction.jl")

# load file
fname = "examples/Fitting/TUBE/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

# alpha shapes
DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.03 #0.03316948190331459
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

# shape detection
pointsoncyl,params = PointClouds.findshape(V,FV,rgb,0.005,"cylinder",index=946)

#cylinder model
Vcyl, FVcyl = PointClouds.larmodelcyl(params...)([36,36])


# extraction cylinder cluster
P,FP,Prgb = PointClouds.extractionmodel(V,FV,rgb,pointsoncyl)

# elaboration cylinder cluster
P,FP = PointClouds.extractshape(pointsoncyl,params,α)

# extraction remained model
Vcurrent,FVcurrent,rgbcurrent = PointClouds.deletepoints(V,FV,rgb,pointsoncyl)

GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,pointsoncyl'))
	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],1.)
	colorview(Vcurrent,FVcurrent,rgbcurrent)
	colorview(P,FP,Prgb)
]);




#=
open("FVwPlane1000.jl", "w") do f
	write(f, "[")
	for simplex in myFV
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end


open("VwPlane1000.jl", "w") do f
	n=size(myV,2)
	write(f, "[")
	for i in 1:n
		x=myV[1,i]
		write(f, "$x ")
	end
	write(f, ";")
	for i in 1:n
		y=myV[2,i]
		write(f, "$y ")
	end
	write(f, ";")
	for i in 1:n
		z=myV[3,i]
		write(f, "$z ")
	end
	write(f, "]")
end
=#
