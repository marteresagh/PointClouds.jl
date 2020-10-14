using LinearAlgebraicRepresentation
using PointClouds
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL = ViewerGL
using NearestNeighbors

function ViewLines(LINES::Array{PointClouds.LineDataset,1})

	mesh = []
	for line in LINES
		pc = line.points
		V,EV = PointClouds.DrawLine(pc.points,line.line,1.0)
		col = GL.COLORS[rand(1:12)]
		push!(mesh,GL.GLGrid(V,EV,col));
		push!(mesh,	GL.GLPoints(convert(Lar.Points,pc.points'),col));
	end

	GL.VIEW(mesh)
end

## points input
Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/planimetriaMERGE_planexy.las")
Voriginal,VV,rgb = PointClouds.loadlas("examples/PAPER/muriAngolo.las")
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


par = 0.06
threshold = 2*0.03
@time LINES = PointClouds.LinesDetectionRandom(PC, 0.06, 2*0.03, 400, 100)
linedetected = PointClouds.LineDetectionFromRandomInitPoint(PC,par,threshold)
L,EL = PointClouds.DrawLines(LINES,0.3)
ViewLines(LINES)
ViewLines(LINES2)

function nonpresi(V,LINES)
	W = copy(V)
	todel = []
	for line in LINES
		pc = line.points
		ps = [PointClouds.matchcolumn(pc.points[:,i],V) for i in 1:size(pc.points,2)]
		union!(todel,ps)
	end
	tokeep = setdiff(collect(1:size(V,2)), todel)
	return W[:,tokeep]
end

W = nonpresi(V,LINES)
GL.VIEW(
	[

		GL.GLPoints(convert(Lar.Points,V'))
		#GL.GLPoints(convert(Lar.Points,W'),GL.COLORS[2])
		GL.GLGrid(L,EL)
		#GL.GLPoints(convert(Lar.Points,pointsonline.points'))
		#GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
	]
);
