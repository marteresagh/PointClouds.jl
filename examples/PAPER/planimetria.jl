using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
using AlphaStructures

# ============= SEZIONE ==============================================================
# txtpotreedirs = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\directory.txt"
# potreedirs = PointClouds.getdirectories(txtpotreedirs)
# typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
# bbin = tightBB
# quota = 105.0
# thickness = 0.02
# outputfile = "planimetria.las"
# @time PointClouds.extractpointcloud( txtpotreedirs, outputfile, bbin, quota, thickness )

# ============= GENERAZIONE FILE INPUT ==============================================================
# header,laspoints = PointClouds.load("examples/PAPER/planimetria.las")
# pvec = PointClouds.set_z_zero(laspoints,header)
# PointClouds.LasIO.update!(header,pvec)
# LasIO.FileIO.save("examples/PAPER/planimetria_planexy.las",header,pvec) # file poi decimato con CC

# ============= LOAD ==============================================================
Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/planimetria_planexy_subsample.las")
_,Vtrasl = PointClouds.subtractaverage(Voriginal)
V = Vtrasl[1:2,:]

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,V'))
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

# ============= ALPHA SHAPE ==============================================================
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


# ============= PLANIMETRIA ==============================================================
#pointsonline, params = PointClouds.linedetection(V,EV,0.02)
lines = PointClouds.linessegmentation(V, EV, 15, 0.02) # random detection

W, EW = PointClouds.drawlines(lines,0.5)

GL.VIEW(
	[
	#	GL.GLPoints(convert(Lar.Points,V'))
		GL.GLGrid(W,EW,GL.COLORS[12])
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);


# ============= SCANSIONE DENTRO E FUORI ==============================================================
interior = PointClouds.apply_matrix(Lar.s(0.9,0.9), V)
new_input = hcat(V,interior)

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,new_input'))
		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

DT = PointClouds.delaunayMATLAB(new_input)
filtration = AlphaStructures.alphaFilter(new_input, DT);
α = 0.05
VV, EV, FV = AlphaStructures.alphaSimplex(new_input, filtration, α);
GL.VIEW(
	[
		GL.GLGrid(new_input,EV)
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

lines = PointClouds.linessegmentation(new_input, EV, 30, 0.02) # random detection

W, EW = PointClouds.drawlines(lines,0.5)

GL.VIEW(
	[
	#	GL.GLPoints(convert(Lar.Points,V'))
		GL.GLGrid(W,EW)
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);
