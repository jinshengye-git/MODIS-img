#!/bin/bash

#prepare MRT environment
MRT_HOME=$HOME/MRT
PATH=$PATH:$MRT_HOME/bin
MRT_DATA_DIR=$MRT_HOME/data
export MRT_HOME PATH MRT_DATA_DIR

#prepare filelist.txt
touch filelist.txt
for i in *.hdf;do #
	echo $i>>filelist.txt
done

#mosaic Japan tiles.....
outputTmp=JapTmp.hdf
mrtmosaic -i filelist.txt -s "0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 0 0" -o $outputTmp>tmp.txt

#get line index of corners
line_num=`awk '/output image corners \(lat\/lon\)/{print NR;exit}' tmp.txt`
line_1=$((line_num+1))
line_2=$((line_num+4))

ULcood=`sed -n "${line_1}p" tmp.txt`
LRcood=`sed -n "${line_2}p" tmp.txt`

#only keep the numbers
ULcood=${ULcood:9} 
LRcood=${LRcood:9}

#prepare the prm file
touch japan.prm
prmfile=japan.prm

outputTif=Japan.tif
resolution=2000

echo "INPUT_FILENAME = $outputTmp">>$prmfile
echo "SPECTRAL_SUBSET = ( 1 1 1 1 1 1 1 )">>$prmfile
echo "SPATIAL_SUBSET_TYPE = INPUT_LAT_LONG">>$prmfile
echo "SPATIAL_SUBSET_UL_CORNER = ( $ULcood )">>$prmfile
echo "SPATIAL_SUBSET_LR_CORNER = ( $LRcood )">>$prmfile
echo "OUTPUT_FILENAME = $outputTif">>$prmfile
echo "RESAMPLING_TYPE = NEAREST_NEIGHBOR">>$prmfile
echo "OUTPUT_PROJECTION_TYPE = UTM">>$prmfile
echo "OUTPUT_PROJECTION_PARAMETERS = ( 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 )">>$prmfile
echo "DATUM = WGS84">>$prmfile
echo "UTM_ZONE = 0">>$prmfile
echo "OUTPUT_PIXEL_SIZE = $resolution">>$prmfile

#resample
resample -i $outputTmp -p $prmfile

rm $prmfile $outputTmp filelist.txt tmp.txt
