echo March 2 2018
echo Alivia Cavallin, Che Elkin, Colin Chisholm

echo Add LAStools to path
set PATH=%PATH%;E:\LAStools\bin

echo change directory
cd E:\FLNR_PEM\Kamloops_PEM\

echo make directories
mkdir n_heights
mkdir percentiles_grain_5
mkdir percentiles_grain_10
mkdir percentiles_grain_25
mkdir percentiles_grain_50

echo get lasground data and run lasheight to get normalized heights
lasheight -i tile_ground\*.las -odir n_heights -replace_z -cores 4 


echo run lascanopy with lasheight data; minimal elevation is set to 0.1 m, step size is grain size


echo for grain size  5
echo lascanopy -i n_heights\*.las -merged -p 50 -height_cutoff 0.1 -step 5 -odir percentiles -o percentiles_.tif
lascanopy -i n_heights\*.las -merged -p 50 75 90 95 -height_cutoff 0.1 -step 5 -odir percentiles_grain_5 -o pb.bil -cores 4


echo for grain size 10
lascanopy -i n_heights\*.las -merged -p 50 75 90 95 -height_cutoff 0.1 -step 10 -odir percentiles_grain_10 -o pb.bil -cores 4


echo for grain size 25
lascanopy -i n_heights\*.las -merged -p 50 75 90 95 -height_cutoff 0.1 -step 25 -odir percentiles_grain_25 -o pb.bil -cores 4


echo for grain size 50
lascanopy -i n_heights\*.las -merged -p 50 75 90 95 -height_cutoff 0.1 -step 50 -odir percentiles_grain_50 -o pb.bil -cores 4
