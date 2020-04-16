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

    RGBtensor, rasterquote, refX, refY = PointClouds.initrasterarray(coordsystemmatrix,GSD,model)

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

    verts,edges,faces = model
    bbglobalextention = zeros(2) # basta farlo sui primi due, X e Y quanto è profonda la scatola non mi interessa in questo momento
    ref = zeros(2)

    # questo loop calcola le dimensioni del raster e mi restituisce i valori di riferimento per la creazione dell'immagine
    # qualunque sia la vista senza la costruzione del BBPO solo allineato agli assi
    for i in 1:2
        coord = PointClouds.projdist(coordsystemmatrix[i,:]).([verts[:,j] for j in 1:size(verts,2)])
        extr = extrema(coord)
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

#prova su punti di esempio poi da estende ai punti della nuvola
function image(V,rgb::Lar.Points, coordsystemmatrix, RGBtensor, rasterquote, refX, refY, GSD)
    npoints = size(V,2)
    for i in 1:npoints
        x = PointClouds.projdist(coordsystemmatrix[1,:])(V[:,i])
        y = PointClouds.projdist(coordsystemmatrix[2,:])(V[:,i])
        z = PointClouds.projdist(coordsystemmatrix[3,:])(V[:,i])
        xcoord = map(Int∘trunc,(x-refX) / GSD)+1
        ycoord = map(Int∘trunc,(refY-y) / GSD)+1
        if rasterquote[ycoord,xcoord] < z
            rasterquote[ycoord,xcoord] = z
            RGBtensor[1, ycoord, xcoord] = rgb[1,i]
            RGBtensor[2, ycoord, xcoord] = rgb[2,i]
            RGBtensor[3, ycoord, xcoord] = rgb[3,i]
        end
    end
    return RGBtensor
end

function projdist(unitvector)
    function projdist0(vert)
        return Lar.dot(unitvector,vert)
    end
    return projdist0
end
