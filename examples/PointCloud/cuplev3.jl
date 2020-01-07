using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using MATLAB

include("./viewfunction.jl")
#
# fname = "examples/PointCloud/pointCloud/CUPConvegno/r.las"
# fname1 = "examples/PointCloud/pointCloud/CUPConvegno/r1.las"
# fname1 = "examples/PointCloud/pointCloud/CUPConvegno/r10.las"
# fname2 = "examples/PointCloud/pointCloud/CUPConvegno/r11.las"
# fname3 = "examples/PointCloud/pointCloud/CUPConvegno/r12.las"
# fname4 = "examples/PointCloud/pointCloud/CUPConvegno/r13.las"
# fname5 = "examples/PointCloud/pointCloud/CUPConvegno/r14.las"
# fname6 = "examples/PointCloud/pointCloud/CUPConvegno/r15.las"
# fname7 = "examples/PointCloud/pointCloud/CUPConvegno/r16.las"
# fname8 = "examples/PointCloud/pointCloud/CUPConvegno/r17.las"


fname1 = "examples/PointCloud/pointCloud/CUPConvegno/r102.las"
fname2 = "examples/PointCloud/pointCloud/CUPConvegno/r104.las"
fname3 = "examples/PointCloud/pointCloud/CUPConvegno/r106.las"
fname4 = "examples/PointCloud/pointCloud/CUPConvegno/r107.las"

fname5 = "examples/PointCloud/pointCloud/CUPConvegno/r116.las"

fname6 = "examples/PointCloud/pointCloud/CUPConvegno/r120.las"
fname7 = "examples/PointCloud/pointCloud/CUPConvegno/r122.las"
fname8 = "examples/PointCloud/pointCloud/CUPConvegno/r124.las"
fname9 = "examples/PointCloud/pointCloud/CUPConvegno/r125.las"
fname10 = "examples/PointCloud/pointCloud/CUPConvegno/r126.las"
fname11 = "examples/PointCloud/pointCloud/CUPConvegno/r127.las"

fname12 = "examples/PointCloud/pointCloud/CUPConvegno/r134.las"

fname13 = "examples/PointCloud/pointCloud/CUPConvegno/r140.las"
fname14 = "examples/PointCloud/pointCloud/CUPConvegno/r142.las"
fname15 = "examples/PointCloud/pointCloud/CUPConvegno/r143.las"
fname16 = "examples/PointCloud/pointCloud/CUPConvegno/r144.las"
fname17 = "examples/PointCloud/pointCloud/CUPConvegno/r146.las"
fname18 = "examples/PointCloud/pointCloud/CUPConvegno/r147.las"

fname19 = "examples/PointCloud/pointCloud/CUPConvegno/r152.las"

fname20 = "examples/PointCloud/pointCloud/CUPConvegno/r161.las"
fname21 = "examples/PointCloud/pointCloud/CUPConvegno/r162.las"
fname22 = "examples/PointCloud/pointCloud/CUPConvegno/r163.las"
fname23 = "examples/PointCloud/pointCloud/CUPConvegno/r164.las"
fname24 = "examples/PointCloud/pointCloud/CUPConvegno/r165.las"
fname25 = "examples/PointCloud/pointCloud/CUPConvegno/r166.las"
fname26 = "examples/PointCloud/pointCloud/CUPConvegno/r167.las"

fname27 = "examples/PointCloud/pointCloud/CUPConvegno/r170.las"
fname28 = "examples/PointCloud/pointCloud/CUPConvegno/r171.las"



Vtot,VV,rgb = PointClouds.loadlas(fname1,fname2,fname3,fname4,fname5,fname6,fname7,fname8,fname9,fname10,
							fname11,fname12,fname13,fname14,fname15,fname16,fname17,fname18,fname19,fname20,
							fname21,fname22,fname23,fname24,fname25,fname26,fname27,fname28)
V,VV = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,VV])


GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.mat3DT(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.06
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb)
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
