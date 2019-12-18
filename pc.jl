using LinearAlgebraicRepresentation, ViewerGL
Lar = LinearAlgebraicRepresentation
GL = ViewerGL

V,(VV,EV,FV,CV) = Lar.cuboid([5,3,2],true)

V1,(VV1,EV1,FV1,CV1) = Lar.cuboid([10,6,9],true)
model = Lar.apply(Lar.t(1,2,3),Lar.apply(Lar.r(pi/4,0,0),(V,FV)))
model1 = Lar.apply(Lar.t(5,6,7),Lar.apply(Lar.r(0,-pi/6,0),(V1,FV1)))

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,model[1]'))
	GL.GLPoints(convert(Lar.Points,model1[1]'))
	GL.GLGrid(model...)
	GL.GLGrid(model1...)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

# prendo le due origini
O = model[1][:,1]
O1 = model1[1][:,1]

# e tutti i punti degli assi
assex=model[1][:,5]-O
assey=model[1][:,3]-O
assez=model[1][:,2]-O

asse1x=model1[1][:,5]-O1
asse1y=model1[1][:,3]-O1
asse1z=model1[1][:,2]-O1

# Assi normalizzati per creare le rotazioni
nassex = assex/Lar.norm(assex)
nassey = assey/Lar.norm(assey)
nassez = assez/Lar.norm(assez)

nassex1 = asse1x/Lar.norm(asse1x)
nassey1 = asse1y/Lar.norm(asse1y)
nassez1 = asse1z/Lar.norm(asse1z)
R=[nassex[1] nassex[2] nassex[3]; nassey[1] nassey[2] nassey[3];nassez[1] nassez[2] nassez[3]]
R1=[nassex1[1] nassex1[2] nassex1[3]; nassey1[1] nassey1[2] nassey1[3]; nassez1[1] nassez1[2] nassez1[3]]

#V2 = R*(model[1].-O)

# calcolo la matrice di scala lunghezza asse pc1 fratto lunghezza asse pc2
S = Lar.Diagonal([Lar.norm(assex)/Lar.norm(asse1x),Lar.norm(assey)/Lar.norm(asse1y),Lar.norm(assez)/Lar.norm(asse1z)])

##### applico la rotazione per portarla nell 'origine e scalarla
V12 = S*R1*(model1[1].-O1)

# la sovrappongo sulla pc1 con la trasformazione inversa di pc1
V1finale = (Lar.inv(R)*V12).+O

GL.VIEW([
	GL.GLPoints(convert(Lar.Points,model[1]'))
	GL.GLPoints(convert(Lar.Points,V1finale'))
	GL.GLGrid(model[1],FV,GL.COLORS[3],0.5)
	GL.GLGrid(V1finale,FV1,GL.COLORS[2],0.5)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);
