using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL

include("viewfunction.jl")

## input data
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\UCS"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,_,_,spacing = PointClouds.readcloudJSON(fname)
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
m,npoints = size(Vtot)

GL.VIEW(
	[
		viewRGB(Y,VV,rgb)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

UCSpath = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\ucs_1.json"

UCS = PointClouds.ucsJSON2matrix(UCSpath)

V4 = [Vtot; fill(1.0, (1,npoints))]
V_ucs = (UCS * V4)[1:m,1:npoints]

GL.VIEW(
	[
		viewRGB(V_ucs,VV,rgb)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

dict = PointClouds.readucsJSON(UCSpath)

V,(VV,EV,FV,CV) = Lar.cuboid([1,2,5],true)
rgb = [1 0.996 0.160 0.160 0.160 0.454 1 1; 0.168 1 1 0.992 0.360 0.160 0.160 0.537; 0.160 0.160 0.231 1 1 1 1 0.160]

GL.VIEW(
	[
		viewRGB(V,VV,rgb)
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);
