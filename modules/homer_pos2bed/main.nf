#!/usr/bin/env nextflow

process POS2BED {

    label 'process_high'
    container 'ghcr.io/bf528/homer_samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(sample), path(peak_txt)

    output:
    tuple val(sample), path("${peak_txt.baseName}.bed"), emit: bed

    script:
    """
    pos2bed.pl ${peak_txt} > ${peak_txt.baseName}.bed
    """

    stub:
    """
    touch ${homer_txt.baseName}.bed
    """
}


