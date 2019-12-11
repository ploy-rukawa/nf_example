params.ref = ""
params.input = ""
params.outdir = "./nf_workshop/results/"

log.info """\
         N F - W O R K S H O P
         ===================================
         ref          : ${params.ref}
         input        : ${params.input}
         outdir       : ${params.outdir}
         """
         .stripIndent()

 ch_ref = Channel.fromPath("$params.ref", checkIfExists:true)
 ch_input = Channel.fromPath("$params.input", checkIfExists:true)
 // ch_ref.println()

process create_mmi {

  input:
  file genome from ch_ref

  output:
  file "*mmi" into ch_mmi

  script:
  """
  minimap2 -ax splice -uf -t $task.cpus -d ${genome.baseName}.mmi $genome
  """
}

process minimap_align {

  input:
  file mmi from ch_mmi
  file fastq from ch_input

  output:
  file "*.sam" into ch_sam

  script:
  """
  minimap2 -ax splice -uf -t $task.cpus $mmi $fastq > ${fastq.baseName}.sam
  """
}

process sam_to_bam {
  publishDir params.outdir, mode:'copy',
  saveAs: { filename -> if (filename.endsWith(".bam")) filename }

  input:
  file sam from ch_sam

  output:
  file "*.bam" into ch_bam

  script:
  """
  samtools view -Sb $sam | samtools sort -o ${sam.baseName}.bam -
  """
}
workflow.onComplete {
    println ( workflow.success ? "\nPipeline Completed! Results stored in -->  $params.outdir\n" : "Oops .. something went wrong" )
}
