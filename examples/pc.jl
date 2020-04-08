using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

using ViewerGL
GL = ViewerGL
include("viewfunction.jl")
V,(VV,EV,FV,CV) = Lar.cuboid([2,5,1],true)
rgb = rand(3,8)
#
# V1,(VV1,EV1,FV1,CV1) = Lar.cuboid([10,6,9],true)
# model = Lar.apply(Lar.t(1,2,3),Lar.apply(Lar.r(pi/4,0,0),(V,FV)))
# model1 = Lar.apply(Lar.t(5,6,7),Lar.apply(Lar.r(0,-pi/6,0),(V1,FV1)))
tri = Lar.quads2triangles(FV)
model = V,tri
GL.VIEW([
	colorview(V,tri,rgb)
	#colorview(modelXZ...,rgb)
	#GL.GLGrid(model1...,)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);


R=[0. 1 0 0 ; 0 0 1 0; 1 0 0 0; 0 0 0 1] #YZ giustaFV
R2=[0. 0 1 0 ; 0 1 0 0; 1 0 0 0; 0 0 0 1] #YZ sbagliata

R=[1 0 0 0; 0 0 1 0; 0 -1 0 0; 0 0 0 1]
R=[0 -1 0 0 ; 0 0 1 0; -1 0 0 0; 0 0 0 1]
modelXZ=Lar.apply(R,model)

GL.VIEW([
	# colorview(V,tri,rgb)
	colorview(modelXZ...,rgb)
	#GL.GLGrid(model1...,)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);

modelYZsbagliata=Lar.apply(R2,model)
GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,model[1]'))
	#GL.GLPoints(convert(Lar.Points,model1[1]'))
	GL.GLGrid(modelYZsbagliata...,GL.COLORS[5])
	GL.GLGrid(modelYZgiusta...,GL.COLORS[2])
	GL.GLGrid(model...,)
	GL.GLAxis(GL.Point3d(0,0,0),GL.Point3d(1,1,1))
]);


R=[0. 0 1 0 ; 1 0 0 0; 0 1 0 0; 0 0 0 1] #XZ giusta
R2=[1. 0 0 0 ; 0 0 1 0; 0 1 0 0; 0 0 0 1] #XZ sbagliata
modelYZgiusta=Lar.apply(R,model)
modelYZsbagliata=Lar.apply(R2,model)
GL.VIEW([
	#GL.GLPoints(convert(Lar.Points,model[1]'))
	#GL.GLPoints(convert(Lar.Points,model1[1]'))
	GL.GLGrid(modelYZsbagliata...,GL.COLORS[5])
	GL.GLGrid(modelYZgiusta...,GL.COLORS[2])
	GL.GLGrid(model...,)
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


"""
 Y è la reference cloud
 X la source cloud
"""
function ICP(X,Y)
	x=X[1,:]
	y=X[2,:]
	u=Y[1,:]
	v=Y[2,:]
	sx2=Lar.norm(x)^2
	sxy=Lar.dot(x,y)
	sx=sum(x)
	sy2=Lar.norm(y)^2
	sy=sum(y)
	n=size(X,2)
	sux=Lar.dot(u,x)
	suy=Lar.dot(u,y)
	su=sum(u)
	svx=Lar.dot(v,x)
	svy=Lar.dot(v,y)
	sv=sum(v)
	A=[ sx2 sxy sx 0 0 0;
		sxy sy2 sy 0 0 0;
		sx  sy  n  0 0 0;
		0 0 0  sx2 sxy sx;
		0 0 0  sxy sy2 sy;
		0 0 0  sx  sy  n]
	b=[sux, suy, su, svx, svy, sv]
	params=A\b

	R=[ params[1] params[2];
		params[4] params[5]]

	t=[params[3], params[6]]
	return R,t
end



function iterativeICP(X,Y,itermax)
	x=copy(X)
	iter=1
	R=Matrix(Lar.I,2,2)
	T=[0,0]
	error=diff=Inf
	while diff>1.e-8 && iter<itermax
		r,t = ICP(x,Y)
		R=r*R
		T=r*T+t
		diff=Lar.abs(error-residuo(R,T,X,Y))
		error=residuo(R,T,X,Y)
		@show diff
		x=r*x.+t
		iter+=1
	end
	return R,T,iter,error
end


function residuo(R,T,X,Y)
	error = Lar.abs(Lar.norm(R*X.+T.-Y)^2)
	return error
end

X=rand(2,1000)

# R = [0.5 0 0.866025; 0.866025 0 -0.5; 0 1 0]
# t = [1,1,1]

r = [0.5 -sqrt(3)/2; sqrt(3)/2 0.5]
t = [1,2]
s=[1.4 0;0 0.5]

Y = r*s*X.+t
Y = AlphaStructures.matrixPerturbation(Y,atol=0.01)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,X'))
	GL.GLPoints(convert(Lar.Points,Y'), GL.COLORS[2])
	GL.GLFrame2
]);


R,T=ICP(X,Y)
X2 = R*X.+T
residuo(R,T,X,Y)
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,X2'))
	GL.GLPoints(convert(Lar.Points,Y'), GL.COLORS[2])
	GL.GLFrame2
]);


R,T,iter,er=iterativeICP(X,Y,1000)
residuo(R,T,X,Y)
X2 = R*X.+T
GL.VIEW([
	GL.GLPoints(convert(Lar.Points,X2'))
	GL.GLPoints(convert(Lar.Points,Y'), GL.COLORS[2])
	GL.GLFrame2
]);
