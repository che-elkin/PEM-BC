echo ############################# CHM50cm Test file
echo ############################# Alivia Cavallin March 21, 2018
echo ############################# This file will test the other structure


echo change directory
cd F:\FLNR_PEM\Smithers_PEM\

REM echo make directory for test and go into it
REM mkdir CHM50_test
REM cd F:\FLNR_PEM\Smithers_PEM\CHM50_test

echo ############################# make directories for test folder
mkdir tiles_raw
mkdir tiles_optimized
mkdir tiles_ground_classified_500
mkdir tiles_noBuffer
mkdir tiles_nHeight
mkdir tiles_nHeight_sml
mkdir Processed
mkdir pittfree_rastertiles
echo #############################

echo ############################# set LAStools to path
set PATH=%PATH%;C:\LAStools\bin\;C:\OSGeo4W64\bin
echo #############################

REM @echo ############################  Tile data %Time%
lastile -i data\*.las -tile_size 500 -buffer 50 -odir tiles_raw -o tiles.las -cores 8
	REM REM Use above if buffering hasn't been done already
REM @echo ############################  Tiles Generated %Time%


echo ############################  Optimize tiles %Time%
lasoptimize -i tiles_raw\*.las -odir tiles_optimized -olas -cores 4
echo ############################  Tiles optimized %Time%


echo ############################  Classify ground %Time%
lasground -i tiles_optimized\*.las  -odir tiles_ground_classified_500 -olas -cores 4
echo ############################  Ground classified %Time%


echo ############################# Height Normalized LAS Start: %Time%
lasheight -i tiles_ground_classified_500\*.las -replace_z -odir tiles_nHeight -olas -cores 4
echo ############################# nHeights Done: %Time%


echo ############################# Create p99 Raster 10m and 5m: %Time%
REM Stand Height Models 10m and 5m 
lascanopy -i tiles_nHeight\*.las -merged -height_cutoff 0.2 -step 10 -p 99 -o Processed\10m.bil 
lascanopy -i tiles_nHeight\*.las -merged -height_cutoff 0.2 -step 5 -p 99 -o Processed\05m.bil 
lascanopy -i tiles_nHeight\*.las -merged -height_cutoff 0.2 -step 25 -p 99 -o Processed\25m.bil 
echo ############################# p99 Done: %Time%


echo ############################# Spike Free CHM 50cm %Time%
lastile -i tiles_nHeight\*.las -tile_size 500 -buffer 25 -odir tiles_nHeight_sml -o nH.las -cores 4
las2dem -i tiles_nHeight_sml\*.las -step 0.5 -use_tile_bb -spike_free 0.9 -odir pittfree_rastertiles -obil -cores 4
blast2dem -i pittfree_rastertiles\*.bil -merged -odir Processed -o ITDraster.tif
echo ############################# CHM Done: %Time%

pause