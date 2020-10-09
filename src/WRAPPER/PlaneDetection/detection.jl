struct PlaneDetectionParams
	pointcloud::Lar.Points
	cloudMetadata::CloudMetadata
	LOD::Int32,
	output::String
	random::Bool
	seedPoints::Lar.Points
	random::Bool
end

function PlaneDetection(
	source::String,
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
		thres = params.cloudMetadata.spacing
		planes = PlaneDetectionFromRandomInitPoint(V::Lar.Points, par::Float64, 2*thres)
	else
		planes = PlaneDetectionFromGivenPoints(V::Lar.Points, FV::Lar.Cells, givenPoints::Lar.Points, par::Float64)
	end

	savePlanes(planes)

end


function init(
	source::String,
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
	seedPoints = Lar.Points
	if !isnothing(fileseedpoints)
		random = false
		seedPoints = seedPointsFromFile(fileseedpoints)
	end


	return PlaneDetectionParams(
	pointcloud,
	cloudMetadata,
	Int32(LOD),
	output,
	random,
	seedPoints,
	random
	)
end

function savePlanes(planes::Array{PlaneDataset,1},params::PlaneDetectionParams)
	for i in 1:length(planes)
		filename = params.output+"/plane$i"
		saveplane(plane.plane,filename+."txt")
		savepoints(plane.points,filename*".las")
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
	npoints = size(points,2)
	header = PointClouds.newHeader(aabb,"PLANEDETECTION",SIZE_DATARECORD,npoints)

	pvec = LasPoint[]
	for i in 1:size(points,2)
		point = PointClouds.newPointRecord(points[:,i], rgb[:,i], LasIO.LasPoint2, header)
		push!(pvec,point)
	end

	LasIO.save(filename,header,pvec)
end
