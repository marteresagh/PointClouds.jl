using LinearAlgebraicRepresentation
using PointClouds
Lar=LinearAlgebraicRepresentation
filename="partof"
from="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
to="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
#aabb=([2.3229684731e6, 4.7701318677e6, 290.14549999999997], [2.3229684731e6+100, 4.7701318677e6+1, 290.14549999999997+1]) #cupola
#aabb=([458117.67680569435; 4.49376852930242e6; 196.68409729003906], [458319.30180569435; 4.49397015430242e6; 398.30909729003906]) #cava
aabb=([458168.08305569435; 4.49386934180242e6; 196.68409729003906], [458193.28618069435; 4.49389454492742e6; 221.88722229003906])
V=[458168.08305569435 458168.08305569435 458168.08305569435 458168.08305569435 458193.28618069435 458193.28618069435 458193.28618069435 458193.28618069435;
    4.49386934180242e6 4.49386934180242e6 4.49389454492742e6 4.49389454492742e6 4.49386934180242e6 4.49386934180242e6 4.49389454492742e6 4.49389454492742e6;
    196.68409729003906 221.88722229003906  196.68409729003906 221.88722229003906 196.68409729003906 221.88722229003906 196.68409729003906 221.88722229003906]
V1,(VV,EV,FV,CV)=Lar.cuboid([1,1,1],true)
model = V,EV,FV
PointClouds.segmentcloud(filename,from,to,model)



from="C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
allfile=PointClouds.filelevel(from,4)
