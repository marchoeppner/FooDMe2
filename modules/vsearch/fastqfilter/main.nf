process VSEARCH_FASTQFILTER {
    tag "${meta.sample_id}"

    label 'short_serial'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vsearch:2.27.0--h6a68c12_0' :
        'quay.io/biocontainers/vsearch:2.27.0--h6a68c12_0' }"

    input:
    tuple val(meta), path(fq)

    output:
    tuple val(meta), path(filtered), emit: fasta
    path("versions.yml"), emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: fq.getBaseName()

    filtered = prefix + '.filtered.fasta'

    """
    vsearch -fastq_filter $fq \
    -relabel ${meta.sample_id}_Filt. \
    -threads ${task.cpus} \
    --sample ${meta.sample_id} \
    -fastaout $filtered $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vsearch: \$(vsearch --version 2>&1 | head -n 1 | sed 's/vsearch //g' | sed 's/,.*//g' | sed 's/^v//' | sed 's/_.*//')
    END_VERSIONS
    """
}
