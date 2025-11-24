#!/usr/bin/env nextflow

process COMPUTEMATRIX {

    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: "copy"

    input:
    tuple val(sample), path(bw)
    path(bed)
    val(window)

    output:
    tuple val(sample), path("${sample}_matrix.gz"), emit: matrix

    script:
    """
    computeMatrix scale-regions -S ${bw} -R $bed -b $window -a $window -o ${sample}_matrix.gz
    """

    stub:
    """
    touch ${sample_id}_matrix.gz
    """
}
