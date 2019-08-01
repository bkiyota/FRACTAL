#!/bin/bash
#$ -S /bin/bash

CMDNAME="FRACTAL.sh"
#setting defalt parameter

MAX_ITERATION=5             #Integer
SUBSAMPLE_SIZE=100          #Integer
INFILE="unspecified"       #Absolute Path of .fa file
NAME="FRACTALout"           #Experiment No.
CODE_DIR=`which FRACTAL.sh | sed -e "s/\/FRACTAL.sh//"` #Absolute path of FRACTAL-X.X.X directory
OUT_DIR="`pwd`"             #output dir should be ${OUT_DIR}/${NAME}
THRESHOLD=500
ROOTING="Origin"
NUM_OF_JOBS=1
TREE=raxmlMP
THREADNUM=1
COLOR="FALSE"
REMOVE_INTERMEDIATES=TRUE
OPTION=""
SEED=0
MODEL="GTRCAT"
MEM_REQ=16
INIT_MEM_REQ=16
ENVIRONMENT="unspecified"

function version {
  echo "######## FRACTAL v1.0.0 ########"
}

function usage {
    cat <<EOF
$(basename ${0}) is a tool for lineage estimation from massive number of DNA sequences.

Usage:
    FRACTAL.sh
    [-v] [-h]
    [-i input_file] [-d output_file_path] [-o output_file_name]
    [-m method] [-p "options"] [-s sequence_number] [-b model_name]
    [-x iteration_number] [-l sequence_number]
    [-q job_number] [-t thread_number] [-e]
    [-r integer] [-M memory_size] [-I memory_size]

Options:
    -v
      Print FRACTAL version; ignore all the other parameters
    -h
      Print the usage of FRACTAL; ignore all the other parameters
    -i <String>
      Input FASTA file
    -d <String>
      Output directory path. Default: current working directory
    -o <String>
      Output file name. Default: FRACTAL_output
    -m <String, Permissible values: ‘raxmlMP’, ‘rapidnjNJ’ and ‘fasttreeML’>               
      Software to reconstruct lineage tree in each iteration cycle. Default: raxmlMP
    -p <”String”>
      Options for the software to reconstruct lineage tree in each iteration cycle.
    -s <Integer>
      Number of sequences for the subsampling procedure. Default: 100
    -b <String>
      Evolution model of RAxML for phylogenetic placement. Default: GTRCAT
    -x <Integer>
      Threshold for the maximum number of trials in the subsampling process
    -t <Integer>
      Threshold number of input sequences to switch to direct lineage tree reconstruction in
        each iteration cycle. Default: 500
    -q <Integer>
      Execute the distributed computing mode and set the number of jobs required.
        Default: 1
    -c <Integer>
      Number of threads required for subsample tree construction and phylogenetic placement
        in each iteration cycle. Default: 1
    -e
      Inactivate the deletion of intermediate files
    -r <Integer>
      Seed to generate random values. Default: 0
    -M <String>
      Memory requirement per distributed computing node. Default: 16GB
    -I <String>
      Memory requirement for the initial calculation node in the distributed computing mode.
        Default: 16GB
EOF
}

# read argument
while getopts i:d:o:m:p:s:b:x:t:q:c:r:M:I:k:vhe OPT
do
  case $OPT in
    "v" ) version; exit 1;;
    "h" ) version; usage; exit 1;;
    "i" ) FLG_i="TRUE" ; INFILE="$OPTARG";;
    "d" ) FLG_D="TRUE" ; OUT_DIR="$OPTARG";;
    "o" ) FLG_O="TRUE" ; NAME="$OPTARG";;
    "m" ) FLG_m="TRUE" ; TREE="$OPTARG";;
    "p" ) FLG_P="TRUE" ; OPTION="$OPTARG";;
    "s" ) FLG_S="TRUE" ; SUBSAMPLE_SIZE="$OPTARG";;
    "b" ) FLG_B="TRUE" ; MODEL="$OPTARG";;
    "x" ) FLG_X="TRUE" ; MAX_ITERATION="$OPTARG";;
    "t" ) FLG_T="TRUE" ; THRESHOLD="$OPTARG";;
    "q" ) FLG_Q="TRUE" ; NUM_OF_JOBS="$OPTARG";;
    "c" ) FLG_C="TRUE" ; THREADNUM="$OPTARG";;
    "e" ) REMOVE_INTERMEDIATES="FALSE" ;;
    "r" ) FLG_R="TRUE" ; SEED="$OPTARG";;
    "M" ) FLG_M="TRUE" ; MEM_REQ="$OPTARG";;
    "I" ) FLG_I="TRUE" ; INIT_MEM_REQ="$OPTARG";;
    "k" ) FLG_K="TRUE" ; ENVIRONMENT="$OPTARG";;
    * ) usage; exit 1;;
  esac
done

# checking existance of directories
if [ ! -e ${INFILE} ]; then
  INFILE=`pwd`/${INFILE}
fi
if [ ! -e ${INFILE} ]; then
  echo "${INFILE} was not found" 1>&2
  exit 1
fi
echo "input fasta file ... OK"
if [ ! -e ${OUT_DIR} ]; then
  echo "${OUT_DIR} was not found" 1>&2
  exit 1
fi
echo "output directory file ... OK"
if [ ! -e ${CODE_DIR} ]; then
  echo "${CODE_DIR} was not found" 1>&2
  exit 1
fi
echo "code directory file ... OK"

# setting tree construction software
# ML (RAxML)
if [ "${TREE}" = "raxmlML" ]; then
  SOFTWARE=`which raxmlHPC-SSE3`
# NJ
elif [ "${TREE}" = "rapidnjNJ" ]; then
  SOFTWARE=`which rapidnj`
# MP
elif [ "${TREE}" = "raxmlMP" ]; then
  SOFTWARE=`which raxmlHPC-SSE3`
# ML (fasttree)
elif [ "${TREE}" = "fasttreeML" ]; then
  SOFTWARE=`which FastTreeMP`
else
  echo "exception: Tree construction method name seems wrong..."
fi

#record setting
echo '###############################################################################'
echo 'FRACTAL was launched with following parameters:'
echo "Max Iteration : ${MAX_ITERATION} [times]"
echo "Subsample Size: ${SUBSAMPLE_SIZE} [cells]"
echo "Threshold Size: ${THRESHOLD} [cells]"
echo "Rooting Mode: ${ROOTING}"
echo "Tree Method: ${TREE}"
echo "Code directory path: ${CODE_DIR}"
echo "Input file path: ${INFILE}"
echo "Output directory path: ${OUT_DIR}/${NAME}"
echo "Model of RAxML: ${MODEL}"
echo "Number of threads per node: ${THREADNUM}"
echo "Number of Computers: ${NUM_OF_JOBS} [nodes]"
echo "Memory requirement in qsub: ${MEM_REQ} [GB]" 
echo "random number seed: ${SEED}" 
echo '###############################################################################' 

bash ${CODE_DIR}/shell/SUPERVISE.sh ${MAX_ITERATION} ${SUBSAMPLE_SIZE} ${INFILE} ${NAME} ${CODE_DIR} ${OUT_DIR} ${THRESHOLD} ${ROOTING} ${NUM_OF_JOBS} ${TREE} ${THREADNUM} ${SOFTWARE} "${OPTION}" ${MODEL} ${MEM_REQ} ${INIT_MEM_REQ} "${SEED}" ${ENVIRONMENT}
wait

echo '###############################################################################' > ${OUT_DIR}/${NAME}/setting.o
echo 'FRACTAL was launched with following parameters:'>> ${OUT_DIR}/${NAME}/setting.o
echo "Max Iteration : ${MAX_ITERATION} [times]">> ${OUT_DIR}/${NAME}/setting.o
echo "Subsample Size: ${SUBSAMPLE_SIZE} [cells]">> ${OUT_DIR}/${NAME}/setting.o
echo "Threshold Size: ${THRESHOLD} [cells]">> ${OUT_DIR}/${NAME}/setting.o
echo "Rooting Mode: ${ROOTING}">> ${OUT_DIR}/${NAME}/setting.o
echo "Tree Method: ${TREE}">> ${OUT_DIR}/${NAME}/setting.o
echo "Code directory path: ${CODE_DIR}">> ${OUT_DIR}/${NAME}/setting.o
echo "Input file path: ${INFILE}">> ${OUT_DIR}/${NAME}/setting.o
echo "Output directory path: ${OUT_DIR}/${NAME}">> ${OUT_DIR}/${NAME}/setting.o
echo "Model of RAxML: ${MODEL}">> ${OUT_DIR}/${NAME}/setting.o
echo "Number of threads per node: ${THREADNUM}">> ${OUT_DIR}/${NAME}/setting.o
echo "Number of Computers: ${NUM_OF_JOBS} [nodes]">> ${OUT_DIR}/${NAME}/setting.o
echo "Memory requirement in qsub: ${MEM_REQ} [GB]" >> ${OUT_DIR}/${NAME}/setting.o
echo "random number seed: ${SEED}" >> ${OUT_DIR}/${NAME}/setting.o
echo '###############################################################################' >> ${OUT_DIR}/${NAME}/setting.o

#show result
echo "##############################################################"
echo "Lineage Construction Finished ~!"
cp ${OUT_DIR}/${NAME}/final_tree/HUGE_Result.nwk ${OUT_DIR}/${NAME}.nwk
if [ ${REMOVE_INTERMEDIATES} = "TRUE" ]; then
  rm -r $OUT_DIR/$NAME
else
  echo "input parameter file path: ${OUT_DIR}/${NAME}/setting.o"
  echo "output .nwk path: ${OUT_DIR}/${NAME}/final_tree/HUGE_Result.nwk"
fi
echo "##############################################################"

