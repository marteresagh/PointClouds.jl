mutable struct Plane
    normal::Array{Float64,1}
    centroid::Array{Float64,1}
end

struct PlaneDataset
    points::Lar.Points
    plane::Plane
end

mutable struct AxisAlignedBoundingBox
    x_max::Float64
    x_min::Float64
    y_max::Float64
    y_min::Float64
    z_max::Float64
    z_min::Float64
end

struct CloudMetadata
    version::String
    octreeDir::String
    projection::String
    points::Int64
    boundingBox::AxisAlignedBoundingBox
    tightBoundingBox::AxisAlignedBoundingBox
    pointAttributes::String
    spacing::Float64
    scale::Float64
    hierarchyStepSize::Int32

    function CloudMetadata(path::String)
        dict = Dict{String,Any}[]
        open(path * "\\cloud.js", "r") do f
            dict = JSON.parse(f)  # parse and transform data
        end
        version = dict["version"]
        if version == "1.7"
            octreeDir = dict["octreeDir"]
            projection = dict["projection"]
            points = dict["points"]
            dictAABB = dict["boundingBox"]
            dicttightBB = dict["tightBoundingBox"]
            boundingBox = PointClouds.AxisAlignedBoundingBox(dictAABB["ux"],dictAABB["lx"],dictAABB["uy"],dictAABB["ly"],dictAABB["uz"],dictAABB["lz"])
            tightBoundingBox = PointClouds.AxisAlignedBoundingBox(dicttightBB["ux"],dicttightBB["lx"],dicttightBB["uy"],dicttightBB["ly"],dicttightBB["uz"],dicttightBB["lz"])

            # AABB = (hcat([dictAABB["lx"],dictAABB["ly"],dictAABB["lz"]]),
            # 		hcat([dictAABB["ux"],dictAABB["uy"],dictAABB["uz"]]))
            # tightBB = (hcat([dicttightBB["lx"],dicttightBB["ly"],dicttightBB["lz"]]),
            # 			hcat([dicttightBB["ux"],dicttightBB["uy"],dicttightBB["uz"]]))

            pointAttributes = dict["pointAttributes"]
            spacing = dict["spacing"]
            scale = dict["scale"]
            hierarchyStepSize = dict["hierarchyStepSize"]

            CloudMetadata(
            version,
            octreeDir,
            projection,
            points,
            boundingBox,
            tightBoundingBox,
            pointAttributes,
            spacing,
            scale,
            Int32(hierarchyStepSize)
            )
        end
    end

end
