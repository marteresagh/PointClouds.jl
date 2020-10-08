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
end
