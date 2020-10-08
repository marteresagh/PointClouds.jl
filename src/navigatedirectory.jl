
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
