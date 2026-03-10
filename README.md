# RUNX1 ChIP-seq Analysis

## Overview
Implemented a modular Nextflow DSL2 ChIP-seq pipeline to identify genome-wide RUNX1 
binding sites in breast cancer cells (GEO: GSE75070).

The workflow performs read QC, trimming, alignment, peak calling, reproducibility 
filtering, motif enrichment, and integration with RNA-seq differential expression data.

## Biological Question
Does RUNX1 function as an architectural transcription factor by regulating 
promoter-proximal regions and influencing chromatin organization in breast cancer?

## Dataset
- Accession: GEO: GSE75070
- Organism: *Homo sapiens* (hg38)
- Cell type: Breast cancer cells
- Samples: RUNX1 ChIP Rep1, RUNX1 ChIP Rep2, Input Rep1, Input Rep2
- Sequencing: Single-end (Illumina)

## Workflow
<img src="./figures/flowchart.png" width="450" alt="Workflow DAG">

FASTQC + BOWTIE2_BUILD → TRIM → BOWTIE2_ALIGN → SAMTOOLS_SORT/IDX/FLAGSTAT → 
MULTIQC → DEEPTOOLS (coverage & correlation) → HOMER (peak calling & motif enrichment) → BEDTOOLS (reproducible peak intersection & blacklist removal) → ANNOTATE


Implemented using modular Nextflow DSL2 processes.

## Usage

**1. Clone the repository**
```
git clone https://github.com/username/your-repo-name.git
cd your-repo-name
```


**2. Run the pipeline**
```
nextflow run main.nf -profile singularity,cluster
```

**Requirements:** Nextflow ≥ 22.0, Singularity

> **Note:** Developed and tested on BU SCC HPC cluster using Singularity containers.


## Quality Control
- ChIP Rep1: 27.7M mapped reads (from 29.7M raw)
- ChIP Rep2: 28.1M mapped reads (from 29.9M raw)
- Input Rep1: 28.1M mapped reads (from 30.1M raw)
- Input Rep2: 10.0M mapped reads (from 10.9M raw) — lower coverage, potential background noise impact
- All samples: Phred score > 30, near-zero per-base N content, read length 101 bp
- Adapter sequences appear after 60 bp — trimmed with Trimmomatic v0.40
- IP replicates flagged for per-base sequence content and sequence duplication — expected for ChIP-seq
- Input replicates failed per-sequence GC content check
- High within-group replicate correlation confirmed by DeepTools (Spearman)


## Key Results
> 6,015 reproducible peaks | ~20% DE gene overlap | Promoter-proximal TSS binding | RUNX family motifs dominant


### Reproducible Peaks
- Rep1: peaks called → Rep2: peaks called → **6,015 reproducible peaks** after BEDtools intersection
- Filtered against ENCODE hg38 blacklist regions
- Binding strongly enriched at TSS (signal: 8–9 units), drops to background (~2 units) across gene body
- Pattern consistent with a sequence-specific transcription factor regulating transcription initiation


<img src="./figures/IP_rep1_signal_coverage.png" width="400" alt="IP Rep1 Signal Coverage">
<img src="./figures/IP_rep2_signal_coverage.png" width="400" alt="IP Rep2 Signal Coverage">

### Motif Enrichment
Top enriched motifs at RUNX1 binding sites:
- RUNX family motifs (dominant)
- YY1
- FOXA family

Cooperative binding with YY1 and FOXA factors suggests RUNX1 functions alongside 
architectural regulators of chromatin organization.

<img src="./figures/knownresults.png" width="650" alt="Known Motif Enrichment">

### RNA-seq Integration
- ~20% of differentially expressed genes overlapped with RUNX1 peaks
- Higher than original study (8–10%) due to:
  - Less stringent reproducibility filtering (1 bp BEDtools overlap vs. IDR)
  - hg38 vs. hg19 reference genome
- IGV validation: MALAT1 shows strong, reproducible RUNX1 peaks confirmed in both replicates
- NEAT1 shows visual signal but was rejected during reproducibility filtering due to insufficient replicate consistency


<img src="./figures/overlapping_chip_results_with_original_RNA-seq_data.png" width="500" alt="ChIP-RNA-seq Overlap">

### Pathway Enrichment (Enrichr, Reactome)
Significant enrichment in:
- VEGFR2-mediated vascular permeability
- HSF1-dependent transactivation
- FOXO transcription factor pathways
- Histone modification complexes

<img src="./figures/Reactome_Pathways_bar_graph.png" width="550" alt="Reactome Enrichment Plot">

Supports RUNX1's regulatory role in chromatin remodeling and tumor-associated pathways.

## Comparison to Original Study
Results are broadly consistent with the original study. Observed differences are 
attributable to methodological choices rather than biological discrepancies:

| Factor | This Analysis | Original Study |
|---|---|---|
| Reference genome | hg38 | hg19 |
| Correlation metric | Spearman | Pearson |
| Reproducible peaks | 6,015 | 3,466 |
| DE gene overlap | ~20% | 8–10% |
| Peak filtering | BEDtools 1bp overlap | IDR + min signal |


## Biological Interpretation
- RUNX1 binds primarily at TSS/promoter-proximal regions (signal peak: 8–9 units at TSS), 
  consistent with its role as a sequence-specific transcriptional regulator
- Co-enrichment of YY1 and FOXA1 motifs indicates cooperative binding with architectural 
  and pioneer transcription factors in breast cancer
- FOXA1 as a pioneer factor likely opens chromatin at RUNX1 target sites; YY1 co-enrichment 
  suggests involvement in chromatin looping and regulatory hubs
- Pathway enrichment in VEGFR2, HSF1, and FOXO signaling supports RUNX1's role beyond 
  transcription initiation — coordinating chromatin-modifying machinery (WDR5 complexes) 
  relevant to tumor microenvironment and cancer progression
- Findings support RUNX1 as an architectural transcription factor influencing higher-order 
  chromatin organization in breast cancer


## Technical Highlights
- Modular Nextflow DSL2 pipeline with Singularity containers
- Automated reproducibility filtering via BEDtools peak intersection
- Multi-omics integration (ChIP-seq + RNA-seq)
- Motif discovery via HOMER
- IGV validation of peak regions
- Fully reproducible workflow on HPC


## Repository Structure
```
├── main.nf                              # Main Nextflow pipeline
├── nextflow.config                      # Configuration file
├── full_samplesheet.csv                 # Full sample sheet
├── subsampled_samplesheet.csv           # Subsampled samplesheet for testing the pipeline
├── genes_for_enrichr.txt                # Gene list for Enrichr analysis
├── modules/                             # Modular process definitions
│   ├── bedtools_intersect/main.nf
│   ├── bedtools_remove/main.nf
│   ├── bowtie2_align/main.nf
│   ├── bowtie2_build/main.nf
│   ├── deeptools_bamcoverage/main.nf
│   ├── deeptools_computematrix/main.nf
│   ├── deeptools_multibwsummary/main.nf
│   ├── deeptools_plotcorrelation/main.nf
│   ├── deeptools_plotprofile/main.nf
│   ├── fastqc/main.nf
│   ├── homer_annotatepeaks/main.nf
│   ├── homer_findmotifsgenome/main.nf
│   ├── homer_findpeaks/main.nf
│   ├── homer_maketagdir/main.nf
│   ├── homer_pos2bed/main.nf
│   ├── multiqc/main.nf
│   ├── samtools_flagstat/main.nf
│   ├── samtools_idx/main.nf
│   ├── samtools_sort/main.nf
│   └── trimmomatic/main.nf
├── bin/                                 # Helper scripts
├── envs/                                # Conda environment (notebook.yml)
├── figures/                             # Plots and visualizations
├── results/                             # Pipeline outputs (not tracked)
└── .gitignore

```


## Tools Used
- FastQC v0.12.1
- Trimmomatic v0.40
- Bowtie2 v2.5.4
- Samtools v1.22
- DeepTools v3.5.6
- HOMER v5.1
- BEDtools v2.31.1
- MultiQC v1.32
- Enrichr (Reactome Pathways)
- IGV
- Nextflow
- Singularity

