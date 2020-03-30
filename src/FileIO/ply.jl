"""
save lar model
"""
function saveply(f, model::Lar.LAR)
    io = open(f,"w")
        vts,fcs = model

        nV = size(vts,2)
        nF = length(fcs)
        nface = length(fcs[1])


        # write the header
        write(io, "ply\n")
        write(io, "format ascii 1.0\n")
        write(io, "element vertex $nV\n")
        write(io, "property float x\nproperty float y\nproperty float z\n")
        write(io, "element face $nF\n")
        write(io, "property list uchar int vertex_index\n")
        write(io, "end_header\n")

        # write the vertices and faces
        for i in 1:nV
            println(io, join(vts[:,i], " "))
        end
        for i in 1:nF
            println(io, nface, " ", join(fcs[i].-1, " "))
        end
    close(io)
end

"""
save point clouds
"""
function saveply(f, vertices, normals, rgb)
    io = open(f,"w")
        vts,fcs = model

        nV = size(vts,2)
        nF = length(fcs)
        nface=length(fcs[1])


        # write the header
        write(io, "ply\n")
        write(io, "format ascii 1.0\n")
        write(io, "element vertex $nV\n")
        write(io, "property float x\nproperty float y\nproperty float z\n")
        write(io, "end_header\n")

        # write the vertices and faces
        for i in 1:nV
            println(io, join(vts[:,i], " "))
        end
        for i in 1:nF
            println(io, nface, " ", join(fcs[i].-1, " "))
        end
    close(io)
end


# function load(fs::Stream{format"PLY_ASCII"}, MeshType=GLNormalMesh)
#     io = stream(fs)
#     nV = 0
#     nF = 0
#
#     properties = String[]
#
#     # read the header
#     line = readline(io)
#
#     while !startswith(line, "end_header")
#         if startswith(line, "element vertex")
#             nV = parse(Int, split(line)[3])
#         elseif startswith(line, "element face")
#             nF = parse(Int, split(line)[3])
#         elseif startswith(line, "property")
#             push!(properties, line)
#         end
#         line = readline(io)
#     end
#     VertexType  = vertextype(MeshType)
#     FaceType    = facetype(MeshType)
#     FaceEltype  = eltype(FaceType)
#
#     vts         = Array{VertexType}(undef, nV)
#     #fcs         = Array{FaceType}(undef, nF)
#     fcs         = FaceType[]
#
#     # read the data
#     for i = 1:nV
#         vts[i] = VertexType(parse.(eltype(VertexType), split(readline(io)))) # line looks like: "-0.018 0.038 0.086"
#     end
#
#     for i = 1:nF
#         line    = split(readline(io))
#         len     = parse(Int, popfirst!(line))
#         if len == 3
#             push!(fcs, Face{3, FaceEltype}(reinterpret(ZeroIndex{Int}, parse.(Int, line)))) # line looks like: "3 0 1 3"
#         elseif len == 4
#             push!(fcs, decompose(FaceType, Face{4, FaceEltype}(reinterpret(ZeroIndex{Int}, parse.(Int, line))))...) # line looks like: "4 0 1 2 3"
#         end
#     end
#
#     return MeshType(vts, fcs)
# end
