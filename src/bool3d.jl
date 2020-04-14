
function spaceindex(point3d::Array{Float64,1})::Function
	function spaceindex0(model::Lar.LAR)::Array{Int,1}
		V,CV = copy(model[1]),copy(model[2])
		V = [V point3d]
		dim, idx = size(V)
		push!(CV, [idx,idx,idx])
		cellpoints = [ V[:,CV[k]]::Lar.Points for k=1:length(CV) ]

		#----------------------------------------------------------
		bboxes = [hcat(Lar.boundingbox(cell)...) for cell in cellpoints]
		xboxdict = Lar.coordintervals(1,bboxes)
		yboxdict = Lar.coordintervals(2,bboxes)
		# xs,ys are IntervalTree type
		xs = Lar.IntervalTrees.IntervalMap{Float64, Array}()
		for (key,boxset) in xboxdict
			xs[tuple(key...)] = boxset
		end
		ys = Lar.IntervalTrees.IntervalMap{Float64, Array}()
		for (key,boxset) in yboxdict
			ys[tuple(key...)] = boxset
		end


		xcovers = Lar.boxcovering(bboxes, 1, xs)
		ycovers = Lar.boxcovering(bboxes, 2, ys)

		covers = [intersect(pair...) for pair in zip(xcovers,ycovers)]

		# add new code part

		# remove each cell from its cover
		pointcover = sort(setdiff(covers[end],[idx+1]))

		return pointcover[1:end-1]
	end
	return spaceindex0
end


"""
	testinternalpoint(V::Lar.Points, EV::Lar.Cells, FV::Lar.Cells)
"""
function testinternalpoint(V,EV,FV)
	copEV = Lar.lar2cop(EV)
	copFV = Lar.lar2cop(FV)
	copFE = copFV * copEV'
	I,J,Val = findnz(copFE)
	triple = zip([(i,j,1) for (i,j,v) in zip(I,J,Val) if v==2]...)
	I,J,Val = map(collect,triple)
	Val = convert(Array{Int8,1},Val)
	copFE = sparse(I,J,Val)
	function testinternalpoint0(testpoint)
		intersectedfaces = Int64[]
		# spatial index for possible intersections with ray
		faces = PointClouds.spaceindex(testpoint)((V,FV))
		depot = []
		# face in faces :  indices of faces of possible intersection with ray
		for face in faces
			value = Lar.rayintersection(testpoint)(V,FV,face)
			if typeof(value) == Array{Float64,1} push!(depot, (face,value)) end
		end
		# actual containment test of ray point in faces within depot
		for (face,point3d) in depot
			vs, edges, point2d = Lar.planemap(V,copEV,copFE,face)(point3d)
			classify = Lar.pointInPolygonClassification(vs,edges)
			inOut = classify(point2d)
			if inOut!="p_out"
				push!(intersectedfaces,face)
			end
		end
		return intersectedfaces
	end
	return testinternalpoint0
end
