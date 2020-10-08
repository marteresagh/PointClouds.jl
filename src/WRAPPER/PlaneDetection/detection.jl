struct PlaneDetectionParams
        pointcloud::Lar.Points
        cloudMetadata::CloudMetadata
        LOD::Int64,
        output::String
        random::Bool
        seedPoints::Lar.Points
        random::Bool
end

function PlaneDetection(source::String,
                        output::String,
                        LOD::Int64,
                        par::Float64,
                        fileseedpoints::String,
                        failed::Int64,
                        maxnumplanetofind::Int64)

        params = PointClouds.init(source::String,
                        output::String,
                        LOD::Int64,
                        par::Float64,
                        fileseedpoints::String,
                        failed::Int64,
                        maxnumplanetofind::Int64)

        if params.random
                planes = PlaneDetectionFromRandomInitPoint(V::Lar.Points, par::Float64, spacing)
        else
                planes = PlaneDetectionFromGivenPoints(V::Lar.Points, FV::Lar.Cells, givenPoints::Lar.Points, par::Float64)
        end

        savePlanes(planes)

end


function init(source::String,
                output::String,
                LOD::Int64,
                par::Float64,
                fileseedpoints::Union{Nothing,String},
                failed::Int64,
                maxnumplanetofind::Int64)


        #input
        allfile = PointClouds.filelevel(source,LOD,false)
        cloudMetadata = PointClouds.cloud_metadata(source)
        pointcloud,_,rgb = PointClouds.loadlas(allfile...)

        #output
        if !isdir(output)
                mkdir(output)
        end

        #seedpoints
        random = true
        if !isnothing(seedpoints)
                random = false
                seedPoints = seedPointsFromFile(fileseedpoints)
        end


        return PlaneDetectionParams(
                                pointcloud::Lar.Points,
                                cloudMetadata::CloudMetadata,
                                LOD::Int64,
                                output::String,
                                random::Bool,
                                seedPoints::Lar.Points,
                                random::Bool
                                )
end


function savePlanes(planes::Array{PlaneDataset,1},params::PlaneDetectionParams)
        for i in 1:length(planes)
		filename = params.output+"/plane$i.txt"
                saveplane(plane.plane,filename)
                savepoints(plane.points,filename)
        end
end

function saveplane(plane::Plane, filename::String)
        io = open(filename,"w")
	write(io, "$(plane.normal[1]) $(plane.normal[2]) $(plane.normal[3]) ")
	write(io, "$(plane.centroid[1]) $(plane.centroid[2]) $(plane.centroid[3])")
	close(io)
end

function savepoints(points::Lar.Points, filename::String)
	aabb = Lar.boundingbox(points)
        header = PointClouds.newHeader(aabb,"PlaneDetection",SIZE_DATARECORD)
        
        savelas()
end
