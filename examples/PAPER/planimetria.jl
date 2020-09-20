using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL


txtpotreedirs = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\directory.txt"
potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
bbin = tightBB
quota = 105.0
thickness = 0.02
outputfile = "planimetria.las"
# @time PointClouds.extractpointcloud( txtpotreedirs, outputfile, bbin, quota, thickness )


# header,laspoints = PointClouds.load("examples/PAPER/planimetria.las")
# pvec = PointClouds.set_z_zero(laspoints,header)
# PointClouds.LasIO.update!(header,pvec)
# LasIO.FileIO.save("examples/PAPER/planimetria_planexy.las",header,pvec)

Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/planimetria_planexy_subsample.las")

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,V'))
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);
