using LinearAlgebraicRepresentation, AlphaStructures, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL
using PointClouds

include("./viewfunction.jl")

# fname = "examples/fit/PUMP/r.las"
#fname = "examples/fit/TUBE/r.las"
fname = "examples/fit/PUMPSEG/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
V,a = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,[1]])

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


# #Equivalent to =>
# V = AlphaStructures.matrixPerturbation(V);
#DT = AlphaStructures.delaunayWall(V);
DT = PointClouds.mat3DT(V)

filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.03316948190331459
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb);
		#colorview(V,TV,rgb)
	]
);

# allplanes,VwPlane1000,FVwPlane1000 = PointClouds.findallplane(V,FV,0.05,1000,2)
# meshes = [GL.GLGrid(allplanes[1][i],allplanes[2][i]) for i in 1:length(allplanes[1])]
# GL.VIEW([
#  	colorview(V,VV,rgb),
#  	meshes...,
#  	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#
# GL.VIEW([
# 	GL.GLGrid(VwPlane1000,FVwPlane1000)
# 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])

# include("./PUMP/FVwPlane1000.jl")
# include("./PUMP/VwPlane1000.jl")

# allplanes,myV1,myFV1 = PointClouds.findallplane(VwPlane1000,FVwPlane1000,0.05,500,2)
# meshes = [GL.GLGrid(allplanes[1][i],allplanes[2][i]) for i in 1:length(allplanes[1])]
# GL.VIEW([
#  	colorview(V,VV,rgb),
#  	meshes...,
#  	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#
# GL.VIEW([
# 	GL.GLGrid(myV1,myFV1)
# 	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#

function quadricshape(V::Lar.Points,FV::Lar.Cells,par::Float64,NOTASHAPE=10::Int64)

	# 1. list of adjacency verteces
	EV = Lar.simplexFacets(FV)
   	adj = Lar.verts2verts(EV)

	# 2. first three points
    i0 = rand(1:length(FV))
	idxp = copy(FV[i0])
    pointsoncyl = V[:,idxp]
	visitedverts = copy(idxp)
	idxneighbors = PointClouds.findnearestof(idxp,visitedverts,adj)
	tot=hcat(pointsoncyl,V[:,idxneighbors])
	idxp=vcat(idxp,idxneighbors)
	params = PointClouds.cylinderfit(tot) #il primo non posso farlo solo su 3 punti  e forse bisogna cambiare idea generale
	visitedverts = copy(idxp)
	idxneighbors = PointClouds.findnearestof(idxp,visitedverts,adj)
	# 4. check if this neighbors are other points of plane
    while !isempty(idxneighbors)
		@show size(pointsoncyl,2)
	    for i in idxneighbors
            p = V[:,i]

            if PointClouds.ispointincyl(p,params,par)
				push!(idxp,i)
            end

			push!(visitedverts,i)

        end

		pointsoncyl = V[:,idxp]
		@show size(pointsoncyl,2)
		params = PointClouds.cylinderfit(pointsoncyl)
        idxneighbors = PointClouds.findnearestof(idxp,visitedverts,adj)
    end

	if size(pointsoncyl,2) <= NOTASHAPE
		println("planeshape: not a valid shape")
		return nothing, nothing
	end
    return  pointsoncyl,params
end


pointsoncyl=nothing
#while isnothing(pointsoncyl)
	pointsoncyl,params = quadricshape(V,FV,0.03,40)
#end

pointsoncyl,params = quadricshape(V,FV,0.05,40)
Vcyl, FVcyl = PointClouds.larmodelcyl(params...)([36,36])
#myV,myFV,myrgb = PointClouds.modelremained(V,FV,rgb,pointsoncyl)

GL.VIEW([
	colorview(V,FV,rgb)
	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[2],1.)
 #	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
])

# pointsoncyl,params = quadricshape(myV,myFV,0.01,40)
# Vcyl1, FVcyl1 = PointClouds.larmodelcyl(params...)([36,36])
# myV1,myFV1,myrgb1 = PointClouds.modelremained(myV,myFV,myrgb,pointsoncyl)
#
# pointsoncyl,params = quadricshape(myV1,myFV1,0.02,40)
# Vcyl2, FVcyl2 = PointClouds.larmodelcyl(params...)([36,36])
# myV2,myFV2,myrgb2 = PointClouds.modelremained(myV1,myFV1,myrgb1,pointsoncyl)
#
# pointsoncyl,params = quadricshape(myV2,myFV2,0.02,40)
# Vcyl3, FVcyl3 = PointClouds.larmodelcyl(params...)([10,10])
# myV3,myFV3,myrgb3 = PointClouds.modelremained(myV2,myFV2,myrgb2,pointsoncyl)
#
# pointsoncyl,params = quadricshape(myV3,myFV3,0.02,40)
# Vcyl4, FVcyl4 = PointClouds.larmodelcyl(params...)([10,36])
# myV4,myFV4,myrgb4 = PointClouds.modelremained(myV3,myFV3,myrgb3,pointsoncyl)
#
# pointsoncyl,params = quadricshape(myV4,myFV4,0.02,40)
# Vcyl5, FVcyl5 = PointClouds.larmodelcyl(params...)([10,36])
# myV5,myFV5,myrgb5 = PointClouds.modelremained(myV4,myFV4,myrgb4,pointsoncyl)
#
# pointsoncyl,params = quadricshape(myV5,myFV5,0.01,40)
# Vcyl6, FVcyl6 = PointClouds.larmodelcyl(params...)([10,36])
# myV6,myFV6,myrgb6 = PointClouds.modelremained(myV5,myFV5,myrgb5,pointsoncyl)
#
# pointsonplane,params = PointClouds.planeshape(myV6,myFV6,0.03,500)
# Vplane, FVplane = PointClouds.larmodelplane(pointsonplane,params)
# myV7,myFV7,myrgb7 = PointClouds.modelremained(myV6,myFV6,myrgb6,pointsonplane)
#
# pointsoncyl,params = quadricshape(myV7,myFV7,0.005,40)
# Vcyl7, FVcyl7 = PointClouds.larmodelcyl(params...)([10,36])
# myV7,myFV7,myrgb7 = PointClouds.modelremained(myV7,myFV7,myrgb7,pointsoncyl)
#
# pointsonplane,params = PointClouds.planeshape(myV7,myFV7,0.02,100)
# Vplane1, FVplane1 = PointClouds.larmodelplane(pointsonplane,params)
# myV8,myFV8,myrgb8 = PointClouds.modelremained(myV7,myFV7,myrgb7,pointsonplane)
#
# GL.VIEW([
#  #	colorview(myV8,myFV8,myrgb8)
# 	GL.GLGrid(myV8,myFV8,GL.COLORS[11],1.)
#  	GL.GLGrid(Vcyl,FVcyl,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl1,FVcyl1,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl2,FVcyl2,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl3,FVcyl3,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl4,FVcyl4,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl5,FVcyl5,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl6,FVcyl6,GL.COLORS[11],1.)
# 	GL.GLGrid(Vcyl7,FVcyl7,GL.COLORS[11],1.)
# 	GL.GLGrid(Vplane,FVplane,GL.COLORS[11],1.)
# 	GL.GLGrid(Vplane1,FVplane1,GL.COLORS[11],1.)
#  #	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#
# GL.VIEW([
# 	colorview(myV2,myFV2,myrgb2)
# 	#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# ])
#









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
