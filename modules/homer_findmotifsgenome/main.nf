#!/usr/bin/env nextflow

process FIND_MOTIFS_GENOME {
    
    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(filtered_peaks)
    path(genome)

    output:
    path("motifs"), emit: motifs

    script:
    """
    mkdir -p motifs
    findMotifsGenome.pl ${filtered_peaks} $genome motifs
    """

    stub:
    """
    mkdir motifs
    """
}


