
"""
	filelevel(path,lev)
"""
function filelevel(path,lev,allprev=true)
	typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(path) # useful parameters
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

	typeofpoints,scale,npoints,AABBr,tightBB,octreeDir,hierarchyStepSize,spacing = readcloudJSON(from) # useful parameters
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
