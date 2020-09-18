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
	)

	# check validity
	@assert isfile(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
	@assert length(PO)==3 "orthoprojectionimage: $PO not valid view"

	potreedirs = PointClouds.getdirectories(txtpotreedirs)
	model = PointClouds.getmodel(bbin)
	coordsystemmatrix = PointClouds.newcoordsyst(PO)

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
	return  potreedirs, model, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, q_l, q_u
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

	PointClouds.flushprintln("========= Image: saving ... =========")

	if PO == "XY+"
		savetfw(outputimage, GSD, refX, refY)
	end

	save(outputimage, Images.colorview(RGB, RGBtensor))
end

"""
Save point cloud extracted.
"""
function savepointcloud(
	outputimage::String,
	n::Int64,
	temp,
	potreedirs
	)

	PointClouds.flushprintln("========= Point cloud: saving ... =========")

	outputfile = splitext(outputimage)[1]*".las"

	header = LasIO.read_header(filelevel(potreedirs[1],0))
	header.records_count = n
	pointtype = pointformat(header)

	open(temp) do s
		open(outputfile,"w") do t
			write(t, LasIO.magic(LasIO.format"LAS"))
			write(t, header)

			LasIO.skiplasf(s)
			for i=1:n
				p = read(s, pointtype)
				write(t,p)
			end
		end
	end

	rm(temp)
end

"""
update image tensor.
"""
function updateimagewithfilter!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        if PointClouds.inmodel(model)(point) # se il punto è interno allora
            rgb = PointClouds.color(laspoint,h)
            p = coordsystemmatrix*point
            xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
            ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

			if p[3] >= q_l && p[3] <= q_u
				if pc
					plas = PointClouds.createlasdata(laspoint,h,header)
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
        end
    end

	return n

end

function updateimage!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        rgb = PointClouds.color(laspoint,h)
        p = coordsystemmatrix*point
        xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
        ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

		if p[3] >= q_l && p[3] <= q_u
			if pc
				plas = PointClouds.createlasdata(laspoint,h,header)
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
    end

	return n

end

"""
imagecreation con i trie
"""
function pointselection(params,s,n::Int64)
	potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc = params
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
				i=i+1
			end
		else
			PointClouds.flushprintln("DFS")
			n,_ = PointClouds.dfsimage(trie,params,s,n,0,l)
		end
	end

	return RGBtensor,n
end


"""
Trie DFS.
"""
function dfsimage(t,params,s,n::Int64,nfiles,l)
	model, _ = params
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
function orthophoto(
	txtpotreedirs::String,
	outputimage::String,
	bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	GSD::Float64,
	PO::String,
	quota::Union{Float64,Nothing},
	thickness::Union{Float64,Nothing},
	pc::Bool
	)

	# initialization
	PointClouds.flushprintln("========= initialization =========")
	potreedirs, model, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, q_l, q_u = initparams( txtpotreedirs, outputimage, bbin, GSD, PO, quota, thickness, pc );


	# image creation
	PointClouds.flushprintln("========= image creation =========")

	n = 0 #number of extracted points
	params = potreedirs, model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc
	if pc
		temp = joinpath(splitdir(outputimage)[1],"temp.las")
		open(temp, "w") do s
			write(s, LasIO.magic(LasIO.format"LAS"))
			RGBtensor,n = PointClouds.pointselection(params,s,n)
		end
	else
		RGBtensor,n = PointClouds.pointselection(potreedirs,params,nothing,n)
	end

	PointClouds.flushprintln("========= saving =========")
	PointClouds.saveorthophoto( outputimage, PO, RGBtensor, GSD, refX, refY)

	if pc
		PointClouds.savepointcloud( outputimage, n, temp)
	end
end
