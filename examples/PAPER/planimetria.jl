using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using Images
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
