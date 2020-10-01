mutable struct ParametersExtraction
	outputfile::String
	potreedirs::Array{String,1}
	model::Lar.LAR
	q_l::Float64
	q_u::Float64
	mainHeader::LasIO.LasHeader
end


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
	temp = joinpath(splitdir(outputfile)[1],"temp.las")
    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)
    params = model, q_l, q_u
	n = 0
	open(temp, "w") do s
		write(s, LasIO.magic(LasIO.format"LAS"))
    	n,header = PointClouds.processfiles(potreedirs,params,s,n)
	end

	PointClouds.flushprintln("create las file")
	#n = quello che mi ritorna
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
	PointClouds.flushprintln("point cloud saved in $outputfile")

end



"""
process file in trie.
"""
function processfiles(potreedirs::Array{String,1},params,s,n::Int64)
	model, q_l, q_u = params

    for potree in potreedirs
        PointClouds.flushprintln( "======== PROJECT $potree ========")
		typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree)

		trie = PointClouds.triepotree(potree)
		header = LasIO.read_header(trie[""])
		global header
		params = model, q_l, q_u, header
		l=length(keys(trie))
		if PointClouds.modelsdetection(model, tightBB) == 2
			PointClouds.flushprintln("FULL model")
			i=1
			for k in keys(trie)
				if i%100==0
					PointClouds.flushprintln(i," files processed of ",l)
				end
				file = trie[k]
				n = PointClouds.updatepoints!(params,file,s,n)
				i=i+1
			end
		else
			PointClouds.flushprintln("DFS")
			n,_ = PointClouds.dfsextraction(trie,params,s,n,0,l)
		end
	end
	return n,header
end

"""
save points in a temporary file
"""
function updatepointswithfilter!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    model, q_l, q_u, header = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        if PointClouds.inmodel(model)(point) # se il punto è interno allora
			if point[3] >= q_l && point[3] <= q_u
				p = PointClouds.createlasdata(laspoint,h,header)
				write(s,p)
				n=n+1
			end
        end
    end
	return n
end

function updatepoints!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    model, q_l, q_u, header = params
    for laspoint in laspoints
		point = PointClouds.xyz(laspoint,h)
		if point[3] >= q_l && point[3] <= q_u
			p = PointClouds.createlasdata(laspoint,h,header)
			write(s,p)
			n=n+1
		end
    end
	return n
end

"""
Trie DFS.
"""
function dfsextraction(t,params,s,n,nfiles,l)
	model, _ = params
	file = t.value
	nodebb = PointClouds.las2aabb(file)
	inter = PointClouds.modelsdetection(model, nodebb)
	if inter == 1
		nfiles = nfiles+1
		if nfiles%100==0
			PointClouds.flushprintln(nfiles," files processed of ",l)
		end
		n = PointClouds.updatepointswithfilter!(params,file,s,n)
		for key in collect(keys(t.children))
			n,nfiles = PointClouds.dfsextraction(t.children[key],params,s,n,nfiles,l)
		end
	elseif inter == 2
		for k in keys(t)
			nfiles = nfiles+1
			if nfiles%100==0
				PointClouds.flushprintln(nfiles," files processed of ",l)
			end
			file = t[k]
			n = PointClouds.updatepoints!(params,file,s,n)
		end
	end
	return n, nfiles
end
