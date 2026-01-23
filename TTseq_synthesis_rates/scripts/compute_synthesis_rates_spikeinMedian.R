#!/usr/bin/env Rscript

# -------------------------------------------------------------------
# Usage:
#   Rscript compute_synthesis_rates_spikeinMedian.R <input_dir> <output_file>
#
# <input_dir> must contain:
#   bam.files.RData
#   bam.files.mat.RData
#   database.merge.htseq.RPKs.antisense.corrected.RData
#   alternative.sequencing.depth.RData
#   alternative.cross.contamination.RData
#
# Output:
#   <output_file>, e.g.
#   results/BRD2_AID/total.synthesis.rates.replicate.list.SpikeinMedian.RData
# -------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Usage: Rscript compute_synthesis_rates_spikeinMedian.R <input_dir> <output_file>")
}

indir  <- args[[1]]
outfile <- args[[2]]

# ensure directory for outfile exists
outdir <- dirname(outfile)
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

# ----------------------------
# Load input data
# ----------------------------

load(file.path(indir, "bam.files.RData"))                            # bam.files
load(file.path(indir, "bam.files.mat.RData"))                        # bam.files.mat

load(file.path(indir, "database.merge.htseq.RPKs.antisense.corrected.RData"))
load(file.path(indir, "alternative.sequencing.depth.RData"))
load(file.path(indir, "alternative.cross.contamination.RData"))

sequencing.depth    <- alternative.sequencing.depth
cross.contamination <- alternative.cross.contamination


# ----------------------------
# Define labeled and total samples
# ----------------------------

# TT-seq: fraction == "TTseq" OR "L_with"
labeled.samples <- paste0(
  rownames(
    bam.files.mat[
      bam.files.mat[, "fraction"] %in% c("TTseq", "L"),
      ,
      drop = FALSE
    ]
  ),
  ".tabular"
)

# total RNA: fraction == "RNAseq" OR "T_with"
total.samples <- paste0(
  rownames(
    bam.files.mat[
      bam.files.mat[, "fraction"] %in% c("RNAseq", "T"),
      ,
      drop = FALSE
    ]
  ),
  ".tabular"
)

# Spike‑in–median normalized TT and RNA coverage
labeled <- t(
  t(database.merge.htseq.RPKs.antisense.corrected[, labeled.samples]) /
    sequencing.depth[labeled.samples]
)

total <- t(
  t(database.merge.htseq.RPKs.antisense.corrected[, total.samples]) /
    sequencing.depth[total.samples]
)


# ----------------------------
# Decay and synthesis rate calculation
# ----------------------------

# Doubling time: 13.3 h for this celltpye (can be changed here if needed)
growthtime <- 13.3
alpha <- log(2) / (growthtime * 60)   # per minute

# 5 minutes labeling time
decay.rate <- t(-alpha - 1 / 5 * log(t(1 - labeled / total) / (1 - cross.contamination[labeled.samples])))

decay.rate[decay.rate <= 0] <- NA

synthesis.rate <- total * t(alpha + t(decay.rate))
colnames(synthesis.rate) <- colnames(decay.rate)

# ----------------------------
# Per‑replicate synthesis rate lists
# ----------------------------

total.synthesis.rates.replicate.list <- list()

for (bam.file in bam.files[grep("TTseq_|L_with", bam.files)]) {
  colname <- gsub(".bam", ".tabular", bam.file)
  total.synthesis.rates.replicate.list[[bam.file]] <-
    synthesis.rate[, colname, drop = FALSE]
}

save(
  total.synthesis.rates.replicate.list,
  file = file.path(outfile)
)

message("Synthesis rate calculation (SpikeinMedian) completed.")
