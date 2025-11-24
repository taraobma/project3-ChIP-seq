#!/usr/bin/env nextflow

process TAGDIR {
    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(bam)

    output:
    path("${sample}_tags"), emit: tagdir

    script:
    """
    makeTagDirectory ${sample}_tags ${bam} -format sam
    """

    stub:
    """
    mkdir ${sample_id}_tags
    """
}


