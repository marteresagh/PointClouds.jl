"""
Read file .hrc of potree hierarchy.
"""
function readhrc(potree::String)

	typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters togli quelli che non usi
	tree = joinpath(potree,octreeDir,"r") # path to directory "r"
	hrcs = PointClouds.searchfile(tree,".hrc")

	for hrc in hrcs
		raw = read(hrc)
		treehrc = reshape(raw, (5, div(length(raw), 5)))

		for i in 1:size(treehrc,2)
			children = bitstring(UInt8(treehrc[1,i]))
			npoints = parse(Int, bitstring(UInt8(treehrc[5,i]))*bitstring(UInt8(treehrc[4,i]))*bitstring(UInt8(treehrc[3,i]))*bitstring(UInt8(treehrc[2,i])); base=2)
			#struct da finire
		end
	end

	return treehrc
end


"""
Trie data structures for Potree hierarchy.
"""
function triepotree(potree::String)
	typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters
	tree = potree*"\\"*octreeDir*"\\r" # path to directory "r"

	trie = DataStructures.Trie{String}()

	println("search in $tree ")

	# 2.- check all file
	files = PointClouds.searchfile(tree,".las")
	for file in files
		name = rsplit(splitdir(file)[2],".")[1]
		trie[name] = file
	end

	return trie.children['r']
end


"""
Trie DFS.
"""
function dfsimage(t,params)
	model, _ = params
	file = t.value
	nodebb = PointClouds.las2aabb(file)
	inter = PointClouds.modelsdetection(model, nodebb)
	@show file
	@show inter
	if inter == 1
		PointClouds.updateimagewithfilter!(params,file)
		for key in collect(keys(t.children))
			PointClouds.dfsimage(t.children[key],params)
		end
	elseif inter == 2
		for k in keys(t)
			file = t[k]
			PointClouds.updateimage!(params,file)
		end
	end
end
