"""
Return the image of orthoprojection.
"""
function orthoprojectionimage(txtpotreedirs::String, outputjpg::String, bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}}, GSD::Float64, PO::String )
    # check validity
    @assert isdir(txtpotreedirs) "orthoprojectionimage: $txtpotreedirs not an existing file"
    @assert isdir(folder) "orthoprojectionimage: $folder not an existing folder"
    @assert length(PO)==3 "orthoprojectionimage: $PO not valid view "

    #metto tutto qui poi separo in sotto funzioni
    # initialization
    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)

    coordsystemmatrix = PointClouds.newcoordsyst(PO)

    RGBtensor, rasterquote, resX, resY = PointClouds.initrasterarray(coordsystemmatrix,GSD,model)

    # jpg creation
    # PointClouds.imagecreation(potreedirs,outputjpg,model,GSD,PO)
    println("image saved in $outputjpg")

end

# function imagecreation(potreedirs::Array{String,1}, outputjpg::String, model::Lar.LAR, GSD::Float64, PO::String)
#     verts,edges,faces = model
#     minGlobalBounds, maxGlobalBounds = Lar.boundingbox(verts)
#     RGBArray = initrasterarray(coordsystemmatrix, GSD, verts)
#
#     save(outputjpg, colorview(RGB, RGBArray))
# end


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
        R=[-1. 0 0; 0 1. 0; 0 0 -1]
        coordsystemmatrix = R*coordsystemmatrix
    end
    return coordsystemmatrix
end


"""
initialize raster image.
"""
function initrasterarray(coordsystemmatrix::Array{Float64,2}, GSD::Float64, model::Lar.LAR)

    # prova per la costruzione di BBPO su un generico piano
    function projdist(unitvector)
        function projdist0(vert)
            return Lar.dot(unitvector,vert)
        end
        return projdist0
    end


    verts,edges,faces = model

    bbglobalextention = zeros(3)
    for i in 1:3
        coord=PointClouds.projdist(coordsystemmatrix[i,:]).([verts[:,j] for j in 1:size(verts,2)])
        min,max = extrema(coord)
        bbglobalextention[i] = max-min
    end

    resX = map(Int∘trunc,bbglobalextention[1] / GSD) + 1
    resY = map(Int∘trunc,bbglobalextention[2] / GSD) + 1

    # Z-BUFFER MATRIX
    rasterquote = fill(-Inf,(resY,resX))

    # RASTER IMAGE MATRIX
    rasterChannels = 3
    RGBtensor = fill(1.,(rasterChannels,resY, resX))

    return RGBtensor, rasterquote, resX, resY
end
