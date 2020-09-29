using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
using AlphaStructures

# txtpotreedirs = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\directory.txt"
# potreedirs = PointClouds.getdirectories(txtpotreedirs)
# typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
# bbin = tightBB
# quota = 105.0
# thickness = 0.02
# outputfile = "planimetria.las"
# @time PointClouds.extractpointcloud( txtpotreedirs, outputfile, bbin, quota, thickness )


# header,laspoints = PointClouds.load("examples/PAPER/planimetria.las")
# pvec = PointClouds.set_z_zero(laspoints,header)
# PointClouds.LasIO.update!(header,pvec)
# LasIO.FileIO.save("examples/PAPER/planimetria_planexy.las",header,pvec)

Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/planimetria_planexy_subsample.las")
_,Vtrasl = PointClouds.subtractaverage(Voriginal)
V = Vtrasl[1:2,:]

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,V'))
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);


DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.05
VV, EV, FV = AlphaStructures.alphaSimplex(V, filtration, α);

# GL.VIEW(
# 	[
# 		GL.GLGrid(V,EV)
# 		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# 	]
# );


#pointsonline, params = PointClouds.linedetection(V,EV,0.02)


lines = PointClouds.linessegmentation(V, EV, 15, 0.02)
W,EW = PointClouds.drawlines(lines,0.5)

GL.VIEW(
	[
	#	GL.GLPoints(convert(Lar.Points,V'))
		GL.GLGrid(W,EW)
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);


#
# x = rand(10)
# a = rand()
# b = rand()
# y = Float64[]
#
# for i in 1:size(x,1)
#     push!(y, x[i]*a + b + 0.01*rand()) # points perturbation
# end
# pointsonline = vcat(x',y')
#
# params = PointClouds.linefit(vcat(x',y'))
#
# V,EV = PointClouds.larmodelsegment(pointsonline,params)
#
#
# GL.VIEW(
# 	[
# 		GL.GLPoints(convert(Lar.Points,pointsonline'))
# 		GL.GLGrid(V,EV)
# 		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# 	]
# );
