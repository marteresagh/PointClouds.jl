"""
Initialize usefull parameters.
"""
function initparams(
	txtpotreedirs::String,
	bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	GSD::Float64,
	PO::String,
	quota::Union{Float64,Nothing},
	thickness::Union{Float64,Nothing},
	ucs::Union{Nothing,String}
	)

	# check validity
	@assert isfile(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
	@assert length(PO)==3 "orthoprojectionimage: $PO not valid view"

	potreedirs = PointClouds.getdirectories(txtpotreedirs)
	model = PointClouds.getmodel(bbin)

	if isnothing(ucs)
		coordsystemmatrix = PointClouds.string2matrix(PO)
	else
		UCS = PointClouds.ucsJSON2matrix(ucs)
		coordsystemmatrix = PointClouds.string2matrix(PO,UCS)
	end


	if !isnothing(quota)
		if PO == "XY+" || PO == "XY-"
			puntoquota = [0,0,quota]
		elseif PO == "XZ+" || PO == "XZ-"
			puntoquota = [0, quota, 0]
		elseif PO == "YZ+" || PO == "YZ-"
			puntoquota = [quota, 0, 0]
		end

		@assert !isnothing(thickness) "orthoprojectionimage: thickness missing"
		q_l = (coordsystemmatrix*puntoquota)[3] - thickness/2
		q_u = (coordsystemmatrix*puntoquota)[3] + thickness/2
	else
		q_l = -Inf
		q_u = Inf
	end

	RGBtensor, rasterquote, refX, refY = PointClouds.initrasterarray(coordsystemmatrix,GSD,model)

	aabb = Lar.boundingbox(model[1])
	mainHeader = newHeader(aabb,"ORTHOPHOTO",26)
	return  potreedirs, model, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, q_l, q_u, mainHeader
end


"""
Save orthophoto.
"""
function saveorthophoto(
	outputimage::String,
	PO::String,
	RGBtensor,
	GSD::Float64,
	refX,
	refY,
	)

	PointClouds.flushprintln("Image: saving ...")

	if PO == "XY+"
		savetfw(outputimage, GSD, refX, refY)
	end

	save(outputimage, Images.colorview(RGB, RGBtensor))
	PointClouds.flushprintln("Image: done ...")
end

"""
Save point cloud extracted.
"""
function savepointcloud(
	outputimage::String,
	n::Int64,
	temp,
	mainHeader
	)


	PointClouds.flushprintln("Point cloud: saving ...")

	outputfile = splitext(outputimage)[1]*".las"

	mainHeader.records_count = n
	pointtype = pointformat(mainHeader)

	open(temp) do s
		open(outputfile,"w") do t
			write(t, LasIO.magic(LasIO.format"LAS"))
			write(t, mainHeader)

			LasIO.skiplasf(s)
			for i=1:n
				p = read(s, pointtype)
				write(t,p)
			end
		end
	end

	rm(temp)
	PointClouds.flushprintln("Point cloud: done ...")
end

"""
update image tensor.
"""
function updateimagewithfilter!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    _, model, _ = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        if PointClouds.inmodel(model)(point) # se il punto è interno allora
			n = update_main(params,laspoint,h,n,s)
        end
    end

	return n
end

function updateimage!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    _, model, _ = params

    for laspoint in laspoints
		n = update_main(params,laspoint,h,n,s)
    end

	return n
end

function update_main(params,laspoint,h,n,s)
	potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc, mainHeader = params
	point = PointClouds.xyz(laspoint,h)
	rgb = PointClouds.color(laspoint,h)
	p = coordsystemmatrix*point
	xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
	ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

	if p[3] >= q_l && p[3] <= q_u
		if pc
			plas = PointClouds.newPointRecord(laspoint,h,LasIO.LasPoint2,mainHeader)
			write(s,plas)
			n=n+1
		end
		if rasterquote[ycoord,xcoord] < p[3]
			rasterquote[ycoord,xcoord] = p[3]
			RGBtensor[1, ycoord, xcoord] = rgb[1]
	        RGBtensor[2, ycoord, xcoord] = rgb[2]
	        RGBtensor[3, ycoord, xcoord] = rgb[3]
		end
	end
	return n
end

"""
imagecreation con i trie
"""
function pointselection(params,s,n::Int64)
	potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc, mainHeader = params
    for potree in potreedirs
        PointClouds.flushprintln( "======== PROJECT $potree ========")
		typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree)

		trie = PointClouds.triepotree(potree)

		l=length(keys(trie))
		if PointClouds.modelsdetection(model, tightBB) == 2
			PointClouds.flushprintln("FULL model")
			i=1
			for k in keys(trie)
				if i%100==0
					PointClouds.flushprintln(i," files processed of ",l)
				end
				file = trie[k]
				n = PointClouds.updateimage!(params,file,s,n)
				i = i+1
			end
		else
			PointClouds.flushprintln("DFS")
			n,_ = PointClouds.dfsimage(trie,params,s,n,0,l)
		end
	end

	return n
end

"""
Trie DFS.
"""
function dfsimage(t,params,s,n::Int64,nfiles,l)
	_, model, _ = params
	file = t.value
	nodebb = PointClouds.las2aabb(file)
	inter = PointClouds.modelsdetection(model, nodebb)
	if inter == 1
		nfiles = nfiles+1
		if nfiles%100==0
			PointClouds.flushprintln(nfiles," files processed of ",l)
		end
		n = PointClouds.updateimagewithfilter!(params,file,s,n)
		for key in collect(keys(t.children))
			n,nfiles = PointClouds.dfsimage(t.children[key],params,s,n,nfiles,l)
		end
	elseif inter == 2
		for k in keys(t)
			nfiles = nfiles+1
			if nfiles%100==0
				PointClouds.flushprintln(nfiles," files processed of ",l)
			end
			file = t[k]
			n = PointClouds.updateimage!(params,file,s,n)
		end
	end
	return n,nfiles
end

"""
API
"""
function orthophoto_main(
	outputimage::String,
	potreedirs,
	model::Lar.LAR,
	coordsystemmatrix,
	GSD,
	RGBtensor,
	rasterquote,
	refX,
	refY,
	q_l,
	q_u,
	pc::Bool,
	mainHeader::LasIO.LasHeader,
	n::Int
	)

	params = potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc, mainHeader

	if pc
		temp = joinpath(splitdir(outputimage)[1],"temp.las")
		open(temp, "w") do s
			write(s, LasIO.magic(LasIO.format"LAS"))
			n = PointClouds.pointselection(params,s,n)
			return n, temp
		end
	else
		n = PointClouds.pointselection(params,nothing,n)
		return n, nothing
	end

end

function orthophoto(
	txtpotreedirs::String,
	outputimage::String,
	bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	GSD::Float64,
	PO::String,
	quota::Union{Float64,Nothing},
	thickness::Union{Float64,Nothing},
	ucs::Union{String,Nothing},
	pc::Bool
	)

	# initialization
	potreedirs, model, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, q_l, q_u, mainHeader =
	PointClouds.initparams( txtpotreedirs,	bbin, GSD,	PO,	quota,	thickness,	ucs);


	# image creation
	PointClouds.flushprintln("========= PROCESSING =========")

	n = 0 #number of extracted points
	n, temp = PointClouds.orthophoto_main(outputimage, potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc, mainHeader, n)

	PointClouds.flushprintln("========= SAVES =========")
	PointClouds.saveorthophoto( outputimage, PO, RGBtensor, GSD, refX, refY)

	if pc
		PointClouds.savepointcloud( outputimage, n, temp, mainHeader)
	end
end
