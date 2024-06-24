process HELPER_SEQTABLE_TO_FASTA {
    tag "${meta.sample_id}"
    label 'short_serial'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-dada2:1.28.0--r43hf17093f_0' :
        'biocontainers/bioconductor-dada2:1.28.0--r43hf17093f_0' }"

    input:
    tuple val(meta), path(rds)
    
    output:
    tuple val(meta), path('*.fasta')    , emit: fasta
    tuple val(meta), path('*.tsv')      , emit: table
    //tuple val(meta), path('*.json')     , emit: json
    path 'versions.yml'                 , emit: versions

    script:

    """
    #!/usr/bin/env Rscript
    suppressPackageStartupMessages(library(dada2))

    seqtab = readRDS("${rds}")

    asv <- data.frame(t(seqtab))
    colnames(asv) <- c("count")
    asv <- cbind(asv, name = sprintf("ASV_%s", seq(1:dim(asv)[1])))
    asv <- cbind(asv, sequence = rownames(asv))
    rownames(asv) <- seq(1:dim(asv)[1])
    fn <- function(x) paste0(">", x[2], ";size=", trimws(x[1]), "\n", x[3])
    asfasta <- apply(asv, MARGIN=1, fn)
    writeLines(asfasta, "${meta.sample_id}_ASVs.fasta")

    # Drop sequences
    asv <- subset(asv, select = -c(sequence))
    write.table(asv, file="${meta.sample_id}_table.tsv", sep = "\\t", row.names = FALSE, quote = FALSE, na = '')


    writeLines(c("\\"${task.process}\\":", paste0("    R: ", paste0(R.Version()[c("major","minor")], collapse = ".")) ), "versions.yml")
    """
}
