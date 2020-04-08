"""
	ispointinpolyhedron(model,point)

Return true if  `point` is in the `model`.
"""
function ispointinpolyhedron(model,point)
	V,EV,FV = model
	test = Lar.testinternalpoint(V,EV,FV)(point)
	if length(test)%2==0
		return false
	else
		return true
	end
end

"""
	boxmodel(aabb::Tuple{Array{Float64,2},Array{Float64,2}})

Return LAR model of the aligned axis box defined by `aabb`.
"""
function boxmodel(aabb::Tuple{Array{Float64,2},Array{Float64,2}})
	min,max = aabb
	V = [	min[1]  min[1]  min[1]  min[1]  max[1]  max[1]  max[1]  max[1];
		 	min[2]  min[2]  max[2]  max[2]  min[2]  min[2]  max[2]  max[2];
		 	min[3]  max[3]  min[3]  max[3]  min[3]  max[3]  min[3]  max[3] ]
	EV = [[1, 2],  [3, 4], [5, 6],  [7, 8],  [1, 3],  [2, 4],  [5, 7],  [6, 8],  [1, 5],  [2, 6],  [3, 7],  [4, 8]]
	FV = [[1, 2, 3, 4],  [5, 6, 7, 8],  [1, 2, 5, 6],  [3, 4, 7, 8],  [1, 3, 5, 7],  [2, 4, 6, 8]]
	return V,EV,FV
end

"""
save file .las.
"""
function segmentpclas(from::String, to::String, model::Lar.LAR)

	# initialize

	V,_,_ = model	# info of model
	aabb = Lar.boundingbox(V)
	scale,_,AABBroot,octreeDir,_,_ = PointClouds.readcloudJSON(from) # useful parameters
	pathr = from*"\\"*octreeDir*"\\r" # path to directory "r"

	headers = LasIO.LasHeader[] # all headers
	arraylaspoint = Array{LasIO.LasPoint,1}[] # all points fall in my model


	println("=========================================")
	println("search in $pathr ")

	# check all file
	dimdirs=0
	d=0
	for (root, dirs, files) in walkdir(pathr)
		i = 0
		l = length(files)
		ld=length(dirs)
		dimdirs=dimdirs+ld
		if d%100==0
			println("=======================")
			println("folder $d of $dimdirs")
			println("=======================")
		end
		f = 0
		for file in files
			pointstaken = LasIO.LasPoint[]
			if endswith(file, ".las")
		        fname = joinpath(root, file) # path to files
				h, pdata = LasIO.FileIO.load(fname) # read data
				octreebb = PointClouds.las2aabb(h) # AABB of octree
				if PointClouds.AABBdetection(octreebb,aabb)
					push!(headers,h)
					for p in pdata
						coordpoint = PointClouds.xyz(p,h)
						if PointClouds.ispointinpolyhedron(model,coordpoint)
							push!(pointstaken,p)
						end
					end
					push!(arraylaspoint,pointstaken)
				end
			end
			#progession
			f = f+1
			if f%100==0
				println("file processed $f of $l")
			end
		end
		d=d+1
	end

	#return headers,arraylaspoint,AABBroot,scale
	println("file creation")
	# merge .las and save
 	header, pointdata = PointClouds.mergelas(headers,arraylaspoint,AABBroot,scale)
	PointClouds.savenewlas(to,header,pointdata)
	println("file .las saved in $to")
	println("=========================================")
	return 1
end

"""
save file .ply
"""
function segmentpcply(from::String, to::String, model::Lar.LAR)

	# initialize
	V,_,_ = model # info of model
	aabb = Lar.boundingbox(V)
	scale,_,AABBroot,octreeDir,_,_ = PointClouds.readcloudJSON(from) # useful parameters
	pathr = from*"\\"*octreeDir*"\\r" # path to directory "r"

	verts = []
	rgbs = []

	println("=========================================")
	println("search in $pathr ")

	# check all file
	dimdirs=0
	d=0
	for (root, dirs, files) in walkdir(pathr)
		i = 0
		l = length(files)
		ld=length(dirs)
		dimdirs=dimdirs+ld
		if d%100==0
			println("=======================")
			println("folder $d of $dimdirs")
			println("=======================")
		end
		f = 0
		for file in files
			pointstaken = LasIO.LasPoint[]
			if endswith(file, ".las")
		        fname = joinpath(root, file)  # path to files
				h, pdata = LasIO.FileIO.load(fname) # read data
				octreebb = PointClouds.las2aabb(h) # AABB of octree
				if PointClouds.AABBdetection(octreebb,aabb)
					#push!(headers,h)
					for p in pdata
						coordpoint = PointClouds.xyz(p,h)
						if PointClouds.ispointinpolyhedron(model,coordpoint)
							i=i+1
							push!(verts,coordpoint)
							push!(rgbs,PointClouds.color(p,h))
						end
					end
				end
			end
			#progession
			f = f+1
			if f%100==0
				println("file processed $f of $l")
			end
		end
		d=d+1
	end

 	println("file creation")
 	# save ply
	PointClouds.saveply(to,hcat(verts...),hcat(rgbs...))
	println("file .ply saved in $to")
	println("=========================================")
	return 1
end

"""
segment point cloud and save in a file.
"""
function segmentpc(from::String, to::String, model::Lar.LAR)
	if endswith(to,".ply")
		segmentpcply(from, to, model)
	elseif endswith(to,".las")
		segmentpclas(from, to, model)
	else
		println("file format not supported")
	end
end


function clip(from::String, to::String, volume::String)
	V,CV,FV,EV = PointClouds.volumemodel(volume)
	model = V,EV,FV
	PointClouds.segmentpc(from, to, model)
end

function readmodel(volume::String)
	V,CV,FV,EV = PointClouds.volumemodel(volume)
	model = V,EV,FV
	aabb = Lar.boundingbox(V) #aabb of given volume
	return aabb,model
end


function filesegment(potree::String, folder::String, volume::String)
	#potree => potree directory
	#folder => cartella in cui salvare i file
	#volume => JSON format of volume

	@assert isdir(potree) "filesegment: $potree not an existing path"
	@assert isdir(folder) "filesegment: $folder not an existing folder"
	@assert isfile(volume) "filesegment: $volume not an existing file"
	PointClouds.clearfolder(folder) #remove all file in directory

	#0. read volume
	aabb,model = PointClouds.readmodel(volume)

	#read potree
	_,_,AABBroot,octreeDir,_,_ = PointClouds.readcloudJSON(potree) # useful parameters
	pathr = joinpath(potree,octreeDir,"r") # path to directory "r"

	println("=========================================")
	println("AABB saved")
	#1. salvare il aabb del volume in folder
	PointClouds.savebbJSON(folder, aabb)
	PointClouds.aabbASCII(folder,aabb)

	#2. per ogni file in potree salvare il file segmentato in folder
	println("=========================================")
	println("search in $pathr ")

	# check all file
	nfile = 0
	for (root, dirs, files) in walkdir(pathr)
		Threads.@threads for file in files
			nfile += 1
			if endswith(file, ".las")
				# initialize
 				inds = Int[]

				# info file
				name = split(file,".")[1]*".ply" # file name
		        fpath = joinpath(root, file)  # path to files

				# info data
				V,_,rgb = PointClouds.loadlas(fpath)
				octreebb = PointClouds.las2aabb(fpath)

				if PointClouds.AABBdetection(octreebb,aabb)
					for  i in 1:size(V,2)
						coordpoint = V[:,i]
						if PointClouds.ispointinpolyhedron(model,coordpoint)
							push!(inds,i)
						end
					end
				end

				#progession
				if !isempty(inds)
					PointClouds.saveply(joinpath(folder,name),V[:,inds],rgb[:,inds])
				end

				if nfile%100==0
					println("$nfile files checked")
				end

				inds = nothing

			end
		end
	end
	println("file .ply saved in $folder")
	println("=========================================")
end

"""
Clear the given folder
"""
function clearfolder(folder::String)
	root, dirs, files = first(walkdir(folder))
	for dir in dirs
		rm(joinpath(root,dir),recursive=true)
	end
	for file in files
		rm(joinpath(root,file))
	end
	return 1
end
