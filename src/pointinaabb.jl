
"""
	aabbsegmentcloud(filename::String, from::String, to::String, model)
"""
function aabbsegmentcloud(from::String, to::String, aabb::Tuple{Array{Float64,2},Array{Float64,2}})

	# initialize
	# info of model
	bb = ([Inf,Inf,Inf],[-Inf,-Inf,-Inf]) # initialize aabb of my finale points

	headers = LasIO.LasHeader[] # all headers
	arraylaspoint = Array{LasIO.LasPoint,1}[] # all points fall in my model

	scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = PointClouds.readJSON(from) # useful parameters
	pathr = from*"\\"*octreeDir*"\\r" # path to directory "r"

	println("=========================================")
	println("search in $pathr ")

	# check all file
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
						coordpoint = xyz(p,h)
						if PointClouds.isinbox(aabb,coordpoint)
							PointClouds.bbincremental!(coordpoint,bb)
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
	end
	println("file creation")
	# merge .las and save
 	header, pointdata = PointClouds.mergelas(headers,arraylaspoint,bb,scale)
	PointClouds.savenewlas(to,header,pointdata)
	println("file .las saved in $to")
	println("=========================================")
	return 1
end
