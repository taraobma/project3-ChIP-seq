nextflow.enable.dsl = 2

// Include your modules here
include {FASTQC} from './modules/fastqc'
include {TRIM} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {MULTIQC} from './modules/multiqc'
include {MULTIBWSUMMARY} from './modules/deeptools_multibwsummary'
include {PLOTCORRELATION} from './modules/deeptools_plotcorrelation'
include {TAGDIR} from './modules/homer_maketagdir'
include {FINDPEAKS} from './modules/homer_findpeaks'
include {POS2BED} from './modules/homer_pos2bed'
include {BEDTOOLS_INTERSECT} from './modules/bedtools_intersect'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {ANNOTATE} from './modules/homer_annotatepeaks'
include {COMPUTEMATRIX} from './modules/deeptools_computematrix'
include {PLOTPROFILE} from './modules/deeptools_plotprofile'
include {FIND_MOTIFS_GENOME} from './modules/homer_findmotifsgenome'


workflow {
    
    //Here we construct the initial channels we need
    
    Channel.fromPath(params.samplesheet)
        .splitCsv( header: true )
        .map{ row -> tuple(row.name, file(row.path)) }
        .set { read_ch }

    FASTQC(read_ch)

    TRIM(read_ch, params.adapter_fa)

    BOWTIE2_BUILD(params.genome)

    BOWTIE2_ALIGN(TRIM.out.trimmed, BOWTIE2_BUILD.out)

    SAMTOOLS_SORT(BOWTIE2_ALIGN.out)

    SAMTOOLS_IDX(SAMTOOLS_SORT.out)

    SAMTOOLS_FLAGSTAT(BOWTIE2_ALIGN.out)

    BAMCOVERAGE(SAMTOOLS_IDX.out)

    multiqc_ch = FASTQC.out.zip
            .map { sample, zip -> zip }
            .mix(TRIM.out.log, SAMTOOLS_FLAGSTAT.out)
            .collect()
    

    MULTIQC(multiqc_ch)

    bw_ch = BAMCOVERAGE.out.map {sample, bw -> bw }.collect()

    MULTIBWSUMMARY(bw_ch)
    
    //plotting the correlation plot with spearman correlation
    PLOTCORRELATION(MULTIBWSUMMARY.out, params.corrtype)

    TAGDIR(BOWTIE2_ALIGN.out)

    tagdir_ch = TAGDIR.out

    input_ch = tagdir_ch.filter { tag -> tag.getName().startsWith('INPUT') }
    ip_ch    = tagdir_ch.filter { tag -> tag.getName().startsWith('IP') }

    input_ch_key = input_ch.map { tag -> tuple(tag.getName().split('_')[1], tag )}

    ip_ch_key = ip_ch.map { tag -> tuple(tag.getName().split('_')[1], tag )}

    paired_ch = ip_ch_key.join(input_ch_key)
      
    FINDPEAKS(paired_ch)

    POS2BED(FINDPEAKS.out)

    bed1_ch = POS2BED.out.filter { name, bed -> name.contains('rep1') }
    bed2_ch = POS2BED.out.filter { name, bed -> name.contains('rep2') }

    bed1_key = bed1_ch.map { n, b -> tuple(n.replaceAll('_?rep1', ''), b) }
    bed2_key = bed2_ch.map { n, b -> tuple(n.replaceAll('_?rep2', ''), b) }

    bed_paired_ch = bed1_key.join(bed2_key).map { key, bed1, bed2 -> tuple(key, bed1, bed2) }

    BEDTOOLS_INTERSECT(bed_paired_ch)

    BEDTOOLS_REMOVE(BEDTOOLS_INTERSECT.out, params.blacklist)

    ANNOTATE(BEDTOOLS_REMOVE.out, params.genome, params.gtf)

    ip_bw_ch = BAMCOVERAGE.out.filter { sample, bw -> sample.contains('IP') }

    COMPUTEMATRIX(ip_bw_ch, params.ucsc_genes, params.window)

    PLOTPROFILE(COMPUTEMATRIX.out)

    FIND_MOTIFS_GENOME(BEDTOOLS_REMOVE.out, params.genome)

}

