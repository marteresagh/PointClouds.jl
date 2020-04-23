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
		@show name
		trie[name]=file
	end

	return trie
end
