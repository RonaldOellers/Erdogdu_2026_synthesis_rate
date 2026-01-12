#!/usr/bin/env python3

import subprocess
from pathlib import Path
import sys

def main():
    """
    This will calculate synthesis rates from the Manuscript ###TODO INSERT MANUSCRIPT DOI using spike-in normalization.
    """
    # Resolve project root from this file location after installation
    project_root = Path(__file__).resolve().parent
    snakefile_path = project_root / "Snakefile"
    workdir = project_root

    # Build Workflow command
    cmd = [
        "snakemake",
        "--snakefile", str(snakefile_path),
        "--directory", str(workdir),
        "-j", "2",
        "--retries", "3"
    ]

    print(f"Running Snakemake:\n{' '.join(cmd)}")


    # Run Workflow
    ret = subprocess.call(cmd)

    if ret != 0:
        print(f"Synthesis Calculation failed with exit code {ret}", file=sys.stderr)
        sys.exit(ret)
    else:
        print(f"Synthesis Calculation completed successfully.")

if __name__ == "__main__":
    main()