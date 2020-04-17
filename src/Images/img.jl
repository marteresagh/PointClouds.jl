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
function imagecreation(potreedirs::Array{String,1},params)
    model, coordsystemmatrix, GSD, RGBtensor, rasterquote, refX, refY = params
    aabbmodel = Lar.boundingbox(model[1])
    for potree in potreedirs
        println("======== PROJECT $potree ========")

        scale,npoints,AABBoriginal,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potree) # useful parameters togli quelli che non usi
    	tree = joinpath(potree,octreeDir,"r") # path to directory "r"

    	println("Search in $tree ")

    	# 2.- check all file
    	for (root, _, _) in walkdir(tree)
            files=PointClouds.searchfile(root,".las")

            println("Search in $root ")
            println("$(length(files)) files to process")
    		for i in 1:length(files) # legge tutti i files

                if i%10==0
                    println("$i files processed")
                end

			    lasfile = joinpath(root, files[i]) # path to file
				header, laspoints = LasIO.FileIO.load(lasfile)
                nodebb = PointClouds.las2aabb(header)

                if PointClouds.AABBdetection(nodebb,aabbmodel) #se il nodo e il modello si intersecano allora
                    PointClouds.updateimage!(params,header,laspoints)
                end
				#break
    		end

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


searchfile(path,key) = filter(x->occursin(key,x), readdir(path,join=true))
