@echo off 
REM ###################################################
REM Pipeline for processing forest data
REM DTM creation from unclassified las data
REM Adapted from Che Elkin, UNBC, Dec. 20, 2017
REM Based on Martin Isenburg's suggested workflow (2013 with 2017 update)
REM Modifications by Colin Chisholm on Jan 7-8, 2018
REM #################################################
REM Process:
    REM 1. start with raw data in a folder named data 
    REM 2. Save this script 1 directory above 'data'  e.g. ..\PutScriptHERE\data
    REM 3. Run this Script from command line the following will occur
        REM a. output directory structure will be generated 
        REM b. data will be tiled for easier processing >>      tiles_raw
        REM c. ground will be classified >>                     tiles_ground
        REM d. spikes will be removed from the data >>          tiles_height
        REM e. Above Ground Classification >>                   tiles_classified
        REM f. Buffers Removed >>                               tiles_final 
        REM g. Height Normalized LAS                            tiles_nHeight
        REM h. DTM, DSM, & CHM generated                        DEMs
REM Assumes that the batch file will be run from within the working directory
REM Assumes that the raw data is stored in 'data'


REM #################################################
REM Directory creation
REM #################################################
REM mkdir tiles_raw
REM mkdir tiles_optimized 
REM mkdir tiles_ground
REM mkdir tiles_groundNoBuffer
REM mkdir DTM_merged
REM REM mkdir tiles_groundOnly
REM REM mkdir LAS_GroundMerged
REM REM @echo ############################  Directories Made %Time%
REM REM REM lastools directory
set PATH=%PATH%;C:\LAStools\bin


REM #################################################
REM	LAS processing: only DTM creation  
REM #################################################

@echo ############################  Tile data %Time%
REM lastile -i data\*.las -tile_size 1000 -odir tiles_raw -o tiles.las -cores 4
	REM Use above if buffering has already been done 
lastile -i data\*.las -tile_size 1000 -buffer 50 -odir tiles_raw -o tiles.las
	REM Use above if buffering hasn't been done already
@echo ############################  Tiles Generated %Time%


@echo ############################  Optimize tiles %Time%
lasoptimize -i tiles_raw\*.las -odir tiles_optimized -olas -cores 4
@echo ############################  Tiles optimized %Time%


@echo ############################  Classify ground %Time%
lasground -i tiles_optimized\*.las -odir tiles_ground -olas -cores 4
@echo ############################  Ground classified %Time%


@echo ############################# Remove the buffer and keep ground only. Start: %Time%
lastile -i tiles_ground\*.las -remove_buffer -keep_class 2 -odir tiles_groundNoBuffer -olas -cores 4
@echo ############################# Remove the buffer and keep ground only. Done: %Time%


@echo ############################  Generate DTM %Time%
blast2dem -i tiles_groundNoBuffer\*.las -odir DTM_merged -o DTM.tif -merged  -thin_with_grid .5 -step 1 
@echo ############################ DTM generated %Time%

pause




















rem lastile -i tiles_groundNoBuffer\*.las -odir tiles_ThinnedGroundOnly -olas -thin_with_grid .5 -keep_class 2 
REM @echo Starting lastile to generate ground only cloud
REM lastile -i tiles_groundNoBuffer\*.las -odir tiles_groundOnly -olas -keep_class 2 
REM @echo starting thinning of pointcloud
REM lasthin -i tiles_groundOnly\*.las -step 0.5 -odir LAS_GroundMerged -olas

REM @echo ############################ Tiles Thinned and Ground Only %Time%
REM @echo Building DTM %Time%
REM blast2dem -i LAS_GroundMerged\*.las -odir DTM_merged -o DTM.tif -merged  -step 1 
REM @echo ############################  DTM Generated %Time%
REM pause



REM REM ############################################
REM REM full process below
REM REM ############################################

REM rem #####################################################
REM rem Tile the data for easier processing 
REM rem Use line below if buffers are needed 
REM lastile -i data\*.las -tile_size 1000 -buffer 50 -odir tiles_raw -o tiles.las 
REM rem Currently using blast2dem ... as such no buffers 
REM rem lastile -i data\*.las -tile_size 1000 -odir tiles_raw -o tiles.las
REM rem alternately with buffers 
REM rem lastile -i data\*.las -tile_size 1000 -odir tiles_raw -o tiles.las -buffer 50
REM @echo ###################################################
REM @echo Tiles Generated %Time%
REM @echo ###################################################

REM rem Note do not use -keep_class 2 flag here ... we need all points to start with so they can be classified.
REM lasground -i tiles_raw\*.las -odir tiles_ground -olas 
REM @echo ###################################################
REM @echo Ground classified %Time%
REM @echo ###################################################

REM rem #####################################################
REM rem Remove any unusual spike <2 & >45m
REM lasheight -i tiles_ground\*.las -drop_below -2 -drop_above 45 -odir tiles_height -olas 
REM @echo ###################################################
REM @echo Spikes Removed %Time%
REM @echo ###################################################

REM rem #####################################################
REM rem classify additional structures (e.g. buildings)
REM lasclassify -i tiles_height\*.las -step 3 -odir tiles_classified -olas 
REM @echo ###################################################
REM @echo Above ground classification complete %Time%
REM @echo ###################################################

REM rem #####################################################
REM rem remove buffers for processing with blast2dem
REM lastile -i tiles_classified\*.las -remove_buffer -odir tiles_final -olas
REM rem -set_user_data 0 // what does this flag do ... do we need it.
REM @echo ###################################################
REM @echo Buffers removed %Time%
REM @echo ###################################################

REM rem #####################################################
REM rem generate height normalized las eg. replace z 
REM rem note that these tiles will not be buffered
REM lasheight -i tiles_final\*.las -odir tiles_nHeight -olas -replace_z
REM @echo ###################################################
REM @echo Height normalized tiles created %Time%
REM @echo ###################################################

REM rem ########################################################
REM rem OPTION 2 blast2dem 
REM rem very efficient - straight to a consolidated dtm.  However, this is an additional license. 
REM rem this step requires removal of buffers prior to processing 
REM rem Remove Buffers from tiles 
REM rem Went straight to buffers above ... no need to recreate them here 
REM rem ## 
REM rem may need next line if buffers have not been removed 
REM rem lastile -i tiles_ground\*.las -remove_buffer -odir tiles_NoBuffer -olas
REM rem @echo bufferless tiles generated
REM blast2dem -i tiles_final\*.las -odir DEMs -o DTM.tif -merged -step 1 -keep_class 2
REM @echo ###################################################
REM @echo DTM generated %Time%
REM @echo ###################################################

REM rem DSM Surface Model
REM blast2dem -i tiles_final\*.las -odir DEMs -o DSM.tif -merged -step 1
REM @echo ###################################################
REM @echo DSM generated %Time%
REM @echo ###################################################

REM rem CHM Crown Height Model
REM blast2dem -i tiles_nHeight\*.las -odir DEMs -o CHM.tif -merged -step 1
REM @echo ###################################################
REM @echo CHM generated %Time%
REM @echo ###################################################
REM @echo 
REM @echo PROCESSING COMPLETE 


