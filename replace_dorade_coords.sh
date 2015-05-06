#!/bin/bash

# Script for processing a coordinate replacement in sweep files
# and creating cfrad text files for later navigation correction.
#
# Raul Valenzuela
# April, 2015

# I/O directories
#---------------------------
# INDIR="$HOME/P3/dorade/case04"
# # OUTDIR="$HOME/P3/dorade/case04_coords_cor2"
# OUTDIR="$HOME/P3/dorade/dummy"

# INDIR="$HOME/P3/dorade/case03/leg01"
# OUTDIR="$HOME/P3/dorade/case03_coords_cor"

# INDIR="$HOME/P3/dorade/case03/leg02"
# OUTDIR="$HOME/P3/dorade/case03_coords_cor/leg02"

INDIR="$HOME/P3/dorade/case03_all/leg03"
OUTDIR="$HOME/P3/dorade/case03_coords_cor/leg03_new"

# standard tape file
#---------------------------
# STDTAPE="$HOME/Github/correct_coords/010125I.nc"
STDTAPE="$HOME/Github/correct_coords/010123I.nc"

# python function
#---------------------------
PYFUN="$HOME/Github/correct_coords/replace_cfradial_coords.py"

# cfradial to text converter script (needed for later nav correction)
#-------------------------------------
CF2TXT="$HOME/Github/navigation/netcdf2text"

# Processing
#---------------------------
if [ ! -d "$OUTDIR/cfrad" ]; then
	echo
else	
	echo
	echo " The output directory: $OUTDIR/cfrad"
	echo " already exists and might contain processed files. "
	echo " If you continue existing files will be deleted."
	echo
	read -r -p " Do you want to continue? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo " Deleting existing output files/folders"
		echo
		cd $OUTDIR
		rm -rf cfrad
		rm swp*
	else
		echo " Stopping script"
		echo
		exit 
	fi	
fi

echo " Changing to input directory: $INDIR"
echo
cd $INDIR
echo " Running RadxConvert"
RadxConvert -f swp* -cfradial -outdir .
RDXOUT="$(ls -d 2*/)"
echo
echo " Changing to RadxConvert directory: $RDXOUT'"
echo
cd $RDXOUT
echo " Running replace_cfradial_coords.py"
echo
python $PYFUN $STDTAPE
echo 
echo " Coordinates replaced"
echo
echo " Cleaning and moving files to $OUTDIR"
mkdir $OUTDIR/cfrad 
mv cfrad.* $OUTDIR/cfrad 
cd $INDIR
rm -rf $RDXOUT
cd $OUTDIR/cfrad
RadxConvert -f cfrad* -dorade -outdir $OUTDIR
cd $OUTDIR
cd $RDXOUT
mv swp* $OUTDIR
cd $OUTDIR
rm -rf $RDXOUT
echo
echo " Running netcdf2text in $OUTDIR/cfrad"
echo
cd $OUTDIR/cfrad 
cp $CF2TXT .
./netcdf2text DZ VG
rm netcdf2text
echo
echo " Done"
echo



