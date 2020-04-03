using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
include("viewfunction.jl")
# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
level = 2
allfile = PointClouds.filelevel(fname,level,false)
_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
spacing = spacing/2^level

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
centroid,V = PointClouds.subtractaverage(Voriginal)
aabb=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457]),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875]))
AABB=(hcat([2.322972769302368e6, 4.7701366959991455e6, 335.9046516418457].-centroid),hcat([2.322984289455414e6, 4.770148216152191e6, 347.4248046875].-centroid))

model = PointClouds.boxmodel(aabb)
GL.VIEW(
	[
		colorview(V,VV,rgb)
		GL.GLGrid(W,EW)
	]
);

"2.322972769302368e6 4.7701366959991455e6 335.9046516418457 2.322984289455414e6 4.770148216152191e6 347.4248046875"

from = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\ROOFLANTERN"

tolas =  "C:\\Users\\marte\\Documents\\SegmentCloud\\roofprova.las"

toply =  "C:\\Users\\marte\\Documents\\SegmentCloud\\roofprova.ply"

PointClouds.segmentpclas(from, tolas, model)

PointClouds.segmentpcply(from, toply, model)

V,(VV,EV,FV,CV) = Lar.cuboid([1,1,1],true)




########  PLY reader

PointClouds.saveply("test.ply", V)


###  Json
V,CV,FV,EV=PointClouds.volumemodel(volume)

GL.VIEW(
	[
		colorview(Voriginal.-centroid,VV,rgb)
		GL.GLGrid(V.-centroid,FV,GL.Point4d(1,1,1,1))
		#GL.GLLar2gl(V,CV)
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)



from = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CUPOLA"
to = "C:\\Users\\marte\\Documents\\SegmentCloud\\roof.ply"
volume = "C:\\Users\\marte\\Documents\\FilePotree\\cava.json"

PointClouds.clip(from, to, volume)

function N1(n)
	a=Int[]
	for i in 1:n
		push!(a,i)
	end
	return a
end


function N2(n)
	a=Array{Int,1}(undef,n)
	for i in 1:n
		a[i]=i
	end
	return a
end

V,(VV,EV,FV,CV) = Lar.apply(Lar.t(-0.5,-0.5,-0.5),Lar.cuboid([1,2,5],true))
mybox = (V,CV,FV,EV)
myboxr = Lar.apply(Lar.r(0,0,-pi/3),mybox)
(V,CV,FV,EV)=myboxr


GL.VIEW(
	[
		GL.GLGrid(V,EV,GL.Point4d(1,1,1,1))
		#GL.GLLar2gl(V,CV)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))

	]
)



function r(args...)
    args = collect(args)
    n = length(args)
    if n == 1 # rotation in 2D
        angle = args[1]; COS = cos(angle); SIN = sin(angle)
        mat = Matrix{Float64}(LinearAlgebra.I, 3, 3)
        mat[1,1] = COS;    mat[1,2] = -SIN;
        mat[2,1] = SIN;    mat[2,2] = COS;
    end

     if n == 3 # rotation in 3D
        mat = Matrix{Float64}(LinearAlgebra.I, 4, 4)
        angle = norm(args);
		@show angle
        if norm(args) != 0.0
			axis = args #normalize(args)
			COS = cos(angle); SIN= sin(angle)
			if axis[2]==axis[3]==0.0    # rotation about x
				mat[2,2] = COS;    mat[2,3] = -SIN;
				mat[3,2] = SIN;    mat[3,3] = COS;
			elseif axis[1]==axis[3]==0.0   # rotation about y
				mat[1,1] = COS;    mat[1,3] = SIN;
				mat[3,1] = -SIN;    mat[3,3] = COS;
			elseif axis[1]==axis[2]==0.0    # rotation about z
				mat[1,1] = COS;    mat[1,2] = -SIN;
				mat[2,1] = SIN;    mat[2,2] = COS;
			else
				I = Matrix{Float64}(LinearAlgebra.I, 3, 3); u = axis
				Ux=[0 -u[3] u[2] ; u[3] 0 -u[1] ;  -u[2] u[1] 1]
				UU =[u[1]*u[1]    u[1]*u[2]   u[1]*u[3];
					 u[2]*u[1]    u[2]*u[2]   u[2]*u[3];
					 u[3]*u[1]    u[3]*u[2]   u[3]*u[3]]
				mat[1:3,1:3]=COS*I+SIN*Ux+(1.0-COS)*UU
			end
		end
	end
	return mat
end
