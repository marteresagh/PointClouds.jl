mutable struct ParametersOrthophoto
	PO::String
	outputimage::String
	outputfile::String
	potreedirs::Array{String,1}
	model::Lar.LAR
	coordsystemmatrix::Array{Float64,2}
	RGBtensor::Array{Float64,3}
	rasterquote::Array{Float64,2}
	GSD::Float64
	refX::Float64
	refY::Float64
	q_l::Float64
	q_u::Float64
	pc::Bool
	ucs::Union{Nothing,String}
	mainHeader::LasIO.LasHeader
end

"""
Initialize usefull parameters.
"""
function initparams(
	txtpotreedirs::String,
	outputimage::String,
	bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	GSD::Float64,
	PO::String,
	quota::Union{Float64,Nothing},
	thickness::Union{Float64,Nothing},
	ucs::Union{Nothing,String},
	pc::Bool
	)

	# check validity
	@assert isfile(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
	@assert length(PO)==3 "orthoprojectionimage: $PO not valid view"


	outputfile = splitext(outputimage)[1]*".las"

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
	mainHeader = newHeader(aabb,"ORTHOPHOTO",SIZE_DATARECORD)
	return  ParametersOrthophoto(PO,
					 outputimage,
					 outputfile,
					 potreedirs,
					 model,
					 coordsystemmatrix,
					 RGBtensor,
					 rasterquote,
					 GSD,
					 refX,
					 refY,
					 q_l,
					 q_u,
					 pc,
					 ucs,
					 mainHeader)
end


"""
Save orthophoto.
"""
function saveorthophoto(params::ParametersOrthophoto)

	PointClouds.flushprintln("Image: saving ...")

	if params.PO == "XY+"
		savetfw(params.outputimage, params.GSD, params.refX, params.refY)
	end

	save(params.outputimage, Images.colorview(RGB, params.RGBtensor))
	PointClouds.flushprintln("Image: done ...")
end


"""
update image tensor.
"""
function updateimagewithfilter!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        if PointClouds.inmodel(params.model)(point) # se il punto è interno allora
			n = update_main(params,laspoint,h,n,s)
        end
    end

	return n
end

function updateimage!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)

    for laspoint in laspoints
		n = update_main(params,laspoint,h,n,s)
    end

	return n
end

function update_main(params,laspoint,h,n,s)
	point = PointClouds.xyz(laspoint,h)
	rgb = PointClouds.color(laspoint,h)
	p = params.coordsystemmatrix*point
	xcoord = map(Int∘trunc,(p[1]-params.refX) / params.GSD)+1
	ycoord = map(Int∘trunc,(params.refY-p[2]) / params.GSD)+1

	if p[3] >= params.q_l && p[3] <= params.q_u
		if params.pc
			plas = PointClouds.newPointRecord(laspoint,h,LasIO.LasPoint2,params.mainHeader)
			write(s,plas)
			n=n+1
		end
		if params.rasterquote[ycoord,xcoord] < p[3]
			params.rasterquote[ycoord,xcoord] = p[3]
			params.RGBtensor[1, ycoord, xcoord] = rgb[1]
	        params.RGBtensor[2, ycoord, xcoord] = rgb[2]
	        params.RGBtensor[3, ycoord, xcoord] = rgb[3]
		end
	end
	return n
end

"""
imagecreation con i trie
"""
function pointselection(params::ParametersOrthophoto,s,n::Int64)
    for potree in params.potreedirs
        PointClouds.flushprintln( "======== PROJECT $potree ========")
		typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree)

		trie = PointClouds.triepotree(potree)

		l=length(keys(trie))
		if PointClouds.modelsdetection(params.model, tightBB) == 2
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
function dfsimage(t,params::ParametersOrthophoto,s,n::Int64,nfiles,l)
	file = t.value
	nodebb = PointClouds.las2aabb(file)
	inter = PointClouds.modelsdetection(params.model, nodebb)
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
function orthophoto_main(params::ParametersOrthophoto,n::Int)

	if params.pc
		temp = joinpath(splitdir(params.outputimage)[1],"temp.las")
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
	params = PointClouds.initparams( txtpotreedirs, outputimage, bbin, GSD,	PO,	quota,	thickness,	ucs, pc);


	# image creation
	PointClouds.flushprintln("========= PROCESSING =========")

	n = 0 #number of extracted points
	n, temp = PointClouds.orthophoto_main(params, n)

	PointClouds.flushprintln("========= SAVES =========")
	PointClouds.saveorthophoto(params)

	if pc
		PointClouds.savepointcloud( params, n, temp)
	end
end
