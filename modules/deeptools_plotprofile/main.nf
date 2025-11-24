#!/usr/bin/env nextflow

process PLOTPROFILE {
    
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy"

    input:
    tuple val(sample), path(matrix)

    output:
    path("${sample}_signal_coverage.png")

    script:
    """
    plotProfile -m ${matrix} -o ${sample}_signal_coverage.png
    """

    stub:
    """
    touch ${sample_id}_signal_coverage.png
    """
}