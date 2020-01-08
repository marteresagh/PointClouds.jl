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
