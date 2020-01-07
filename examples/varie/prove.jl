using AlphaStructures
using MATLAB
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL = ViewerGL

#------------------------------------------------------- SEZIONE MURO 2D
# s = 2; #A =A.+(B-A).* abs.(s.*rand(2, 10).-s/2)
# npoints=500
# A=0
# B=100
#
# x1 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y1 = zeros(npoints)
# x2 = zeros(npoints)
# y2 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# x3 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y3 = ones(npoints)*B
# x4 = ones(npoints).*B
# y4 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
#
# A=10
# B=90
#
# x5 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y5 = ones(npoints).*A
# x6 = ones(npoints).*A
# y6 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# x7 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y7 = ones(npoints)*B
# x8 = ones(npoints).*B
# y8 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
#
# V = hcat(hcat(x1,y1)',hcat(x2,y2)',hcat(x3,y3)',hcat(x4,y4)',hcat(x5,y5)',hcat(x6,y6)',hcat(x7,y7)',hcat(x8,y8)')
#
# GL.VIEW([
#     GL.GLPoints(convert(Lar.Points,V'))
#     GL.GLFrame2
# ]);
#
# x,y = lar2matlab(V)
# @mput x
# @mput y
# mat"DT = delaunay(x,y)"
# @mget DT
# DT =  [convert(Array{Int64,2},DT)[i,:] for i in 1:size(DT,1)]
# filtration = AlphaStructures.alphaFilter(V,DT);
# VV,EV,FV = AlphaStructures.alphaSimplex(V,filtration,1.)
#
# α=6. #5.9spigoli e facce  #6.5 #solo facce #0.9 #solo segmenti
#
# VV,EV,FV = AlphaStructures.alphaSimplex(V, filtration, α)
# GL.VIEW([
# 	#GL.GLGrid(V,EV),
# 	GL.GLGrid(V,FV)
# 	]
# );


#------------------------------------------------------- OGGETTO CONCAVO
#
#
# s = 2; #A =A.+(B-A).* abs.(s.*rand(2, 10).-s/2)
# npoints=100
# A=0
# B=100
#
# x1 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y1 = zeros(npoints)
# x2 = zeros(npoints)
# y2 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# x3 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y3 = ones(npoints)*B
#
# A=0
# B=30
#
# x4 = ones(npoints).*100
# y4 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
#
# A=70
# B=100
# x5 = ones(npoints).*100
# y5 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
#
# A=30
# B=70
#
# x6 = ones(npoints).*50
# y6 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# A=50
# B=100
#
# x7 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y7 = ones(npoints)*30
#
# x8 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y8 = ones(npoints)*70
#
#
# V = hcat(hcat(x1,y1)',hcat(x2,y2)',hcat(x3,y3)',hcat(x4,y4)',hcat(x5,y5)',hcat(x6,y6)',hcat(x7,y7)',hcat(x8,y8)')
#
# GL.VIEW([
#     GL.GLPoints(convert(Lar.Points,V'))
#     GL.GLFrame2
# ]);
#
# x,y = FittingShape.lar2matlab(V)
# @mput x
# @mput y
# mat"DT = delaunay(x,y)"
# @mget DT
# DT =  [convert(Array{Int64,2},DT)[i,:] for i in 1:size(DT,1)]
# filtration = AlphaStructures.alphaFilter(V,DT);
# VV,EV,FV = AlphaStructures.alphaSimplex(V,filtration,1.)
#
# α = 25. #5.9spigoli e facce  #6.5 #solo facce #0.9 #solo segmenti
#
# VV,EV,FV = AlphaStructures.alphaSimplex(V, filtration, α)
# GL.VIEW([
# 	GL.GLGrid(V,EV),
# 	GL.GLGrid(V,FV)
# 	]
# );
#


#------------------------------------------------------- MURO 3D

s = 2; #A =A.+(B-A).* abs.(s.*rand(2, 10).-s/2)
npoints=1000
A=0
B=10

x1 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
y1 = zeros(npoints)
x2 = zeros(npoints)
y2 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
x3 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
y3 = ones(npoints)*B
x4 = ones(npoints).*B
y4 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
z = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
A=1
B=9

x5 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
y5 = ones(npoints).*A
x6 = ones(npoints).*A
y6 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
x7 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
y7 = ones(npoints)*B
x8 = ones(npoints).*B
y8 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)

V = hcat(hcat(x1,y1,z)',hcat(x2,y2,z)',hcat(x3,y3,z)',hcat(x4,y4,z)',hcat(x5,y5,z)',hcat(x6,y6,z)',hcat(x7,y7,z)',hcat(x8,y8,z)')

GL.VIEW([
    GL.GLPoints(convert(Lar.Points,V'))
    GL.GLFrame2
]);

x,y,z = PointClouds.lar2matlab(V)
@mput x
@mput y
@mput z
mat"DT = delaunay(x,y,z)"
@mget DT
DT =  [convert(Array{Int64,2},DT)[i,:] for i in 1:size(DT,1)]
filtration = AlphaStructures.alphaFilter(V,DT);
VV,EV,FV = AlphaStructures.alphaSimplex(V,filtration,1.)

α=0.7 #5.9spigoli e facce  #6.5 #solo facce #0.9 #solo segmenti

VV,EV,FV,TV = AlphaStructures.alphaSimplex(V, filtration, α)
GL.VIEW([
	#GL.GLGrid(V,FV)
	GL.GLGrid(V,TV)
	]
);



#------------------------------------------------------- COLONNA CONCAVA

#
# s = 2; #A =A.+(B-A).* abs.(s.*rand(2, 10).-s/2)
# npoints=1000
# A=0
# B=100
#
# x1 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y1 = zeros(npoints)
# x2 = zeros(npoints)
# y2 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# x3 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y3 = ones(npoints)*B
# z = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# A=0
# B=30
#
# x4 = ones(npoints).*100
# y4 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
#
# A=70
# B=100
# x5 = ones(npoints).*100
# y5 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
#
# A=30
# B=70
#
# x6 = ones(npoints).*50
# y6 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# A=50
# B=100
#
# x7 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y7 = ones(npoints)*30
#
# x8 = A.+(B-A).* abs.(s.*rand(npoints).-s/2)
# y8 = ones(npoints)*70
#
#
# V = hcat(hcat(x1,y1,z)',hcat(x2,y2,z)',hcat(x3,y3,z)',hcat(x4,y4,z)',hcat(x5,y5,z)',hcat(x6,y6,z)',hcat(x7,y7,z)',hcat(x8,y8,z)')
#
# GL.VIEW([
#     GL.GLPoints(convert(Lar.Points,V'))
#     GL.GLFrame2
# ]);
#
# x,y,z = FS.lar2matlab(V)
# @mput x
# @mput y
# @mput z
# mat"DT = delaunay(x,y,z)"
# @mget DT
# DT =  [convert(Array{Int64,2},DT)[i,:] for i in 1:size(DT,1)]
# filtration = AlphaStructures.alphaFilter(V,DT);
# VV,EV,FV = AlphaStructures.alphaSimplex(V,filtration,1.)
#
# α = 25. #5.9spigoli e facce  #6.5 #solo facce #0.9 #solo segmenti
#
# VV,EV,FV,TV = AlphaStructures.alphaSimplex(V, filtration, α)
# GL.VIEW([
# 	GL.GLGrid(V,FV),
# 	GL.GLGrid(V,TV)
# 	]
# );
#


#=
open("V.ply", "w") do f
	for i=1:size(V,2)
		x=V[1,i]
		y=V[2,i]
		z=V[3,i]
		write(f, "$x $y $z \n")
	end
end
=#
