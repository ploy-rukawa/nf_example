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
