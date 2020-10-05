mutable struct ParametersExtraction
	outputfile::String
	potreedirs::Array{String,1}
	coordsystemmatrix::Array{Float64,2}
	model::Lar.LAR
	q_l::Float64
	q_u::Float64
	mainHeader::LasIO.LasHeader
end

"""
Save extracted pc in a file.
"""
function pointExtraction(
     txtpotreedirs::String,
	 outputfile::String,
	 coordsystemmatrix::Array{Float64,2},
	 bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	 quota::Union{Float64,Nothing},
	 thickness::Union{Float64,Nothing},
	  )


    params = initParamsExtraction(   txtpotreedirs::String,
									 outputfile::String,
									 coordsystemmatrix::Array{Float64,2},
									 bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
									 quota::Union{Float64,Nothing},
									 thickness::Union{Float64,Nothing}
									 )

	n = 0
	temp = joinpath(splitdir(params.outputfile)[1],"temp.las")
	open(temp, "w") do s
		write(s, LasIO.magic(LasIO.format"LAS"))
    	n = PointClouds.processfiles(params,s,n)
	end

	PointClouds.savepointcloud( params, n, temp)

end


"""
init
"""
function initParamsExtraction(txtpotreedirs::String,
							 outputfile::String,
							 coordsystemmatrix::Array{Float64,2},
							 bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
							 quota::Union{Float64,Nothing},
							 thickness::Union{Float64,Nothing}
							 )
	# check validity
	@assert isfile(txtpotreedirs) "extractpointcloud: $txtpotreedirs not an existing file"

	if !isnothing(quota)
		@assert !isnothing(thickness) "extractpointcloud: thickness missing"
		q_l = quota - thickness/2
		q_u = quota + thickness/2
	else
		q_l = -Inf
		q_u = Inf
	end

	potreedirs = PointClouds.getdirectories(txtpotreedirs)
	model = PointClouds.getmodel(bbin)
	aabb = Lar.boundingbox(model[1])
	mainHeader = newHeader(aabb,"EXTRACTION",SIZE_DATARECORD)

	return ParametersExtraction(outputfile,
								potreedirs,
								coordsystemmatrix,
								model,
								q_l,
								q_u,
								mainHeader)
end

"""
process file in trie.
"""
function processfiles(params::ParametersExtraction,s,n::Int64)

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
				n = PointClouds.updatepoints!(params,file,s,n)
				i=i+1
			end
		else
			PointClouds.flushprintln("DFS")
			n,_ = PointClouds.dfsextraction(trie,params,s,n,0,l)
		end
	end
	return n
end

"""
save points in a temporary file
"""
function updatepointswithfilter!(params::ParametersExtraction,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
		p = params.coordsystemmatrix*point
        if PointClouds.inmodel(params.model)(point) # se il punto è interno allora
			if p[3] >= params.q_l && p[3] <= params.q_u
				plas = PointClouds.newPointRecord(laspoint,h,LasIO.LasPoint2,params.mainHeader)
				write(s,plas)
				n=n+1
			end
        end
    end
	return n
end

function updatepoints!(params::ParametersExtraction,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    for laspoint in laspoints
		point = PointClouds.xyz(laspoint,h)
		p = params.coordsystemmatrix*point
		if p[3] >= params.q_l && p[3] <= params.q_u
			plas = PointClouds.newPointRecord(laspoint,h,LasIO.LasPoint2,params.mainHeader)
			write(s,plas)
			n=n+1
		end
    end
	return n
end

"""
Trie DFS.
"""
function dfsextraction(t,params::ParametersExtraction,s,n,nfiles,l)
	file = t.value
	nodebb = PointClouds.las2aabb(file)
	inter = PointClouds.modelsdetection(params.model, nodebb)
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
