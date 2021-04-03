<h2>FRACTAL Installation and User Manual</h2>

- [Overview of FRACTAL](#overview-of-fractal)
- [Supported Environment](#supported-environment)
- [Software Dependency](#software-dependency)
- [Software installation](#software-installation)
- [Sample Codes](#sample-codes)
- [FRACTAL Usage](#fractal-usage)

### Overview of FRACTAL

**FRACTAL** (framework for distributed computing to trace large accurate lineages) is a new deep distributed computing framework that is designated to reconstruct extremely large lineages of nucleotide sequences using a software tool of choice. In brief, FRACTAL first subsamples a small number of sequences to reconstruct only an upper hierarchy of a target lineage and assigns the remaining sequences to its downstream clades, for each of which the same procedure is recursively iterated. Since the iteration procedure can be performed in parallel in a distributed computing framework, FRACTAL allows highly scalable reconstruction of an extremely large lineage tree.

<img src=images/fractal_concept.jpg width=10000x3000>

**Figure 1. Schematic diagram of FRACTAL.** From an input sequence pool, a given number of sequences are first randomly subsampled (Step 1) and their sample lineage tree is reconstructed with a rooting or provisional rooting sequence by lineage estimation software of choice (Step 2). Note that while an outgroup is preferred as the rooting sequence if available, any sequence can be used for unrooted tree estimation. The all the input sequences are then mapped to the branches of the sample tree by phylogenetic placement (Step 3). If all of the input sequences are mapped on downstream branches of the sample tree so as to separate them into multiple distinct clades, their upstream lineage is considered to be true and fixed (Step 4), and the sequence group in each downstream clade is recursively subjected to the first process in a distributed computing node (Step 5). If any sequence(s) mapped on the root branch does not allow the grouping of input sequences into clades, the phylogenetic placement is repeated against a new sample tree generated for sequences randomly chosen from a union of the previous subsampled sequences and the “problematic” sequences (Step 6). This process generates a new sample tree in a biased manner such that it harbors the previous problematic sequences in its leaves and decreases the likelihood of acquiring problematic sequences in the following phylogenetic placement step. This procedure is repeated until the problem is solved, but only up to a given threshold number of times as long as the number of problematic sequences continues to be reduced in every retrial step. When the retrial cycle stops without solving the problem, the remaining problematic sequences are discarded, and the other sequence sets are separated into distinct clades and subjected to the first process. Accordingly, FRACTAL hierarchically generates expanding parallel computing trajectories, where each distributed computing job recursively generates a large set of successive jobs. When the number of input sequences is reduced to a certain threshold (hereafter called the naïve computing threshold) while the FRACTAL iteration cycles, the remaining marginal lineage is directly reconstructed by using the software of choice and the operation terminates for this computing trajectory (Step 7). Accordingly, FRACTAL enables efficient reconstruction of a large lineage by distributed computing while utilizing limited computing power and memory per node. FRACTAL is also effective even for a single computing node because its memory consumption level can be kept down for large lineage reconstructions.

<img src=images/fractal_unaligned.jpg width=10000x3000>

**Figure 2. Workflow for unaligned datasets.** When FRACAL receives unaligned DNA sequence pool, FRACTAL can divide and distribute the alignment task with some additional procedures. After random subsampling (Step 1), the subsampled sequences are aligned by MAFFT (Step 2) and a sample tree is estimated from the aligned sequences (Step3). Each input sequence is then mapped onto the sample tree (Step 4). In step 4, each sequence is firstly aligned with the subsampled sequences by HMMER ("hmmalign" command) based on a HMM profile constructed from the aligned subsampled sequences by "hmmbuild" command (Step 4i). Then, the sequence is placed onto eather branch of the sample tree by phylogenetic placement (Step 4ii). Once all input sequences are aligned by Step 4i, the alignment result will be reused in the following FRACTAL iteration cycles until the the number of input sequences is reduced to X% of the number of sequences when the alignment was conducted (X is a user-defined parameter).

### Supported Environment

1. FRACTAL can be executed on Linux OS
2. The distributed computing mode of FRACTAL requires UGE (Univa Grid Engine)

### Software Dependency

1. Python3 (version: 3.7.0 or later) with Biopython (version: 1.76) module *required*
2. RAxML (raxmlHPC-PTHREADS-SSE3 and raxmlHPC-SSE3) (version: 8.2.12) *required*
3. EPA-ng (version: 0.3.5) *required*
4. Seqkit (version: 0.11.0) *required*
5. Trimal (version: 1.4.1) *required*
6. RapidNJ (version: 2.3.2) *optional; if you want to use NJ for lineage reconstruction*
7. FastTreeMP (version: 2.1.10) *optional; if you want to use ML for lineage reconstruction*
8. MAFFT (version: 7.464) *optional; if you want to reconstruct a lineage from unaligned sequences*
9. HMMER (version: 3.3) *optional; if you want to reconstruct a lineage from unaligned sequences*


### Software installation

Each installation step will take less than ~1 min


#### Installation of FRACTAL


1. Download FRACTAL by

   ```shell
    git clone https://github.com/yachielab/FRACTAL.git
   ```

   or you can also obtain FRACTAL as follows

   ```shell
    wget https://github.com/yachielab/FRACTAL/archive/master.zip
    unzip master.zip
   ```

2. Add the absolute path of `FRACTAL` directory to `$PATH`

3. Make `FRACTAL` executable

   ```shell
   chmod u+x FRACTAL
   ```

#### Installation of [Anaconda](https://www.anaconda.com/distribution/) (required)

1. Execute the following commands

    ```shell
    wget https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
    bash Anaconda3-2018.12-Linux-x86_64.sh
    bash
    ```

2. Please set `$PATH` to `anaconda3/bin`.

#### Installation of [Biopython](https://anaconda.org/anaconda/biopython) (required)

1. Install Biopython by

   ```shell
   conda install biopython
   ```

#### Installation of [RAxML](https://github.com/stamatak/standard-RAxML) (required)

1. Execute the following commands

   ```shell
   wget https://github.com/stamatak/standard-RAxML/archive/master.zip
   unzip master.zip
   cd standard-RAxML-master
   make -f Makefile.SSE3.gcc
   rm *.o
   make -f Makefile.SSE3.PTHREADS.gcc
   rm *.o
   ```

2. Set `$PATH` to `raxmlHPC-SSE3` & `raxmlHPC-PTHREADS-SSE3` executable.

#### Installation of [EPA-ng](https://github.com/Pbdas/epa-ng) (required)

1. Install EPA-ng by

   ```shell
   conda install -c bioconda epa-ng
   ```

#### Installation of [Seqkit](https://bioinf.shenwei.me/seqkit/) (required)

1. Install Seqkit by

   ```shell
   conda install -c bioconda seqkit
   ```

#### Installation of [RapidNJ](http://birc.au.dk/software/rapidnj/) (optional)

1. Install RapidNJ

   ```
   conda install -c bioconda rapidnj
   ```

#### Installation of [FastTreeMP](http://www.microbesonline.org/fasttree/) (optional)

1. Execute the following commands

   ```shell
   wget http://www.microbesonline.org/fasttree/FastTreeMP
   chmod u+x FastTreeMP
   ```

2. Please set `$PATH` to `FastTreeMP` executable.

#### Installation of [MAFFT](https://mafft.cbrc.jp/alignment/software/) (optional)

1. Install MAFFT

   ```shell
   conda install -c bioconda mafft
   ```

#### Installation of [HMMER](http://hmmer.org/) (optional)

1. Install HMMER

   ```shell
   conda install -c bioconda hmmer
   ```

#### Installation of [trimAl](http://trimal.cgenomics.org/) (optional)

1. Install trimAl

   ```shell
   conda install -c bioconda trimal
   ```

### Sample Codes

The FRACTAL package contains an example input file in the `examples` directory so users can check the software functions as follows:

**Example 1**

Lineage estimation of the sequences in the test input file `test.fa` with the default parameter set without distributed computing. The computation will take several minutes.

```shell
FRACTAL -i test.fa
```


Input:

​	 [`test.fa`](https://github.com/yachielab/FRACTAL/blob/master/example/test.fa)  (FASTA format)

Output:

​	 [`FRACTALout.nwk`](https://github.com/yachielab/FRACTAL/blob/master/example/output/FRACTALout.nwk) (Newick format) will be created in your current working directory

**Example 2**

Lineage estimation by sample tree estimation using RapidNJ with distributed computing where the maximum number of computing nodes is set to 100. The output file name is set to `FRACTAL_NJ`. The computation will take several minutes.

```shell
FRACTAL -i test.fa -f FRACTAL_NJ -m rapidnjNJ -d 100
```

Input:

​	 [`test.fa`](https://github.com/yachielab/FRACTAL/blob/master/example/test.fa) (FASTA format)

Output:

​	 [`FRACTAL_NJ.nwk`](https://github.com/yachielab/FRACTAL/blob/master/example/output/FRACTAL_NJ.nwk) (Newick format) for intermediate files will be created in your working directory.

**Example 3**

Lineage estimation by sample tree estimation using FastTreeMP with its option `-fastest` without distributed computing. The number of threads required for the phylogenetic placement and the sample tree reconstruction procedures is set to be 16. The output file name is set to `FRACTAL_ML`.  The computation will take ~5 min.

```shell
FRACTAL -i test.fa -f FRACTAL_ML -m fasttreeML -a "-fastest" -c 16
```

Input:    

​	 [`test.fa`](https://github.com/yachielab/FRACTAL/blob/master/example/test.fa) (FASTA format)

Output:  

​	 [`FRACTAL_ML.nwk`](https://github.com/yachielab/FRACTAL/blob/master/example/output/FRACTAL_ML.nwk) (Newick format) 

**Example 4**

Lineage estimation with a software tool of choice and user defined parameters.

1. Prepare a shell script that takes a FASTA file as an input file, calculate a lineage of the input sequences, and output it to a Newick format file whose name is inherited from the input FASTA file, like from `foo.fa` to `foo.fa.tree`.

2. Add the absolute path of the shell script to `$PATH`

3. Make the shell script executable

4. Execute FRACTAL as follows. The example shell script file [`ml_raxml.sh`](https://github.com/yachielab/FRACTAL/blob/hotfix/example/script/ml_raxml.sh) below is prepared and provided in the installation package for ML method with GTR-Gamma model by RAxML. The maximum number of computing nodes is set to 100 in the following command. The computation will take 20~30 min.

   ```shell
   FRACTAL -i test.fa -f FRACTAL_raxml -s ml_raxml.sh -d 100
   ```

**Example 5**

Lineage estimation from an unaligned sequence dataset. The number of sequences in a subsample and the threshold number of input sequences to swich to direct lineage computing are set to be 1,000.

```shell
FRACTAL -i test.unaligned.fa -f FRACTAL_unaligned -k 1000 -t 1000 -m fasttreeML -u
```

Input:    

​	 [`test.unaligned.fa`](https://github.com/yachielab/FRACTAL/blob/master/example/test.unaligend.fa) (FASTA format)

Output:  

​	 [`FRACTAL_unaligned.nwk`](https://github.com/yachielab/FRACTAL/blob/master/example/output/FRACTAL_unaligned.nwk) (Newick format) 

**Example 6**

Lineage estimation from sets of substitutions, insertions and deletions  using MP (RAxML) and phylogenetic placement using MP (RAxML). When `-E` option is specified, FRACTAL takes a special input file format to describe any set of mutations (see example input).

```shell
FRACTAL -i test.edit -f FRACTAL_edit -p MP -E
```

Input:    

​	 [`test.edit`](https://github.com/yachielab/FRACTAL/blob/master/example/test.edit) (Original format)

Output:  

​	 [`FRACTAL_edit.nwk`](https://github.com/yachielab/FRACTAL/blob/master/example/output/FRACTAL_edit.nwk) (Newick format) 

### FRACTAL Usage

```
Usage:
    FRACTAL.sh
    [-v] [-h] [-i input_file] [-f output_file_path] [-f output_file_name]
    [-u] [-m method] [-a "options"] [-s script_file_name] [-k sequence_number]
    [-b model_name] [-p placement_method] [-x iteration_number] [-t sequence_number]
    [-d job_number] [-c thread_number] [-e] [-r integer] [-n file_path] [-E] 
    [-O qsub_option] [-I first_qsub_option] [-A last_qsub_option] [-j job_name] 
    [-l iteration_upper_limit] [-g]

Options:
    -v
      Print FRACTAL version; ignore all the other parameters
    -h
      Print the usage of FRACTAL; ignore all the other parameters
    -i <String>
      Input FASTA file
    -o <String>
      Output directory path. Default: current working directory
    -f <String>
      Output file name. Default: FRACTALout
    -u
      Reconstuct a lineage from unaligned sequences
    -m <String, Permissible values: ‘raxmlMP’, ‘rapidnjNJ’ and ‘fasttreeML’>
      Method to reconstruct lineage tree in each iteration cycle. Default: raxmlMP
        When you specify -s option, this option will be ignored.
    -a "<String>"
      Options for the software corresponding to the method selected by -m
    -s <String>
      File name of a shell script used to reconstruct lineage tree in each iteration cycle.
        See sample codes (example 4).
    -k <Integer>
      Number of sequences for the subsampling procedure. Default: 100
    -z <Integer>
      Number of extracted tips from sample tree. 
      Default: the number specified by "-k" (Tree extraction is not conducted)
    -b <String>
      Substitution model of RAxML for phylogenetic placement. Default: GTRCAT
    -p <String, Permissible values: ‘ML’, ‘MP’>
      Method for phylogenetic placement in each iteration cycle.
        Placement by ML and MP method is conducted by EPAng and RAxML respecitively
        Default: ML
    -x <Integer>
      Threshold for the maximum number of retrial iterations in the subsampling process
    -t <Integer>
      Threshold number of input sequences to switch to direct lineage tree reconstruction 
        in each iteration cycle. Default: 500
    -d <Integer>
      Maximum number of jobs permissible for distributed computing.
        Default: 1 (no distributed computing)
    -c <Integer>
      Number of threads for the subsample tree reconstruction and the phylogenetic placement
        in each iteration cycle. Default: 1
    -e
      Output intermediate files
    -r <Integer>
      Seed number for generation of random values. Default: 0
    -E 
      Take original input file format. 
      Currently, this option can be used only with "-p MP -d 1", and without "-g" option.
    -O "<String>"
      Options for qsub. Default: ""
        example:  -O "-pe def_slot 4 -l s_vmem=16G -l mem_req=16G" 
    -I "<String>"
      Options especially for the first qsub. Default: the string specified by -O
    -A "<String>"
      Options especially for the last qsub (tree assembly). 
        Default: the string specified by -O
    -j "<String>"
      Name of the jobs distributed by FRACTAL. Default: "FRACTAL"
    -l <Integer>
      Maximum number of FRACTAL iterations. Default: 10000
    -g 
      Gzip intermediate files
```


### Contact


Naoki Konno (The University of Tokyo) [naoki@bs.s.u-tokyo.ac.jp](mailto:naoki@bs.s.u-tokyo.ac.jp)

Nozomu Yachie (The University of Tokyo) [nzmyachie@gmail.com](mailto:yachie@synbiol.rcast.u-tokyo.ac.jp)

