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
		planes = PlaneDetectionFromRandomInitPoint(V::Lar.Points, par::Float64, spacing)
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



mutable struct Model
    G::Lar.Points
    T::Array{Lar.ChainOp, 1}

    """
        Model(V::Lar.Points, T::Array{Lar.ChainOp, 1})

    Generic constructor for CAGD.Model.
    Coherency checks are performed between Topology and Geometry
    """
    function Model(V::Lar.Points, T::Array{Lar.ChainOp, 1})
        dim, npts = size(V)
        dim > 0 ||
            throw(ArgumentError("At least one point is needed."))
        length(T) == dim ||
            throw(ArgumentError("Topology is not coherent with Geometry."))

        size(T[1], 2) == npts ||
            throw(ArgumentError("Topology not coherent with Geometry."))
        for i = 2 : dim
            isempty(T[i-1]) || size(T[i], 2) == size(T[i-1],1) ||
                throw(ArgumentError("Topology not coherent with Topology."))
        end

        new(V, T)
    end

    function Model(V::Lar.Points, T::Array{Lar.Cells, 1})
        m = Model(V)
        addModelCells!(m, 1, T[1], signed=true)
        cFE = convert(Lar.ChainOp, Lar.coboundary_1(m.G, T[2], T[1]))
        addModelCells!(m, 2, cFE)
        return m
    end

    """
        Model(V::Lar.Points, EV::Lar.Cells)

    Builds a signed CAGD.Model with vertices and edges only.
    """
    function Model(V::Lar.Points, EV::Lar.Cells)

        I = Array{Int,1}()
        J = Array{Int,1}()
        K = Array{Int8,1}()
        for i = 1 : length(EV)
            let sign = -1;  for j = 1 : length(EV[i])
                push!(I, i)
                push!(J, EV[i][j])
                push!(K, sign)
                sign = 1
            end  end
        end

        T = [SparseArrays.sparse(I, J, K, length(EV), size(V, 2))]
        if size(V, 1) > 1  push!(T, SparseArrays.spzeros(Int8, 0, length(EV)))  end
        Ts = SparseArrays.spzeros(Int8, 0, 0)
        for i = 3 : size(V, 1)  push!(T, Ts)  end
        Model(V, T)
    end

    """
        Model(V::Lar.Points)

    Constructor for CAGD.Model with geometry only.
    Topology is set to void by default.
    """
    function Model(V::Lar.Points)
        T = convert(Array{Lar.ChainOp,1},
            [SparseArrays.spzeros(Int8, 0, 0) for i = 1 : size(V, 1)]
        )
        T[1] = convert(Lar.ChainOp, SparseArrays.spzeros(Int8, 0, size(V,2)))
        Model(V, T)
    end

    """
        Model()

    Void constructor for CAGD.Model.
    Returns `nothing`
    """
    function Model()
        nothing
    end
end
