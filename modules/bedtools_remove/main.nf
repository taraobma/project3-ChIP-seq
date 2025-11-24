#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {
   
    label 'process_high'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(peaks_bed)
    path(blacklist)

    output:
    tuple val(sample), path("repr_peaks_filtered.bed"), emit: filtered_peaks

    script:
    """
    bedtools intersect -a ${peaks_bed} -b $blacklist -v > repr_peaks_filtered.bed
    """

    stub:
    """
    touch repr_peaks_filtered.bed
    """
}

// -v to only reports those entries in A that have no overlap in B 