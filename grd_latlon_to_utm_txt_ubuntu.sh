#!/bin/bash

# Default values
save_to_obj=false
verbose="quiet"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--file) file_name="$2"; shift ;;
        -e|--env) path_pyt_312="$2"; shift ;;
        -s|--save-obj) save_to_obj=true ;;
        -v|--verbose) verbose="verbose" ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

file_no_ext="${file_name%.*}"

echo
echo
echo "Path: $file_no_ext"
echo "Virtualenv: $path_pyt_312"
echo "Save to OBJ: $save_to_obj"
echo "Verbosity: $verbose"

echo
echo
echo "STARTING PROCESS"
echo
echo

echo "Checking/Installing necessary GMT packages (if needed)..."
if ! command -v gmt &> /dev/null; then
    echo "GMT not found. Installing..."
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y gmt gmt-dcw gmt-gshhg > /dev/null 2>&1
else
    echo "GMT is already installed."
fi

echo "Projecting the grid data using the WGS84 model, zone 10..."
if [[ "$verbose" == "verbose" ]]; then
	gmt grdproject "${file_no_ext}.grd" -J"+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs" -G"${file_no_ext}_UTM.grd" -V
else
	gmt grdproject "${file_no_ext}.grd" -J"+proj=utm +zone=10 +datum=WGS84 +units=m +no_defs" -G"${file_no_ext}_UTM.grd" -Vq
fi

echo "Converting lat-lon to north-south..."
if [[ "$verbose" == "verbose" ]]; then
	gmt grd2xyz "${file_no_ext}_UTM.grd" -V > "${file_no_ext}_UTM.txt";
else
	gmt grd2xyz "${file_no_ext}_UTM.grd" -Vq > "${file_no_ext}_UTM.txt";
fi

echo "Activating the virtual environment with Python 3.12..."
source "${path_pyt_312}/bin/activate"

echo "Installing necessary Python packages (if needed)..."
pip install numpy scipy matplotlib trimesh open3d > /dev/null 2>&1

echo "Cleaning and plotting data for verification..."
if [[ "$verbose" == "verbose" ]]; then
	python3 clean_and_plot.py "${file_no_ext}_UTM.txt" "$save_to_obj"
else
	python3 clean_and_plot.py "${file_no_ext}_UTM.txt" "$save_to_obj" > /dev/null 2>&1
fi

echo "Deactivating the virtual environment..."
deactivate

echo
echo "Close the image to terminate the process"
echo
echo
echo "TERMINATING PROCESS"
echo   
echo