function imagecreation(txtpotreedirs::String, outputjpg::String, bbin::Union{String,Tuple{Array{Float64,2},Array{Float64,2}}}, GSD::Float64, PO::String )
    @assert isdir(txtpotreedirs) "imagecreation: $txtpotreedirs not an existing file"
    @assert isdir(folder) "filesegment: $folder not an existing folder"

    potreedirs = PointClouds.getdirectories(txtpotreedirs)
    model = PointClouds.getmodel(bbin)

end

function
