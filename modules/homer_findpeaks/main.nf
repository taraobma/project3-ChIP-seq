#!/usr/bin/env nextflow

process FINDPEAKS {
    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(ip_tagdir), path(input_tagdir)

    output:
    tuple val(sample), path("${sample}_peaks.txt"), emit: peaks

    script:
    """
    findPeaks ${ip_tagdir} -style factor -i ${input_tagdir} -o ${sample}_peaks.txt
    """

    stub:
    """
    touch ${rep}_peaks.txt
    """
}


