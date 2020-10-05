"""
Save point cloud extracted.
"""
function savepointcloud(
	params::Union{ParametersOrthophoto,ParametersExtraction},
	n::Int64,
	temp,
	)

	PointClouds.flushprintln("Point cloud: saving ...")

	params.mainHeader.records_count = n
	pointtype = pointformat(params.mainHeader)

	PointClouds.flushprintln("Extracted $n points")

	open(temp) do s
		open(params.outputfile,"w") do t
			write(t, LasIO.magic(LasIO.format"LAS"))
			write(t,params.mainHeader)

			LasIO.skiplasf(s)
			for i=1:n
				p = read(s, pointtype)
				write(t,p)
			end
		end
	end

	rm(temp)
	PointClouds.flushprintln("Point cloud: done ...")
end
