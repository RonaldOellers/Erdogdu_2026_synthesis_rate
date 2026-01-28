# TT-seq synthesis rate reproduction (SpikeinMedian)

This repository reproduces synthesis rate calculations from TT-seq and RNA-seq data using spike-in normalization.

## Input data

The required RData inputs for each experiment must be placed in:

- `data/BRD234_inhibition/`

Each directory should contain:

- `bam.files.RData`
- `bam.files.mat.RData`
- `database.merge.htseq.RPKs.antisense.corrected.RData`
- `alternative.sequencing.depth.RData`
- `alternative.cross.contamination.RData`

## Running the workflow
### Option 1: run Snakemake manually in a conda environment

1. Create and activate an environment with Snakemake:
```bash
conda create -n ttseq_synth -c conda-forge -c bioconda snakemake
conda activate ttseq_synth
```

2. Clone this repository:
```bash
git clone https://github.com/RonaldOellers/Erdogdu_2026_synthesis_rate.git
cd Erdogdu_2026_synthesis_rate/TTseq_synthesis_rates
```

3. Run the workflow
```bash
snakemake -j 2
```
> [!IMPORTANT]  
> make sure the input RData files are in data/BRD234_inhibition before running

&nbsp;
---
&nbsp;

### Option 2: install as CalcSynthesisRates package
This option takes care of installing snakemake for you and you can run everything from a single command

1. Create and activate a conda environment:
```bash
conda create -n ttseq_synth -c conda-forge -c bioconda python=3.12
conda activate ttseq_synth
```

2. Install this project as a package:
```bash
git clone https://github.com/RonaldOellers/Erdogdu_2026_synthesis_rate.git
cd Erdogdu_2026_synthesis_rate
pip install -e .
```

3. Run:
```bash
CalcSynthesisRates
```
> [!IMPORTANT]  
> make sure the input RData files are in data/BRD234_inhibition before running.
> Also the output files will be generated in the package dir so make sure to use `pip install -e .` so the results will be produced in the repo dir.

&nbsp;
# Where to find the results
Both of these will create:

- Erdogdu_2026_synthesis_rate/results/BRD234_inhibition/total.synthesis.rates.replicate.list.SpikeinMedian.RData
