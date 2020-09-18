"""
Return the image of orthoprojection.
"""
function orthoprojectionimage(
     txtpotreedirs::String,
	 outputimage::String,
	 bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}},
	 GSD::Float64,
	 PO::String,
	 quota::Union{Float64,Nothing},
	 thickness::Union{Float64,Nothing},
	 pc::Bool,
	  )

    # check validity
    @assert isfile(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
    @assert length(PO)==3 "orthoprojectionimage: $PO not valid view "


	# initialization
    PointClouds.flushprintln("initialization")

    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)
    coordsystemmatrix = PointClouds.newcoordsyst(PO)



	if !isnothing(quota)
		if PO == "XY+" || PO == "XY-"
			puntoquota = [0,0,quota]
		elseif PO == "XZ+" || PO == "XZ-"
			puntoquota = [0, quota, 0]
		elseif PO == "YZ+" || PO == "YZ-"
			puntoquota = [quota, 0, 0]
		end

		@assert !isnothing(thickness) "orthoprojectionimage: thickness missing"
		q_l = (coordsystemmatrix*puntoquota)[3] - thickness/2
		q_u = (coordsystemmatrix*puntoquota)[3] + thickness/2
	else
		q_l = -Inf
		q_u = Inf
	end

    RGBtensor, rasterquote, refX, refY = PointClouds.initrasterarray(coordsystemmatrix,GSD,model)
    params = model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc

	if PO == "XY+"
		savetfw(outputimage, GSD, refX, refY)
	end

	#image creation
	PointClouds.flushprintln("image creation")
	n = 0

	if pc
		temp = joinpath(splitdir(outputimage)[1],"temp.las")
		open(temp, "w") do s
			write(s, LasIO.magic(LasIO.format"LAS"))
			RGBtensor,n = PointClouds.imagecreation(potreedirs,params,s,0)
		end
	else
		RGBtensor,n = PointClouds.imagecreation(potreedirs,params,nothing,n)
	end

    save(outputimage, Images.colorview(RGB, RGBtensor))
    PointClouds.flushprintln("image saved in $outputimage")

	#salva file
	if pc
		outputfile = splitext(outputimage)[1]*".las"
		PointClouds.flushprintln("create las file")
		header.records_count = n
	    pointtype = pointformat(header)

		open(temp) do s
			open(outputfile,"w") do t
				write(t, LasIO.magic(LasIO.format"LAS"))
				write(t, header)

			    LasIO.skiplasf(s)
			 	for i=1:n
			        p = read(s, pointtype)
					write(t,p)
			    end
			end
		end

		rm(temp)
		PointClouds.flushprintln("point cloud saved in $outputfile")
	end
end

"""
new basis.
"""
function newcoordsyst(PO::String)
    planecode = PO[1:2]
    @assert planecode == "XY" || planecode == "XZ" || planecode == "YZ" "orthoprojectionimage: $PO not valid view "

    directionview = PO[3]
    @assert directionview == '+' || directionview == '-' "orthoprojectionimage: $PO not valid view "

    coordsystemmatrix = Matrix{Float64}(Lar.I,3,3)

    # if planecode == XY # top, - bottom
    #     continue
    if planecode == "XZ" # back, - front
        coordsystemmatrix[1,1] = -1.
        coordsystemmatrix[2,2] = 0.
        coordsystemmatrix[3,3] = 0.
        coordsystemmatrix[2,3] = 1.
        coordsystemmatrix[3,2] = 1.
    elseif planecode == "YZ" # right, - left
        coordsystemmatrix[1,1] = 0.
        coordsystemmatrix[2,2] = 0.
        coordsystemmatrix[3,3] = 0.
        coordsystemmatrix[1,2] = 1.
        coordsystemmatrix[2,3] = 1.
        coordsystemmatrix[3,1] = 1.
    end

    # if directionview == "+"
    #     continue
    if directionview == '-'
        R = [-1. 0 0; 0 1. 0; 0 0 -1]
        coordsystemmatrix = R*coordsystemmatrix
    end
    return coordsystemmatrix
end


"""
initialize raster image.
"""
function initrasterarray(coordsystemmatrix::Array{Float64,2}, GSD::Float64, model::Lar.LAR)

    verts,edges,faces = model
    bbglobalextention = zeros(2)
    ref = zeros(2)

	newcoord = coordsystemmatrix*verts

    for i in 1:2
        extr = extrema(newcoord[i,:])
        bbglobalextention[i] = extr[2]-extr[1]
        ref[i] = extr[i]
    end

    # IMAGE RESOLUTION
    resX = map(Int∘trunc,bbglobalextention[1] / GSD) + 1
    resY = map(Int∘trunc,bbglobalextention[2] / GSD) + 1

    # Z-BUFFER MATRIX
    rasterquote = fill(-Inf,(resY,resX))

    # RASTER IMAGE MATRIX
    rasterChannels = 3
    RGBtensor = fill(1.,(rasterChannels,resY, resX))

    # refX=ref[1]
    # refY=ref[2]
    return RGBtensor, rasterquote, ref[1], ref[2]
end

"""
In recursive mode, search all files with key in filename.
"""
function searchfile(path::String,key::String)
	files = String[]
	for (root, _, _) in walkdir(path)
		thisfiles = filter(x->occursin(key,x), readdir(root,join=true))
		union!(files,thisfiles)
	end
	return files
end

"""
update image tensor.
"""
function updateimagewithfilter!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        if PointClouds.inmodel(model)(point) # se il punto è interno allora
            rgb = PointClouds.color(laspoint,h)
            p = coordsystemmatrix*point
            xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
            ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

			if p[3] >= q_l && p[3] <= q_u
				if pc
					plas = PointClouds.createlasdata(laspoint,h,header)
					write(s,plas)
					n=n+1
				end
				if rasterquote[ycoord,xcoord] < p[3]
	            	rasterquote[ycoord,xcoord] = p[3]
	                RGBtensor[1, ycoord, xcoord] = rgb[1]
	                RGBtensor[2, ycoord, xcoord] = rgb[2]
	                RGBtensor[3, ycoord, xcoord] = rgb[3]
	            end
			end
        end
    end

	return n

end

function updateimage!(params,file,s,n::Int64)
	h, laspoints =  PointClouds.readpotreefile(file)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,h)
        rgb = PointClouds.color(laspoint,h)
        p = coordsystemmatrix*point
        xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
        ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

		if p[3] >= q_l && p[3] <= q_u
			if pc
				plas = PointClouds.createlasdata(laspoint,h,header)
				write(s,plas)
				n=n+1
			end
	        if rasterquote[ycoord,xcoord] < p[3]
	        	rasterquote[ycoord,xcoord] = p[3]
	            RGBtensor[1, ycoord, xcoord] = rgb[1]
	            RGBtensor[2, ycoord, xcoord] = rgb[2]
	            RGBtensor[3, ycoord, xcoord] = rgb[3]
	        end
		end
    end

	return n

end

"""
imagecreation con i trie
"""
function imagecreation(potreedirs::Array{String,1},params,s,n::Int64)
	model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY, q_l, q_u, pc = params
    for potree in potreedirs
        PointClouds.flushprintln( "======== PROJECT $potree ========")
		typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree)

		trie = PointClouds.triepotree(potree)
		header = LasIO.read_header(trie[""])
		global header

		l=length(keys(trie))
		if PointClouds.modelsdetection(model, tightBB) == 2
			PointClouds.flushprintln("FULL model")
			i=1
			for k in keys(trie)
				if i%100==0
					PointClouds.flushprintln(i," files processed of ",l)
				end
				file = trie[k]
				n = PointClouds.updateimage!(params,file,s,n)
				i=i+1
			end
		else
			PointClouds.flushprintln("DFS")
			n,_ = PointClouds.dfsimage(trie,params,s,n,0,l)
		end
	end

	return RGBtensor,n
end


"""
Trie DFS.
"""
function dfsimage(t,params,s,n::Int64,nfiles,l)
	model, _ = params
	file = t.value
	nodebb = PointClouds.las2aabb(file)
	inter = PointClouds.modelsdetection(model, nodebb)
	if inter == 1
		nfiles = nfiles+1
		if nfiles%100==0
			PointClouds.flushprintln(nfiles," files processed of ",l)
		end
		n = PointClouds.updateimagewithfilter!(params,file,s,n)
		for key in collect(keys(t.children))
			n,nfiles = PointClouds.dfsimage(t.children[key],params,s,n,nfiles,l)
		end
	elseif inter == 2
		for k in keys(t)
			nfiles = nfiles+1
			if nfiles%100==0
				PointClouds.flushprintln(nfiles," files processed of ",l)
			end
			file = t[k]
			n = PointClouds.updateimage!(params,file,s,n)
		end
	end
	return n,nfiles
end

# function image(V,rgb::Lar.Points, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, GSD)
#     npoints = size(V,2)
#     for i in 1:npoints
#         x = PointClouds.projdist(coordsystemmatrix[1,:])(V[:,i])
#         y = PointClouds.projdist(coordsystemmatrix[2,:])(V[:,i])
#         z = PointClouds.projdist(coordsystemmatrix[3,:])(V[:,i])
#         xcoord = map(Int∘trunc,(x-refX) / GSD)+1
#         ycoord = map(Int∘trunc,(refY-y) / GSD)+1
#         if rasterquote[ycoord,xcoord] < z
#             rasterquote[ycoord,xcoord] = z
#             RGBtensor[1, ycoord, xcoord] = rgb[1,i]
#             RGBtensor[2, ycoord, xcoord] = rgb[2,i]
#             RGBtensor[3, ycoord, xcoord] = rgb[3,i]
#         end
#     end
#     return RGBtensor
# end

## da RIVEDERE
"""
A model and an AABB intersection:
 - 0 -> model not intersect AABB
 - 1 -> model intersect but not contains AABB
 - 2 -> model contains AABB
"""

function modelsdetection(model,octree)
	verts,edges,faces = model
	aabbmodel = Lar.boundingbox(verts)
	if PointClouds.AABBdetection(aabbmodel,octree)
		#ci sono 3 casi se i due bounding box si incontrano:
		# 1. octree è tutto interno  return 2
		# 2. octree esterno return 0
		# 3. octree intersecato ma non contenuto return 1
		Voctree,EVoctree,FVoctree = PointClouds.getmodel(octree)
		test = PointClouds.inmodel(model).([Voctree[:,i] for i in 1:size(Voctree,2)])
		if test == ones(size(Voctree,2))
			return 2 # full model
		elseif !separatingaxis(model, octree)
			return 0
		else
			return 1
		end
	else
		return 0 # no intersection
	end
end

function separatingaxis(model,octree)
	V,EV,FV = PointClouds.getmodel(octree)
	verts,edges,faces = model
	axis_x = (verts[:,5]-verts[:,1])/Lar.norm(verts[:,5]-verts[:,1])
	axis_y = (verts[:,2]-verts[:,1])/Lar.norm(verts[:,2]-verts[:,1])
	axis_z = (verts[:,3]-verts[:,1])/Lar.norm(verts[:,3]-verts[:,1])
	coordsystem = [axis_x';axis_y';axis_z']
	newverts = coordsystem*verts
	newV = coordsystem*V
	newaabb = [extrema(newverts[i,:]) for i in 1:3]
	newAABB = [extrema(newV[i,:]) for i in 1:3]
	aabb = (hcat([newaabb[1][1],newaabb[2][1],newaabb[3][1]]),hcat([newaabb[1][2],newaabb[2][2],newaabb[3][2]]))
	AABB = (hcat([newAABB[1][1],newAABB[2][1],newAABB[3][1]]),hcat([newAABB[1][2],newAABB[2][2],newAABB[3][2]]))
	return PointClouds.AABBdetection(aabb,AABB)
end


function inmodel(model)
	verts,edges,faces = model
	axis_x = (verts[:,5]-verts[:,1])/Lar.norm(verts[:,5]-verts[:,1])
	axis_y = (verts[:,2]-verts[:,1])/Lar.norm(verts[:,2]-verts[:,1])
	axis_z = (verts[:,3]-verts[:,1])/Lar.norm(verts[:,3]-verts[:,1])
	coordsystem = [axis_x';axis_y';axis_z']
	newverts = coordsystem*verts
	a = [extrema(newverts[i,:]) for i in 1:3]
	A = (hcat([a[1][1],a[2][1],a[3][1]]),hcat([a[1][2],a[2][2],a[3][2]]))

	function inmodel0(p)
		newp = coordsystem*p
		# 1. - axis x AleftB = A[1,max]<B[1,min]  ArightB = A[1,min]>B[1,max]
		# 2. - axis y AfrontB = A[2,max]<B[2,min]  AbehindB = A[2,min]>B[2,max]
			# 3. - axis z AbottomB = A[3,max]<B[3,min]  AtopB = A[3,min]>B[3,max]
		return (A[2][1]>=newp[1] && A[1][1]<=newp[1]) &&
					 (A[2][2]>=newp[2] && A[1][2]<=newp[2]) &&
					  (A[2][3]>=newp[3] && A[1][3]<=newp[3])
	end
	return inmodel0
end
