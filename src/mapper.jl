function cone(radius, height, ang=2*pi)
    function cone0(shape=[36, 1])
        V, CV = Lar.cuboidGrid(shape)
		CV = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV]
		CV = reduce(append!,CV)
        V = [ang/shape[1] 0.0 ; 0.0 height/shape[2]]*V
        W = [V[:, k] for k=1:size(V, 2)]
		apex = [0.;0.;0.]
        V = hcat(map(p->let(theta, v)=p;[v/height*radius*cos(theta);v/height*radius*sin(theta);
        	v] end, W)...)
		index = PointClouds.matchcolumn(apex,V)
        W, CW = Lar.simplifyCells(V, CV)
		for cell in CW
			if length(cell)<3
				append!(cell,index)
			end
		end
        return W, CW
    end
    return cone0
end

function paraboloid(radii,ang=2*pi)
	a,b,c = radii
    function paraboloid0(shape=[36, 36])
		V, CV = Lar.cuboidGrid(shape)
		CV = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV]
		CV = reduce(append!,CV)
        V = [ang/shape[1] 0.0 ; 0.0 1.0/shape[2]]*V
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(v,u)=p;[a*sqrt(u/c)*cos(v),b*sqrt(u/c)*sin(v),c*u] end, W)...)
		apex = [0.;0.;0.]
		index = PointClouds.matchcolumn(apex,V)
        W, CW = Lar.simplifyCells(V, CV)
		for cell in CW
			if length(cell)<3
				append!(cell,index)
			end
		end
        return W, CW
    end
    return paraboloid0
end

function hyperboloid(params,ang=2*pi)
	a,b,c = params
    function hyperboloid0(shape=[36, 36])
		V0, CV0 = Lar.cuboidGrid(shape)
		V1, CV1 = Lar.cuboidGrid(shape)
		CV0 = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV0]
		CV0 = reduce(append!,CV0)
		CV1 = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV1]
		CV1 = reduce(append!,CV1)
		CV1 = [CV1[i].+size(V0,2) for i in 1:length(CV1)]
        V0 = [ang/shape[1] 0.0 ; 0.0 1.0/shape[2]]*V0
		V1 = [ang/shape[1] 0.0 ; 0.0 -1.0/shape[2]]*V1
        W0 = [V0[:, k] for k=1:size(V0, 2)]
		W1 = [V1[:, k] for k=1:size(V1, 2)]
		W = vcat(W0,W1)
		CV = union(CV0,CV1)
        V = hcat(map(p->let(u, v)=p;[a*sqrt(1+v^2)*cos(u);b*sqrt(1+v^2)*sin(u);c*v] end, W)...)
        W, CW = Lar.simplifyCells(V, CV)
        return W, CW
    end
    return hyperboloid0
end


function ellipsoid(params,ang1=pi,ang2=2*pi)
	a,b,c = params
    function ellipsoid0(shape=[18, 36])
        V, CV = Lar.simplexGrid(shape)
        V = [ang1/shape[1] 0;0 ang2/shape[2]]*V
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[a*cos(u)*sin(v);
        	b*sin(u)*sin(v);c*cos(v)]end, W)...)
        W, CW = Lar.simplifyCells(V, CV)
        CW = [triangle for triangle in CW if length(triangle)==3]
		return W,CW
    end
    return ellipsoid0
end


function cylinderellip(radii, angle=2*pi)
	a,b,c=radii
    function cylinder0(shape=[36, 1])
        V, CV = Lar.cuboidGrid(shape)
		CV = [[[u,v,w],[w,v,t]] for (u,v,w,t) in CV]
		CV = reduce(append!,CV)
        V = [angle/shape[1] 0.0 ; 0.0 1.0/shape[2]]*V
        W = [V[:, k] for k=1:size(V, 2)]
        V = hcat(map(p->let(u, v)=p;[a*cos(u);b*sin(u);
        	c*v] end, W)...)
        W, CW = Lar.simplifyCells(V, CV)
        return W, CW
    end
    return cylinder0
end
