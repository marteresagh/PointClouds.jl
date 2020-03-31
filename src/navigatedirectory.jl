
"""
	filelevel(path,lev)
"""
function filelevel(path,lev,allprev=true)
	scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = readJSON(path) # useful parameters
	pathr = path*"\\"*octreeDir*"\\r" # path to directory "r"

	println("search in $pathr ")

	# 2.- check all file
	allfile=[]
	for (root, dirs, files) in walkdir(pathr)
		for file in files
			if endswith(file, ".las")
				name = rsplit(file,".")[1]
				level = []
				for i in name
					if isnumeric(i)
						push!(level,i)
					end
				end
				if !allprev
					if length(level)==lev
						push!(allfile,joinpath(root, file))
					end
				else
					if length(level)<=lev
						push!(allfile,joinpath(root, file))
					end
				end
			end
		end
	end
	return allfile
end

# """
# 	readJSON(path::String)
#
# Read a file `.json`.
# """
# function readJSON(path::String)
# 	dict=Dict{String,Any}[]
# 	open(path * "\\cloud.js", "r") do f
# 	    dict=JSON.parse(f)  # parse and transform data
# 	end
# 	dictAABB = dict["boundingBox"]
# 	scale = dict["scale"]
# 	npoints = dict["points"]
# 	AABB=([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]],
# 			[dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]])
# 	octreeDir = dict["octreeDir"]
# 	hierarchyStepSize = dict["hierarchyStepSize"]
# 	spacing = dict["spacing"]
# 	return scale,npoints,AABB,octreeDir,hierarchyStepSize,spacing
# end

# """
# 	boxmodel(aabb::Tuple{Array{Float64,2},Array{Float64,2}})
# """
# function boxmodel(aabb::Tuple{Array{Float64,2},Array{Float64,2}})
# 	min,max = aabb
# 	V = [	min[1]  min[1]  min[1]  min[1]  max[1]  max[1]  max[1]  max[1];
# 		 	min[2]  min[2]  max[2]  max[2]  min[2]  min[2]  max[2]  max[2];
# 		 	min[3]  max[3]  min[3]  max[3]  min[3]  max[3]  min[3]  max[3] ]
# 	EV = [[1, 2],  [3, 4], [5, 6],  [7, 8],  [1, 3],  [2, 4],  [5, 7],  [6, 8],  [1, 5],  [2, 6],  [3, 7],  [4, 8]]
# 	FV = [[1, 2, 3, 4],  [5, 6, 7, 8],  [1, 2, 5, 6],  [3, 4, 7, 8],  [1, 3, 5, 7],  [2, 4, 6, 8]]
# 	return V,EV,FV
# end

# TODO: bug in testinternalpoint punto sotto il modello
# """
# 	volumesegmentcloud(filename::String, from::String, to::String, model)
# """
# function volumesegmentcloud(from::String, to::String, aabb::Tuple{Array{Float64,2},Array{Float64,2}})
#
# 	# initialize
# 	# info of model
# 	V,EV,FV = PointClouds.boxmodel(aabb)
#
#
# 	bb = ([Inf,Inf,Inf],[-Inf,-Inf,-Inf]) # initialize aabb of my finale points
#
# 	headers = LasIO.LasHeader[] # all headers
# 	arraylaspoint = Array{LasIO.LasPoint,1}[] # all points fall in my model
#
# 	scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = PointClouds.readJSON(from) # useful parameters
# 	pathr = from*"\\"*octreeDir*"\\r" # path to directory "r"
#
# 	println("=========================================")
# 	println("search in $pathr ")
#
# 	# check all file
# 	for (root, dirs, files) in walkdir(pathr)
# 		l = length(files)
# 		f = 0
# 		for file in files
# 			pointstaken = LasIO.LasPoint[]
# 			if endswith(file, ".las")
# 		        fname = joinpath(root, file) # path to files
# 				AABB = PointClouds.las2aabb(fname) # AABB of octree
# 				h, pdata = LasIO.FileIO.load(fname) # read data
# 				if PointClouds.AABBdetection(AABB,aabb)
# 					push!(headers,h)
# 					for p in pdata
# 						coordpoint = xyz(p,h)
# 						if !isempty(Lar.testinternalpoint(V,EV,FV)(coordpoint))
# 							PointClouds.bbincremental!(coordpoint,bb)
# 							push!(pointstaken,p)
# 						end
# 					end
# 					push!(arraylaspoint,pointstaken)
# 				end
# 			end
# 			#progession
# 			f = f+1
# 			if f%100==0
# 				println("file processed $f of $l")
# 			end
# 		end
# 	end
# 	println("file creation")
# 	# merge .las and save
#  	header, pointdata = PointClouds.mergelas(headers,arraylaspoint,bb,scale)
# 	PointClouds.savenewlas(to,header,pointdata)
# 	println("file .las saved in $to")
# 	println("=========================================")
# 	return 1
# end
#

"""
	regionsegmentcloud(filename::String,from::String, to::String, region, par::Float64)
"""
function regionsegmentcloud(filename::String, from::String, to::String, region, par::Float64)

	# 1.- initialize
	# info of model
	println("=========================================")
	shape,pointsmodel,params = region
	aabb = Lar.boundingbox(pointsmodel)

	writefile = to*"\\"*filename*".las"
	bb = ([Inf,Inf,Inf],[-Inf,-Inf,-Inf]) # initialize aabb of my finale points

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
			pointstaken = LasIO.LasPoint[]
			if endswith(file, ".las")
		        fname = joinpath(root, file) # path to files
				AABB = PointClouds.las2aabb(fname) # AABB of octree
				h, pdata = LasIO.FileIO.load(fname) # read data
				if PointClouds.AABBdetection(AABB,aabb)
					push!(headers,h)
					for p in pdata
						coordpoint = PointClouds.xyz(p,h)
						if PointClouds.isclosetomodel(coordpoint,params, par, shape)
							bbincremental!(coordpoint,bb)
							push!(pointstaken,p)
						end
					end
					push!(arraylaspoint,pointstaken)
				end
			end
			# progession
			f = f+1
			if f%100==0
				println("file processed $f of $l")
			end
		end
	end

	# merge .las and save
	println("creation of file")
 	header, pointdata = PointClouds.mergelas(headers,arraylaspoint,bb,scale)
	savenewlas(writefile,header,pointdata)
	println("file .las saved in $writefile")
	println("=========================================")
	# questi punti li tolgo dall'albero?? cioè da ogni file .las
	return 1
end

# """
# 	 xyz(p::LasPoint, h::LasHeader)
#
# Return coords of this laspoint p.
# """
# function xyz(p::LasPoint, h::LasHeader)
# 	return [xcoord(p, h); ycoord(p, h); zcoord(p, h)]
# end
#
# """
# 	savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})
#
# save file .las in writefile.
# """
# function savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})
#     if ispath(writefile) #overwrite
#         rm(writefile)
#     end
#     LasIO.FileIO.save(writefile,h,p)
# end
#
# """
# 	mergelas(headers,pointdata,bb,scale)
#
# Merge more file .las.
# """
# function mergelas(headers,pointdata,bb,scale)
# 	@assert length(headers) == length(pointdata) "mergelas: inconsistent data"
#
# 	# header of merging las
# 	hmerge = createheader(headers,pointdata,bb,scale)
# 	data = LasIO.LasPoint[]
#
# 	# Las point data merge
# 	for i in 1:length(pointdata)
# 		for p in pointdata[i]
# 			laspoint = createlasdata(p,headers[i],hmerge)
# 			push!(data,laspoint)
# 		end
# 	end
#
# 	return hmerge,data
# end
#
# """
#  	createheader(headers,pointdata,bb,scale)
#
# crea header coerente con i miei punti.
# """
# function createheader(headers,pointdata,bb,scale)
# 	type = pointformat(headers[1])
# 	h = deepcopy(headers[1])
#
# 	h.x_scale = scale
#     h.y_scale = scale
#     h.z_scale = scale
#
# 	h.x_offset = bb[1][1]
#     h.y_offset = bb[1][2]
#     h.z_offset = bb[1][3]
#
#     h.x_max = bb[2][1]
#     h.x_min = bb[1][1]
#     h.y_max = bb[2][2]
#     h.y_min = bb[1][2]
#     h.z_max = bb[2][3]
#     h.z_min = bb[1][3]
#
# 	h.records_count = sum(length.(pointdata))
# 	return h
# end
#
# """
#  	createlasdata(p,h,header)
#
# Generate laspoint coerenti con il mio header (soprattutto per quanto riguarda la traslazione).
# """
# function createlasdata(p,h,hmerge)
# 	type = pointformat(h)
#
# 	x = xcoord(xcoord(p,h),hmerge)
# 	y = ycoord(ycoord(p,h),hmerge)
# 	z = zcoord(zcoord(p,h),hmerge)
# 	intensity = p.intensity
# 	flag_byte = p.flag_byte
# 	raw_classification = p.raw_classification
# 	scan_angle = p.scan_angle
# 	user_data = p.user_data
# 	pt_src_id = p.pt_src_id
#
# 	if type == LasIO.LasPoint0
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id
# 					)
#
# 	elseif type == LasIO.LasPoint1
# 		gps_time = p.gps_time
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id, gps_time
# 					)
#
# 	elseif type == LasIO.LasPoint2
# 		red = p.red
# 		green = p.green
# 		blue = p.blue
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id,
# 					red, green, blue
# 					)
#
# 	elseif type == LasIO.LasPoint3
# 		gps_time = p.gps_time
# 		red = p.red
# 		green = p.green
# 		blue = p.blue
# 		return type(x, y, z,
# 					intensity, flag_byte, raw_classification,
# 					scan_angle, user_data, pt_src_id, gps_time,
# 					red, green, blue
# 					)
#
# 	end
# end
#
# """
# 	bbincremental!(coordpoint,bb)
#
# """
# function bbincremental!(coordpoint,bb)
#
# 	for i in 1:length(coordpoint)
# 		if coordpoint[i] < bb[1][i]
# 			bb[1][i] = coordpoint[i]
# 		end
# 		if coordpoint[i] > bb[2][i]
# 			bb[2][i] = coordpoint[i]
# 		end
# 	end
#
# 	return true
# end
