#
# ################################ load Volume debug
#
# UCS=[  0.7659698  0.6427249  0.0139622;
#   -0.6411936  0.7622139 0.0888856;
#    0.0464868 -0.0770362  0.9959440 ]
#
# RotXYZ(UCS)
# RotXYZ(-5.1*pi/180,0.8*pi/180, -40*pi/180)
#
#
#  MrotationVol = [  0.9986295 -0.0523360  0.0000000;
#       0.0523360  0.9986295  0.0000000;
#       0.0000000  0.0000000  1.0000000 ]
#
# apply_matrix = UCS*MrotationVol
#
# using Rotations
#
#
# RotXYZ(apply_matrix )
#
# [-0.0890118, 0.0139627, -0.645772]*180/pi
#
# b=RotXYZ(UCS)
#
# a=RotXYZ(MrotationVol )
#
# eu_ucs = [-0.0, 0.0, 0.0523599]
#
# eu_vol=[-0.0890118, 0.0139627, -0.698132]
#
# 180/pi*(eu_ucs+eu_vol)
#
#
# ###########################################################################
#
# UCS = [  0.7659698  0.6427249  0.0139622;
#   -0.6411936  0.7622139 0.0888856;
#    0.0464868 -0.0770362  0.9959440 ]
#
# # sbagliato
# euler_ucs = RotXYZ(UCS)
# euler_ucs = [-0.0890118, 0.0139627, -0.698132]
# RotXYZ(UCS)
# RotXYZ(MrotationVol )
#
# eu_ucs = [-0.0890118, 0.0139627, -0.698132]
#
# eu_vol=[0.785398, 0.523599, 0.0]
#
# 180/pi*(eu_ucs+eu_vol)
#
#
# # giusto
# # 1. matrice ucs
# # 2. calcolo la matrice dagli angoli in radianti
# # 3. applico ucs
# # 4. ricalcolo angoli di eulero di questa nuova matrice
#
# UCS = [  0.7659698  0.6427249  0.0139622;
#   -0.6411936  0.7622139 0.0888856;
#    0.0464868 -0.0770362  0.9959440 ]
#
# rotationVol = RotXYZ(45*pi/180,30*pi/180,0*pi/180 )
#
# newVolume = UCS*rotationVol
#
# euler_volumeconucs = RotXYZ(newVolume )
#
# [0.822613, -0.00205205, -0.482899]*180/pi
#

# using ViewerGL
# GL=ViewerGL
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation
# include("viewfunction.jl")
using PointClouds

txtpotreedirs = "C:/Users/marte/Documents/GEOWEB/FilePotree/orthophoto/directory.txt"

ucs = "C:/Users/marte/Documents/GEOWEB/FilePotree/orthophoto/ucs_su_ucs.json"

potreedirs = PointClouds.getdirectories(txtpotreedirs)
typeofpoint,scale,npoints,AABB,tightBB,octreeDir,hierarchyStepSize,spacing = PointClouds.readcloudJSON(potreedirs[1])
bbin = "C:/Users/marte/Documents/GEOWEB/FilePotree/orthophoto/orthophoto.json"
model = PointClouds.getmodel(bbin)
quota = nothing
thickness = nothing
GSD = 0.3
PO = "XZ+"
outputimage = "ucs_e_volume$PO.jpg"
pc = true

PointClouds.orthophoto( txtpotreedirs,
                        outputimage,
                        bbin,
                        GSD,
                        PO,
                        quota,
                        thickness,
                        ucs,
                        pc
                        )

outputfile = "extraction.las"
PointClouds.pointExtraction( txtpotreedirs,
						outputfile,
						bbin,
						quota,
						thickness
						)
