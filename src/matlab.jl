"""
	lar2matlab(V::Lar.Points)

"""
function lar2matlab(V::Lar.Points)
	dim = size(V,1)
    x = V[1,:]
    y = V[2,:]
	if dim == 3
    	z = V[3,:]
		return x,y,z
	end
    return x,y
end

"""
	mat3DT(V::Lar.Points)

3D Delaunay triangulation algorithm in MATLAB.
"""
function mat3DT(V::Lar.Points)
	x,y,z = Tesi.lar2matlab(V)
	@mput x
	@mput y
	@mput z
	mat"DT = delaunay(x,y,z)"
	@mget DT
	DT = convert(Array{Int64,2},DT)
	DT = [DT[i,:] for i in 1:size(DT,1)]
	return DT
end



"""
	DTprojxy(V::Lar.Points)

Delaunay triangulation projected on xy plane with MATLAB algorithm.
"""
function DTprojxy(V::Lar.Points)
	x,y,z = Tesi.lar2matlab(V)
	@mput x
	@mput y
	mat"DT = delaunay(x,y)"
	@mget DT
	DT = convert(Array{Int64,2},DT)
	DT = [DT[i,:] for i in 1:size(DT,1)]
	return DT
end
