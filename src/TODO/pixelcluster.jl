#
# function preprocess(img)
# 	white = RGB{N0f8}(1.0,1.0,1.0)
# 	mat = channelview(img)
# 	n,m = size(img)
# 	allwhitepixel = DataStructures.Dict{Array{Int64,1}, Bool}()
# 	for i in 2:n-1
# 		for j in 2:m-1
# 			if img[i,j]==white
# 				allwhitepixel[[i,j]] = false
# 			end
# 		end
# 	end
# 	return allwhitepixel
# end
#
# regions = DataStructures.Dict{Array{Int64,1}, Array{Array{Int64,1},1}}()
#
#
# function floodfill(nodo,allwhitepixel,regions)
# 	i,j = nodo
# 	if haskey(allwhitepixel,[i,j]) && allwhitepixel[[i,j]] == false
# 		allwhitepixel[[i,j]] = true
# 		push!(regions,[i,j])
# 		floodfill([i-1,j],allwhitepixel,regions)
# 		floodfill([i,j-1],allwhitepixel,regions)
# 		floodfill([i+1,j],allwhitepixel,regions)
# 		floodfill([i,j+1],allwhitepixel,regions)
# 	end
# end
#
# allwhitepixel = preprocess(img)
#
# regions = Array{Int64,1}[]
#
# floodfill([2,2],allwhitepixel,regions)
#
# function clusters(img)
# 	allwhitepixel = preprocess(img)
# 	cluss = DataStructures.Dict{Array{Int64,1}, Array{Array{Int64,1},1}}()
#
# 	# while !isempty(allwhitepixel)
# 		regions = Array{Int64,1}[]
# 		k = collect(keys(allwhitepixel))[1]
# 		floodfill(k,allwhitepixel,regions)
# 		cluss[k]=regions
#
# 		for item in regions
# 			delete!(allwhitepixel,item)
# 		end
# 	# end
#
# 	return cluss
# end


using DataStructures
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Images, StatsBase
#
# RGBtensor = fill(1.,(3,10, 6))
#
# RGBtensor[:,1,:] .= 0.
# RGBtensor[:,:,1] .= 0.
# RGBtensor[:,end,:] .= 0.
# RGBtensor[:,:,end] .= 0.
# RGBtensor[:,2,5] .= 0.
# RGBtensor[:,3,4] .= 0.
# RGBtensor[:,4,4] .= 0.
# RGBtensor[:,5,3] .= 0.
# RGBtensor[:,5,6] .= 0.
# RGBtensor[:,6,2] .= 0.
# RGBtensor[:,6,5] .= 0.
# RGBtensor[:,7,4] .= 0.
# RGBtensor[:,8,2] .= 0.
# RGBtensor[:,8,3] .= 0.
# RGBtensor[:,8,4] .= 0.
# RGBtensor[:,9,4] .= 0.
# RGBtensor[:,10,4] .= 0.
#
#
# save("pixel.png", Images.colorview(RGB, RGBtensor))

function binaryimg(img)
	white = RGB{N0f8}(1.0,1.0,1.0)
	n,m = size(img)
	bimg = falses(n,m)
	for i in 1:n
		for j in 1:m
			if img[i,j]==white
				bimg[i,j] = true
			end
		end
	end
	return bimg
end



img_path = "pixel.png"
img_path = "C:\\Users\\marte\\Documents\\GEOWEB\\prova01XY+.png"
img = load(img_path)
img[980:1000,980:1000]
bimg = binaryimg(img[980:1000,980:1000])

labels = label_components(bimg)

mapcluster=sort(countmap(labels; alg=:dict))
