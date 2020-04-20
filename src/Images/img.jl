function modelintersectoctree(model, octreenode)
	verts,edges,faces = model
	aabbmodel = Lar.boundingbox(verts)
	if PointClouds.AABBdetection(aabbmodel,octreenode)
		Voctree,_,_ = PointClouds.boxmodelfromaabb(octreenode)
		inter = PointClouds.testinternalpoint(verts,edges,faces).([Voctree[:,i] for i in 1:size(Voctree,2)])
		test = length.(inter).%2
		if test == ones(size(Voctree,2))
			return 2 # octreenode all in model
		elseif isempty(test)
			return 0
		else
			return 1 #interseca ma non contiene
		end
	else
		return 0 # no intersection
	end
end

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
    bbglobalextention = zeros(2) # basta farlo sui primi due, X e Y quanto è profonda la scatola non mi interessa in questo momento
    ref = zeros(2)

	newcoord=coordsystemmatrix*verts

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
#
# #prova
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

"""
Cerca nei file di potree quali punti considerare
"""
#considera quali punti prendere in partenza, devo modificare la lettura del jsaon e inserire anche il resto dei parametri sopratutto tightbb
function imagecreation(potreedirs::Array{String,1},params)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY = params
    aabbmodel = Lar.boundingbox(model[1])
    for potree in potreedirs
        println("======== PROJECT $potree ========")

        scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters togli quelli che non usi
		tree = joinpath(potree,octreeDir,"r") # path to directory "r"

		println("Search in $tree ")

		# 2.- check all file
		files = PointClouds.searchfile(tree,".las")
		nfiles = length(files)
		println("$(nfiles) files to process")

		if PointClouds.modelintersectoctree(model, AABBoriginal) == 2
			println("all model")

			for i in 1:nfiles # for all files
				#progression
	            if i%100 == 0
	                println("$i files processed of $nfiles")
	            end

				header, laspoints = LasIO.FileIO.load(files[i])
	            # nodebb = PointClouds.las2aabb(header)

	            # if PointClouds.AABBdetection(nodebb,aabbmodel) #se il nodo e il modello si intersecano allora
	            #     PointClouds.updateimage!(params,header,laspoints)
	            # end
				PointClouds.updateimage2!(params,header,laspoints)
			end
		elseif PointClouds.modelintersectoctree(model, AABBoriginal) == 1
			println("interect model")
			for i in 1:nfiles # for all files
				#progression
				if i%100 == 0
					println("$i files processed of $nfiles")
				end

				header, laspoints = LasIO.FileIO.load(files[i])
				nodebb = PointClouds.las2aabb(header)

				# if PointClouds.AABBdetection(nodebb,aabbmodel) #se il nodo e il modello si intersecano allora
				#     PointClouds.updateimage!(params,header,laspoints)
				# end

				inter = PointClouds.modelintersectoctree(model, nodebb)
				@show inter
				if inter == 1
					 PointClouds.updateimage!(params,header,laspoints)
				elseif inter == 2
					PointClouds.updateimage2!(params,header,laspoints)
				end
			end
		elseif PointClouds.modelintersectoctree(model, AABBoriginal) == 0
			println("no point in model")
		end

    end
    return RGBtensor
end

"""
aggiorna l'immagine.
"""
function updateimage!(params,header,laspoints)
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

function updateimage2!(params,header,laspoints)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY = params

    for laspoint in laspoints
        point = PointClouds.xyz(laspoint,header)
        #if PointClouds.ispointinpolyhedron(model,point) # se il punto è interno allora
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
        #end
    end
end

function searchfile(path,key)
	files = String[]
	for (root, _, _) in walkdir(path)
		thisfiles=filter(x->occursin(key,x), readdir(root,join=true))
		union!(files,thisfiles)
	end
	return files
end
