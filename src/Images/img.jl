
"""
Return the image of orthoprojection.
"""
function orthoprojectionimage(txtpotreedirs::String, outputimage::String, bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}}, GSD::Float64, PO::String )
    # check validity
    @assert isfile(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
    @assert length(PO)==3 "orthoprojectionimage: $PO not valid view "

    # initialization
    println("initialization")
    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)
    coordsystemmatrix = PointClouds.newcoordsyst(PO)
    RGBtensor, rasterquote, refX, refY = PointClouds.initrasterarray(coordsystemmatrix,GSD,model)
    params = model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY

    #image creation
    println("image creation")
    RGBtensor = PointClouds.imagecreation(potreedirs,params)
    save(outputimage, Images.colorview(RGB, RGBtensor))
    println("image saved in $outputimage")

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
Cerca nei file di potree quali punti considerare
"""
#considera quali punti prendere in partenza, devo modificare la lettura del jsaon e inserire anche il resto dei parametri sopratutto tightbb
function imagecreation(potreedirs::Array{String,1},params)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY = params
    aabbmodel = Lar.boundingbox(model[1])
    for potree in potreedirs
        println("======== PROJECT $potree ========")

		typeofpoints,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters togli quelli che non usi
		tree = joinpath(potree,octreeDir,"r") # path to directory "r"

		println("Search in $tree ")

		# 2.- check all file
		files = PointClouds.searchfile(tree,".las")
		nfiles = length(files)
		println("$(nfiles) files to process")

		if PointClouds.modelsdetection(model, tightBB) == 2
			#println("Full")
			for i in 1:nfiles # for all files
				#progression
	            if i%100 == 0
	                println("$i files processed of $nfiles")
	            end

				header, laspoints = LasIO.FileIO.load(files[i])
				PointClouds.updateimage!(params,header,laspoints)

			end

		elseif PointClouds.modelsdetection(model, tightBB) == 1
			#println("Limited")
			for i in 1:nfiles # for all files
				#progression
				if i%100 == 0
					println("$i files processed of $nfiles")
				end

				header, laspoints = LasIO.FileIO.load(files[i])
				nodebb = PointClouds.las2aabb(header)

				inter = PointClouds.modelsdetection(model, nodebb)
				if inter == 1
					 PointClouds.updateimagewithfilter!(params,header,laspoints)
				elseif inter == 2
					PointClouds.updateimage!(params,header,laspoints)
				end
			end

		end

    end
    return RGBtensor
end

"""
aggiorna l'immagine.
"""
function updateimagewithfilter!(params,header,laspoints)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,header)
        if PointClouds.ispointinpolyhedron(model,point) # se il punto è interno allora
            rgb = PointClouds.color(laspoint,header)
            p = coordsystemmatrix*point
            xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
            ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

            if rasterquote[ycoord,xcoord] < p[3]
            	rasterquote[ycoord,xcoord] = p[3]
                RGBtensor[1, ycoord, xcoord] = rgb[1]
                RGBtensor[2, ycoord, xcoord] = rgb[2]
                RGBtensor[3, ycoord, xcoord] = rgb[3]
            end
        end
    end
end

function updateimage!(params,header,laspoints)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,header)
        rgb = PointClouds.color(laspoint,header)
        p = coordsystemmatrix*point
        xcoord = map(Int∘trunc,(p[1]-refX) / GSD)+1
        ycoord = map(Int∘trunc,(refY-p[2]) / GSD)+1

        if rasterquote[ycoord,xcoord] < p[3]
        	rasterquote[ycoord,xcoord] = p[3]
            RGBtensor[1, ycoord, xcoord] = rgb[1]
            RGBtensor[2, ycoord, xcoord] = rgb[2]
            RGBtensor[3, ycoord, xcoord] = rgb[3]
        end
    end
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
		# 1. octree esterno return 0
		# 1. octree intersecato ma non contenuto return 1
		Voctree,EVoctree,FVoctree = PointClouds.getmodel(octree)
		inter = PointClouds.testinternalpoint(verts,edges,faces).([Voctree[:,i] for i in 1:size(Voctree,2)])
		test = length.(inter).%2
		if test == ones(size(Voctree,2)) || test == [1, 0, 1, 0, 1, 0, 1, 0] #quest' ultimo se si sovrappongono
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
