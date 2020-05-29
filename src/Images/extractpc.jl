"""
Save extracted pc in a file.
"""
function extractpointcloud(
     txtpotreedirs::String,
	 outputfile::String,
	 bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	 quota::Union{Float64,Nothing},
	 thickness::Union{Float64,Nothing},
	  )

    # check validity
    @assert isfile(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"

	if !isnothing(quota)
		@assert !isnothing(thickness) "orthoprojectionimage: thickness missing"
		q_l = quota - thickness/2
		q_u = quota + thickness/2
	else
		q_l = -Inf
		q_u = Inf
	end

	# initialization
    PointClouds.flushprintln("initialization")

    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)
	headers = LasIO.LasHeader[] # all headers
	arraylaspoint = Array{LasIO.LasPoint,1}[]
    params = model, q_l, q_u, arraylaspoint, headers

    RGBtensor = PointClouds.processfiles(potreedirs,params)

	header, pointdata = PointClouds.mergelas(headers,arraylaspoint)
	PointClouds.savenewlas(outputfile,header,pointdata)
	PointClouds.flushprintln("point cloud saved in $outputfile")

end



"""
imagecreation con i trie
"""
function processfiles(potreedirs::Array{String,1},params)
	model, q_l, q_u, arraylaspoint, headers = params
    for potree in potreedirs
        PointClouds.flushprintln( "======== PROJECT $potree ========")
		typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree)

		trie = PointClouds.triepotree(potree)
		if PointClouds.modelsdetection(model, tightBB) == 2
			PointClouds.flushprintln("FULL model")
			i=1
			l=length(keys(trie))
			for k in keys(trie)
				if i%100==0
					PointClouds.flushprintln(i," files processed of ",l)
				end
				file = trie[k]
				PointClouds.updatepoints!(params,file)
				i=i+1
			end
		else
			PointClouds.flushprintln("DFS")
			PointClouds.dfsimage(trie,params)
		end
	end
    return RGBtensor
end



"""
aggiorna l'immagine.
"""
function updatepointswithfilter!(params,file)
	header, laspoints =  PointClouds.readpotreefile(file)
    model, q_l, q_u, arraylaspoint, headers = params

	pointstaken = LasIO.LasPoint[]

	if pc
		push!(headers,header)
	end

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,header)
        if PointClouds.inmodel(model)(point) # se il punto è interno allora
			if p[3] >= q_l && p[3] <= q_u
				if pc
					push!(pointstaken,laspoint)
				end
			end
        end
    end

	if pc
		push!(arraylaspoint,pointstaken)
	end
end

function updatepoints!(params,file)
	header, laspoints =  PointClouds.readpotreefile(file)
    model, q_l, q_u, arraylaspoint, headers = params
	pointstaken = LasIO.LasPoint[]
	if pc
		push!(headers,header)
	end

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,header)
        rgb = PointClouds.color(laspoint,header)
        p = coordsystemmatrix*point
        xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
        ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

		if p[3] >= q_l && p[3] <= q_u
			if pc
				push!(pointstaken,laspoint)
			end
	        if rasterquote[ycoord,xcoord] < p[3]
	        	rasterquote[ycoord,xcoord] = p[3]
	            RGBtensor[1, ycoord, xcoord] = rgb[1]
	            RGBtensor[2, ycoord, xcoord] = rgb[2]
	            RGBtensor[3, ycoord, xcoord] = rgb[3]
	        end
		end
    end
	if pc
		push!(arraylaspoint,pointstaken)
	end
end
