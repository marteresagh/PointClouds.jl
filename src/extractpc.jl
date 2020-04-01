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
	volumetricsegmentcloudlas(filename::String, from::String, to::String, model)

"""
# TODO refactoring
# Separa questa funzione  costruisci tutti i punti e poi scegli il salvataggio ply o las, devi passargli il modello generato dal json.
function volumetricsegmentcloudlas(from::String, to::String, aabb::Tuple{Array{Float64,2},Array{Float64,2}})

	# initialize
	# info of model

	bb = ([Inf,Inf,Inf],[-Inf,-Inf,-Inf]) # initialize aabb of my finale points
	V,EV,FV = PointClouds.boxmodel(aabb)

	headers = LasIO.LasHeader[] # all headers
	arraylaspoint = Array{LasIO.LasPoint,1}[] # all points fall in my model

	scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(from) # useful parameters
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
						if PointClouds.ispointinpolyhedron((V,EV,FV),coordpoint)
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
