function orthoprojectionimage(txtpotreedirs::String, outputjpg::String, bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}}, GSD::Float64, PO::String )
    # check validity
    @assert isdir(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
    @assert isdir(folder) "orthoprojectionimage: $folder not an existing folder"
    @assert length(PO)==3 "orthoprojectionimage: $PO not valid view "
    # initialization
    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)

    verts,edges,faces = model
    BBPO = Lar.boundingbox(verts) #da rivedere il BBPO su piano generico


    coordsystemmatrix = PointClouds.newcoordsyst(PO)

    RGBArray, rasterquote = PointClouds.createrasterarray(coordsystemmatrix,GSD,BBPO)

    # jpg creation
    # PointClouds.imagecreation(potreedirs,outputjpg,model,GSD,PO)
    println("jpg saved in $outputjpg")

end

function imagecreation(potreedirs::Array{String,1}, outputjpg::String, model::Lar.LAR, GSD::Float64, PO::String)
    # devo creare il raster
    # devo conoscere il aabb di bbin
    # e calcolare la risoluzione
    # e definire cosìil tensore dell'immagine
    verts,edges,faces = model
    minGlobalBounds, maxGlobalBounds = Lar.boundingbox(verts)
    RGBArray =
    save(outputjpg, colorview(RGB, RGBArray))
end


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
        R=[-1. 0 0; 0 1. 0; 0 0 -1]
        coordsystemmatrix = R*coordsystemmatrix
    end
    return coordsystemmatrix
end


function createrasterarray(coordsystemmatrix::Array{Float64,2}, GSD::Float64, BBPO::Tuple{Array{Float64,2},Array{Float64,2}})
    
    # Z-BUFFER MATRIX
    rasterQuote = fill(-Inf,(resY,resX))

    # RASTER IMAGE MATRIX
    rasterChannels = 3
    RGBArray = fill(1.,(rasterChannels,resY, resX))


    b
    h
    return RGBArray, rasterquote
end
