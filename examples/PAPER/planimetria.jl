using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL = ViewerGL
using AlphaStructures

# ============= SEZIONE ==============================================================
# txtpotreedirs = "C:\\Users\\marte\\Documents\\GEOWEB\\FilePotree\\orthophoto\\directory.txt"
# potreedirs = PointClouds.getdirectories(txtpotreedirs)
# typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
# bbin = tightBB
# quota = 0.0
# thickness = 0.02
# outputfile = "planimetriaMERGE.las"
# @time PointClouds.pointExtraction( txtpotreedirs, outputfile, Matrix{Float64}(Lar.I,3,3), bbin, quota, thickness )

# ============= GENERAZIONE FILE INPUT ==============================================================
# header,laspoints = PointClouds.load("examples/PAPER/planimetriaMERGE.las")
# pvec = PointClouds.set_z_zero(laspoints,header)
# PointClouds.LasIO.update!(header,pvec)
# using LasIO
# LasIO.FileIO.save("examples/PAPER/planimetriaMERGE_planexy.las",header,pvec) # file poi decimato con CC

# ============= LOAD ==============================================================
Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/planimetriaMERGE_planexy.las")
# Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/planimetria_planexy_subsample.las")
trasl,Vtrasl = PointClouds.subtractaverage(Voriginal)
V = Vtrasl[1:2,:]
PC = PointClouds.PointCloud(size(V,2),V,rgb)

GL.VIEW(
	[
		GL.GLPoints(convert(Lar.Points,V'))
		#GL.GLGrid(L,EL)
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);

# ============= PLANIMETRIA ==============================================================
LINES = PointClouds.LinesDetectionRandom(PC, 0.15, 2*0.03, 200, 100)
# LINES = PointClouds.LinesDetectionRandom(PC, 0.02, 2*0.05, 200, 20) #casaletto

L,EL = PointClouds.DrawLines(LINES)

GL.VIEW(
	[
		#GL.GLPoints(convert(Lar.Points,V'))
		GL.GLGrid(L,EL)
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);


# ================== ARRANGEMENT ============================================================

# model = (L,EL)
# Sigma = Lar.spaceindex(model)
#
# model = L,EL;
# W,EW = Lar.fragmentlines(model);
# U,EVs = Lar.biconnectedComponent((W,EW::Lar.Cells));
# EV = convert(Lar.Cells, cat(EVs))
# V,FVs,EVs = Lar.arrange2D(U,EV)
#
# GL.VIEW(GL.GLExplode(V,FVs,1.2,1.2,1.2,1));
# GL.VIEW(GL.GLExplode(V,FVs,1.2,1.2,1.2,3,1));
# GL.VIEW(GL.GLExplode(V,FVs,1.2,1.2,1.2,99,1));
# GL.VIEW(GL.GLExplode(V,FVs,1.,1.,1.,99,1));
# GL.VIEW(GL.GLExplode(V,EVs,1.2,1.2,1.2,1,1));

# ============= SCANSIONE DENTRO E FUORI ==============================================================
# interior = PointClouds.apply_matrix(Lar.s(0.9,0.9), V)
# new_input = hcat(V,interior)
#
# GL.VIEW(
# 	[
# 		GL.GLPoints(convert(Lar.Points,new_input'))
# 		GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
# 	]
# );
