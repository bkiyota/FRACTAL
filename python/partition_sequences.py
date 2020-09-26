from Bio import Phylo
from io import StringIO
import sys
import os
import json
import jplace_parse
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import subprocess
import random
import gzip

def classify_sequences(inputFASTA_filehandle, seqname2dirpath, dirpath2filepath, filepath2handle):
    # open input FASTAfile
    outfilepath2Nseq = {}
    records = SeqIO.parse(inputFASTA_filehandle, "fasta")
    
    for record in records:
        if (record.name == "root"):
            None
        else:
            outfilepath = dirpath2filepath[seqname2dirpath[record.id]]
            try:    outfilepath2Nseq[outfilepath] += 1
            except: outfilepath2Nseq[outfilepath] = 1

            outhandle   = filepath2handle[outfilepath]
            SeqIO.write(record, outhandle, "fasta")
    
    for outfilepath in outfilepath2Nseq.keys():
        with open(outfilepath + ".count", 'w') as numhandle:
            print(outfilepath, outfilepath2Nseq[outfilepath], '\t', file = numhandle)

def partition_sequences(inputFASTA_filepathlist, outputFASTA_dirpathlist, seqname2dir_filepath):

    seqname_set = set()
    for inputFASTA_filepath in inputFASTA_filepathlist:
        is_gzipped = (inputFASTA_filepath.split(".")[-1] == "gz")
        if is_gzipped:
            ist  = gzip.open(inputFASTA_filepath, 'rt')
        else:
            ist  = open(inputFASTA_filepath, 'r')
        records = SeqIO.parse(ist, "fasta")
        for record in records:
            seqname_set.add(record.name)
        ist.close()
    seqname2dirpath = {}
    with open(seqname2dir_filepath, 'r') as dicst:
        for line in dicst:
            line     = line.split("\n")[0]
            seqname  = line.split("\t")[0]
            dirpath  = line.split("\t")[1]
            if seqname in seqname_set:
                seqname2dirpath[seqname] = dirpath

    for inputFASTA_filepath in inputFASTA_filepathlist:
        is_gzipped = (inputFASTA_filepath.split(".")[-1] == "gz")
        if is_gzipped:
            ist  = gzip.open(inputFASTA_filepath, 'rt')
        else:
            ist  = open(inputFASTA_filepath, 'r')
        filepath2handle = {}
        dirpath2filepath = {}
        for outputFASTA_dirpath in outputFASTA_dirpathlist:
            outputFASTA_filepath = outputFASTA_dirpath + "/" + inputFASTA_filepath.split("/")[-1].split(".gz")[0]
            filepath2handle[outputFASTA_filepath] = open(outputFASTA_filepath, 'w')
            dirpath2filepath[outputFASTA_dirpath] = outputFASTA_filepath

        classify_sequences(ist, seqname2dirpath, dirpath2filepath, filepath2handle)

        ist.close()
        for outputFASTA_dirpath in outputFASTA_dirpathlist:
            outputFASTA_filepath = outputFASTA_dirpath + "/" + inputFASTA_filepath.split("/")[-1].split(".gz")[0]
            filepath2handle[outputFASTA_filepath].close()
        if (is_gzipped):    
            for outputFASTA_dirpath in outputFASTA_dirpathlist:
                outputFASTA_filepath = outputFASTA_dirpath + "/" + inputFASTA_filepath.split("/")[-1].split(".gz")[0]
                subprocess.call(
                    "gzip " + outputFASTA_filepath,
                    shell=True
                )
        os.remove(inputFASTA_filepath)

if __name__ == "__main__":
    partition_sequences(
        inputFASTA_filepathlist = sys.argv[1].split(":"), 
        outputFASTA_dirpathlist = sys.argv[2].split(":"), 
        seqname2dir_filepath    = sys.argv[3]
        )