
"""
	loadlas(fname::String...)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read more than one file `.las` and extrapolate the LAR model and the color of each point.

"""
function loadlas(fname::String...)::Tuple{Lar.Points,Array{Array{Int64,1},1},Array{LasIO.N0f16,2}}
	Vtot = Array{Float64,2}(undef, 3, 0)
	rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
	for name in fname
		V,VV = PointClouds.las2lar(name)
		rgb = PointClouds.lascolor(name)
		Vtot = hcat(Vtot,V)
		rgbtot = hcat(rgbtot,rgb)
	end
	return Vtot,[[i] for i in 1:size(Vtot,2)],rgbtot
end

"""
	las2lar(fname::String)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read data from a file `.las`:
- generate the LAR model `(V,VV)`
- extrapolate color associated to each point
"""
function las2lar(fname::String)::Tuple{Lar.Points,Array{Array{Int64,1},1}}
	header, laspoints =  PointClouds.readpotreefile(fname)
	npoints = length(laspoints)
	x = [LasIO.xcoord(laspoints[k], header) for k in 1:npoints]
	y = [LasIO.ycoord(laspoints[k], header) for k in 1:npoints]
	z = [LasIO.zcoord(laspoints[k], header) for k in 1:npoints]
	return vcat(x',y',z'), [[i] for i in 1:npoints]
end

"""
	las2aabb(fname::String)

Return the AABB of the file `fname`.

"""
function las2aabb(fname::String)
	header, p =  PointClouds.readpotreefile(fname)
	#header = read(fname, LasIO.LasHeader)
	AABB = LasIO.boundingbox(header)
	return reshape([AABB.xmin;AABB.ymin;AABB.zmin],(3,1)),reshape([AABB.xmax;AABB.ymax;AABB.zmax],(3,1))
end

function las2aabb(header::LasHeader)
	AABB = LasIO.boundingbox(header)
	return (hcat([AABB.xmin;AABB.ymin;AABB.zmin]),hcat([AABB.xmax;AABB.ymax;AABB.zmax]))
end


"""
	lascolor(fname::String)::Tuple{Lar.Points,Array{LasIO.N0f16,2}}

Read data from a file `.las`:
- extrapolate color associated to each point.
"""
function lascolor(fname::String)::Array{LasIO.N0f16,2}
	header, laspoints =  PointClouds.readpotreefile(fname)
	npoints = length(laspoints)
	type = LasIO.pointformat(header)
	if type != LasPoint0 && type != LasPoint1
		r = LasIO.ColorTypes.red.(laspoints)
		g = LasIO.ColorTypes.green.(laspoints)
		b = LasIO.ColorTypes.blue.(laspoints)
		return vcat(r',g',b')
	end
	return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end

function color(p::LasPoint, header::LasHeader)
	type = LasIO.pointformat(header)
	if type != LasPoint0 && type != LasPoint1
		r = LasIO.ColorTypes.red(p)
		g = LasIO.ColorTypes.green(p)
		b = LasIO.ColorTypes.blue(p)
		return vcat(r',g',b')
	end
	return rgbtot = Array{LasIO.N0f16,2}(undef, 3, 0)
end

"""
	 xyz(p::LasPoint, h::LasHeader)

Return coords of this laspoint p.
"""
function xyz(p::LasPoint, h::LasHeader)
	return [LasIO.xcoord(p, h); LasIO.ycoord(p, h); LasIO.zcoord(p, h)]
end

"""
	savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})

save file .las in writefile.
"""
function savenewlas(writefile::String,h::LasIO.LasHeader,p::LasIO.Array{LasPoint,1})
    if ispath(writefile) #overwrite
        rm(writefile)
    end
    LasIO.FileIO.save(writefile,h,p)
end

"""
	mergelas(headers,pointdata,bb,scale)

Merge more file .las.
"""
function mergelas(headers,pointdata)
	@assert length(headers) == length(pointdata) "mergelas: inconsistent data"

	# header of merging las
	hmerge = createheader(headers,pointdata)
	data = LasIO.LasPoint[]

	# Las point data merge
	for i in 1:length(pointdata)
		for p in pointdata[i]
			laspoint = createlasdata(p,headers[i],hmerge)
			push!(data,laspoint)
		end
	end

	return hmerge,data
end

"""
 	createheader(headers,pointdata,bb,scale)

crea header coerente con i miei punti.
"""
function createheader(headers,pointdata)
	type = pointformat(headers[1])
	h = deepcopy(headers[1])
	h.records_count = sum(length.(pointdata))
	return h
end

"""
 	createlasdata(p,h,header)

Generate laspoint coerenti con il mio header (soprattutto per quanto riguarda la traslazione).
"""
function createlasdata(p,h::LasIO.LasHeader,hmerge::LasIO.LasHeader)
	type = pointformat(h)

	x = LasIO.xcoord(xcoord(p,h),hmerge)
	y = LasIO.ycoord(ycoord(p,h),hmerge)
	z = LasIO.zcoord(zcoord(p,h),hmerge)
	intensity = p.intensity
	flag_byte = p.flag_byte
	raw_classification = p.raw_classification
	scan_angle = p.scan_angle
	user_data = p.user_data
	pt_src_id = p.pt_src_id

	if type == LasIO.LasPoint0
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id
					)

	elseif type == LasIO.LasPoint1
		gps_time = p.gps_time
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time
					)

	elseif type == LasIO.LasPoint2
		red = p.red
		green = p.green
		blue = p.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id,
					red, green, blue
					)

	elseif type == LasIO.LasPoint3
		gps_time = p.gps_time
		red = p.red
		green = p.green
		blue = p.blue
		return type(x, y, z,
					intensity, flag_byte, raw_classification,
					scan_angle, user_data, pt_src_id, gps_time,
					red, green, blue
					)

	end
end

"""
	bbincremental!(coordpoint,bb)

"""
function bbincremental!(coordpoint,bb)

	for i in 1:length(coordpoint)
		if coordpoint[i] < bb[1][i]
			bb[1][i] = coordpoint[i]
		end
		if coordpoint[i] > bb[2][i]
			bb[2][i] = coordpoint[i]
		end
	end

	return true
end

function readpotreefile(fname::String)
	if endswith(fname,".las")
		header, laspoints = LasIO.FileIO.load(fname)
	elseif endswith(fname,".laz")
		header, laspoints = LazIO.load(fname)
	end
	return header,laspoints
end
