#!/usr/bin/env nextflow

process ANNOTATE {

    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(filtered_peaks)
    path(genome)
    path(gtf)

    output:
    tuple val(sample), path("annotated_peaks.txt"), emit: annotated_peaks

    script:
    """
    annotatePeaks.pl ${filtered_peaks} $genome -gtf $gtf > annotated_peaks.txt
    """

    stub:
    """
    touch annotated_peaks.txt
    """
}



