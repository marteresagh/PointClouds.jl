# ```


"""
	 AABBdetection(aabb::Tuple{Array{Float64,1},Array{Float64,1}},AABB::Tuple{Array{Float64,1},Array{Float64,1}})::Bool

Compute collision detection of two AABB.

"""
function AABBdetection(aabb,AABB)::Bool
	A=hcat(aabb...)
	B=hcat(AABB...)
	@assert size(A,1) == size(B,1) "AABBdetection: not same dimension"
	dim = size(A,1)
	m=1
	M=2
	# 1. - axis x AleftB = A[1,max]<B[1,min]  ArightB = A[1,min]>B[1,max]
	# 2. - axis y AfrontB = A[2,max]<B[2,min]  AbehindB = A[2,min]>B[2,max]
	if dim == 3
		# 3. - axis z AbottomB = A[3,max]<B[3,min]  AtopB = A[3,min]>B[3,max]
		return !( A[1,M]<=B[1,m] || A[1,m]>=B[1,M] ||
				 A[2,M]<=B[2,m] ||A[2,m]>=B[2,M] ||
				  A[3,M]<=B[3,m] || A[3,m]>=B[3,M] )

	end
	return !( A[1,M]<=B[1,m] || A[1,m]>=B[1,M] ||
			 A[2,M]<=B[2,m] || A[2,m]>=B[2,M] )
end

"""
	readJSON(path::String)

Read a file `.json`.
"""
function readJSON(path::String)
	dict=Dict{String,Any}[]
	open(path * "\\cloud.js", "r") do f
	    dict=JSON.parse(f)  # parse and transform data
	end
	dictAABB = dict["boundingBox"]
	scale = dict["scale"]
	npoints = dict["points"]
	AABB=([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]],
			[dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]])
	octreeDir = dict["octreeDir"]
	hierarchyStepSize = dict["hierarchyStepSize"]
	spacing = dict["spacing"]
	return scale,npoints,AABB,octreeDir,hierarchyStepSize,spacing
end

"""
	segmentcloud(filename::String,
		 from::String, to::String,
		 #= model: poi metto il modello al posto dell'aabb=#
		 aabb::Tuple{Array{Float64,1},Array{Float64,1}})

"""
function segmentcloud(filename::String,
	 from::String, to::String,
	 model
	#=aabb::Tuple{Array{Float64,1},Array{Float64,1}}=#)

	# 1.- initialize
	# info of model
	V,EV,FV = model
	aabb = Lar.boundingbox(V)

	writefile = to*"\\"*filename*".las"
	bb = ([Inf,Inf,Inf],[-Inf,-Inf,-Inf]) # initialize aabb of my finales points

	headers = LasIO.LasHeader[] # all headers
	arraylaspoint = Array{LasIO.LasPoint,1}[] # all points fall in my model

	scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = readJSON(from) # useful parameters
	pathr = from*"\\"*octreeDir*"\\r" # path to directory "r"

	println("search in $pathr ")

	# 2.- check all file
	for (root, dirs, files) in walkdir(pathr)
		l = length(files)
		f = 0
		for file in files
			#@show file
			pointstaken = LasIO.LasPoint[]
			if endswith(file, ".las")
		        fname = joinpath(root, file) # path to files
				AABB = PointClouds.las2aabb(fname) # AABB of octree
				h, pdata = LasIO.FileIO.load(fname) # read data
				if AABBdetection(AABB,aabb) # iff #TODO attenzione ai casi in cui interseca il bb ma non ho punti che ricadono nel modello
					push!(headers,h)
					for p in pdata
						coordpoint = xyz(p,h)
						if !isempty(Lar.testinternalpoint(V,EV,FV)(coordpoint)) # pointinmodel(model,coordpoint) #come lo voglio definire il cilindro??
							bbincremental!(coordpoint,bb)
							push!(pointstaken,p)
						end
					end
					#@show length(pointstaken)
					push!(arraylaspoint,pointstaken)
				end
			end
			#progession
			f = f+1
			if f%100==0
				println("file processed $f of $l")
			end

		end

	end

	# 3.- merge .las and save
 	header, pointdata = mergelas(headers,arraylaspoint,bb,scale)
	savenewlas(writefile,header,pointdata)
	println("file .las saved in $writefile")
	# questi punti li tolgo dall'albero?? cioè da ogni file .las
	return 1
end

"""
	 xyz(p::LasPoint, h::LasHeader)

Return coords of this laspoint p.
"""
function xyz(p::LasPoint, h::LasHeader)
	return [xcoord(p, h); ycoord(p, h); zcoord(p, h)]
end

"""
	savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})

save file .las in writefile.
"""
function savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})
    if ispath(writefile) #overwrite
        rm(writefile)
    end
    LasIO.FileIO.save(writefile,h,p)
end

"""
	mergelas(headers,pointdata,bb,scale)

Merge more file .las.
"""
function mergelas(headers,pointdata,bb,scale)
	@assert length(headers) == length(pointdata) "inconsistent data"

	# 1. - header of merging las
	hmerge = createheader(headers,pointdata,bb,scale)
	data = LasIO.LasPoint[]

	# 2. - Las point data merge
	for i in 1:length(pointdata)
		for p in pointdata[i]
			laspoint = createlasdata(p,headers[i],hmerge)
			push!(data,laspoint)
		end
	end

	return hmerge,data
end

"""
 	createheader(headers,pointdata,bb,scale)

crea header coerente con i miei punti.
"""
function createheader(headers,pointdata,bb,scale)
	type = pointformat(headers[1])

	h = deepcopy(headers[1])
	h.x_scale = scale
    h.y_scale = scale
    h.z_scale = scale
	h.x_offset = bb[1][1]
    h.y_offset = bb[1][2]
    h.z_offset = bb[1][3]
    h.x_max = bb[2][1]
    h.x_min = bb[1][1]
    h.y_max = bb[2][2]
    h.y_min = bb[1][2]
    h.z_max = bb[2][3]
    h.z_min = bb[1][3]
	h.records_count = sum(length.(pointdata))
	return h
end

"""
 	createlasdata(p,h,header)

genera laspoint coerenti con il mio header.
"""
function createlasdata(p,h,hmerge)
	type = pointformat(h)

	x = xcoord(xcoord(p,h),hmerge)
	y = ycoord(ycoord(p,h),hmerge)
	z = zcoord(zcoord(p,h),hmerge)
	intensity = p.intensity
	flag_byte = p.flag_byte
	raw_classification = p.raw_classification
	scan_angle = p.scan_angle
	user_data = p.user_data
	pt_src_id = p.pt_src_id

	if type == LasIO.LasPoint0
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id
					)

	elseif type == LasIO.LasPoint1
		gps_time = p.gps_time
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time
					)

	elseif type == LasIO.LasPoint2
		red = p.red
		green = p.green
		blue = p.blue

		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id,
					red, green, blue
					)

	elseif type == LasIO.LasPoint3
		gps_time = p.gps_time
		red = p.red
		green = p.green
		blue = p.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time,
					red, green, blue
					)

	end

end

"""
	bbincremental!(coordpoint,bb)

"""
function bbincremental!(coordpoint,bb)
	for i in 1:length(coordpoint)
		if coordpoint[i] < bb[1][i]
			bb[1][i] = coordpoint[i]
		end
		if coordpoint[i] > bb[2][i]
			bb[2][i] = coordpoint[i]
		end
	end

	return true
end


"""
"""
function pointin(model,test) #passo il modello e il test di contenimento

	function pointin0(point)

	end
	return pointin0
end
