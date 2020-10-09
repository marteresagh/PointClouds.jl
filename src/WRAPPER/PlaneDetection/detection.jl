struct PlaneDetectionParams
	pointcloud::Lar.Points
	cloudMetadata::PointClouds.CloudMetadata
	LOD::Int32
	output::String
	rnd::Bool
	seedPoints::Lar.Points
	random::Bool
	failed::Int32
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

	if params.rnd
		thres = params.cloudMetadata.spacing
		planes = PlaneDetectionFromRandomInitPoint(V, par, 2*thres, failed)
	else
		planes = PlaneDetectionFromGivenPoints(V, FV, givenPoints, par)
	end

	savePlanesDataset(planes)

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
	rnd = true
	seedPoints = Lar.Points
	if !isnothing(fileseedpoints)
		rnd = false
		seedPoints = seedPointsFromFile(fileseedpoints)
	end


	return PlaneDetectionParams(
	pointcloud,
	cloudMetadata,
	Int32(LOD),
	output,
	rnd,
	seedPoints,
	random,
	Int32(failed)
	)
end




# ==============  SAVES DONE

function savePlanesDataset(planes::Array{PlaneDataset,1},params::PlaneDetectionParams)
	for i in 1:length(planes)
		filename = params.output+"/plane$i"
		savePlane(plane.plane,filename+."txt")
		savePoints(plane.points,filename*".las")
	end
end

function savePlane(plane::Plane, filename::String)
	# plane2json(plane::Plane, filename::String)  JSON FORMAT
	io = open(filename,"w")
	write(io, "$(plane.normal[1]) $(plane.normal[2]) $(plane.normal[3]) ")
	write(io, "$(plane.centroid[1]) $(plane.centroid[2]) $(plane.centroid[3])")
	close(io)
end

function savePoints(points::Lar.Points, filename::String)
	aabb = Lar.boundingbox(points)
	npoints = size(points,2)
	header = PointClouds.newHeader(aabb,"PLANEDETECTION",SIZE_DATARECORD,npoints)

	pvec = Array{LasPoint,1}(undef,npoints)
	for i in 1:npoints
		point = PointClouds.newPointRecord(points[:,i], rgb[:,i], LasIO.LasPoint2, header)
		pvec[i] = point
	end

	LasIO.save(filename,header,pvec)
end
