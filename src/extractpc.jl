"""
	ispointinpolyhedron(model,point)

Return true if  `point` is in the `model`.
"""
function ispointinpolyhedron(model,point)
	V,EV,FV = model
	test = PointClouds.testinternalpoint(V,EV,FV)(point)
	if length(test)%2==0
		return false
	else
		return true
	end
end



#
# """
# 	filesegment(potree::String, folder::String, volume::String)
#
# Segment all files in a `potree` hierarchy: save files .ply in `folder` with all points in `volume`.
# `folder` is always overwrited.
# """
# function filesegment(potree::String, folder::String, volume::String)
# 	#potree => potree directory
# 	#folder => cartella in cui salvare i file
# 	#volume => JSON format of volume
#
# 	@assert isdir(potree) "filesegment: $potree not an existing path"
# 	@assert isdir(folder) "filesegment: $folder not an existing folder"
# 	@assert isfile(volume) "filesegment: $volume not an existing file"
# 	PointClouds.clearfolder(folder) #remove all file in directory
#
# 	#0. read volume
# 	model = PointClouds.readmodel(volume)
# 	V,EV,FV=model
# 	aabb=Lar.boundingbox(V)
#
# 	#read potree
# 	_,_,AABBroot,octreeDir,_,_ = PointClouds.readcloudJSON(potree) # useful parameters
# 	pathr = joinpath(potree,octreeDir,"r") # path to directory "r"
#
# 	println("=========================================")
# 	println("AABB saved")
# 	#1. salvare il aabb del volume in folder
# 	PointClouds.savebbJSON(folder, aabb)
# 	PointClouds.aabbASCII(folder,aabb)
#
# 	#2. per ogni file in potree salvare il file segmentato in folder
# 	println("=========================================")
# 	println("search in $pathr ")
#
# 	# check all file
# 	nfile = 0
# 	for (root, dirs, files) in walkdir(pathr)
#  		Threads.@threads for file in files
# 			@show file
# 			nfile += 1
# 			if endswith(file, ".las")
# 				# initialize
#  				inds = Int[]
#
# 				# info file
# 				name = split(file,".")[1]*".ply" # file name
# 		        fpath = joinpath(root, file)  # path to files
#
# 				# info data
# 				V,_,rgb = PointClouds.loadlas(fpath)
# 				octreebb = PointClouds.las2aabb(fpath)
#
# 				if PointClouds.AABBdetection(octreebb,aabb)
# 					for  i in 1:size(V,2)
# 						coordpoint = V[:,i]
# 						if PointClouds.ispointinpolyhedron(model,coordpoint)
# 							push!(inds,i)
# 						end
# 					end
# 				end
#
# 				#progession
# 				if !isempty(inds)
# 					PointClouds.saveply(joinpath(folder,name),V[:,inds],rgb[:,inds])
# 				end
#
# 				if nfile%100==0
# 					println("$nfile files checked")
# 				end
#
# 				inds = nothing
#
# 			end
# 		end
# 	end
# 	println("file .ply saved in $folder")
# 	println("=========================================")
# end

"""
	clearfolder(folder::String)

Clear the given `folder`.
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

"""
Two ways to pass model: file .json of `volume` or min e max coordinates of `aabb`.
"""
function clip(potree::String,folder::String,volume::String)
	@assert isdir(potree) "filesegment: $potree not an existing path"
	@assert isdir(folder) "filesegment: $folder not an existing folder"
	@assert isfile(volume) "filesegment: $volume not an existing file"
	PointClouds.clearfolder(folder) #remove all file in directory
 	model = PointClouds.readmodel(volume)
 	PointClouds.segmentmodel(potree, folder, model)
end

function clip(potree::String,folder::String,aabb::Tuple{Array{Float64,2},Array{Float64,2}})
	@assert isdir(potree) "filesegment: $potree not an existing path"
	@assert isdir(folder) "filesegment: $folder not an existing folder"
	PointClouds.clearfolder(folder) #remove all file in directory
 	model = PointClouds.boxmodel(aabb)
 	PointClouds.segmentmodel(potree, folder, model)
end

"""
	segmentmodel(potree::String, folder::String, model::Lar.LAR)

Segment all files in a `potree` hierarchy: save files .ply in `folder` with all points in `model`.
`folder` is always overwrited.
"""
function segmentmodel(potree::String, folder::String, model::Lar.LAR)

	#0. read model
	V,EV,FV = model
	aabb = Lar.boundingbox(V)

	#read potree
	_,_,AABBroot,octreeDir,_,_ = PointClouds.readcloudJSON(potree) # useful parameters
	pathr = joinpath(potree,octreeDir,"r") # path to directory "r"

	println("=========================================")
	println("AABB saved ")
	#1. salvare il aabb del volume in folder
	PointClouds.savebbJSON(folder, aabb)
	PointClouds.aabbASCII(folder,aabb)

	#2. per ogni file in potree salvare il file segmentato in folder
	println("search in $pathr ")

	# check all file
	for (root, dirs, files) in walkdir(pathr)
		Threads.@threads for file in files
			if endswith(file, ".las")
				# initialize
 				inds = Int[]

				# info file
				name = split(file,".")[1]*".ply" # file name
		        fpath = joinpath(root, file)  # path to files

				# info data
				nodebb = PointClouds.las2aabb(fpath)

				if PointClouds.AABBdetection(nodebb,aabb)
					V,_,rgb = PointClouds.loadlas(fpath)
					for  i in 1:size(V,2)
						coordpoint = V[:,i]
						if PointClouds.ispointinpolyhedron(model,coordpoint)
							push!(inds,i)
						end
					end
					if !isempty(inds)
						PointClouds.saveply(joinpath(folder,name),V[:,inds],rgb[:,inds])
					end
				end

				inds = nothing

			end
		end
	end
	println("file .ply saved in $folder")
	println("=========================================")
end
