#' @importFrom magrittr %>%
NULL

# ------------------------------------------------------------
# Creation of Slurm Job Object
# ------------------------------------------------------------

#' Create a Slurm job object
#'
#' Constructs a Slurm job specification that can be rendered to an
#' sbatch script and submitted to a Slurm scheduler.
#' Validation is always performed when rendering or submitting a job.
#' Setting `validate = TRUE` performs an additional check at construction time.
#'
#' @param body Character vector of shell commands to execute.
#' @param job_name Name of the Slurm job.
#' @param partition Slurm partition to submit to.
#' @param time Walltime limit (e.g. "02:00:00").
#' @param mem Total memory for the job.
#' @param cpus Number of CPUs per task.
#' @param nodes Number of nodes.
#' @param output Path for stdout log file.
#' @param error Path for stderr log file.
#' @param shebang Shebang line for the script (default "#!/bin/bash").
#' @param validate Whether calling slurm_job should immediately test validity of options.
#' @param ... Any additional Slurm options not explicitly listed.
#'
#' @return A \code{slurm_job} object.
#'
#' @examples
#' # Simple job
#' job1 <- slurm_job("echo Hello World", job_name = "hello", cpus = 2)
#'
#' # Job with memory, walltime, and partition
#' job2 <- slurm_job(
#'   body = c("module load python", "python script.py"),
#'   job_name = "python_job",
#'   partition = "short",
#'   time = "01:00:00",
#'   mem = "4G",
#'   cpus = 2
#' )
#'
#' # Validation at creation
#' \dontrun{
#' job3 <- slurm_job("echo Validate Me", validate = TRUE)
#'}
#'
#' @export
slurm_job <- function(
    body = NULL,
    job_name = NULL,
    partition = NULL,
    time = NULL,
    mem = NULL,
    cpus = NULL,
    nodes = NULL,
    output = "logs/%x_%j.out",
    error  = "logs/%x_%j.err",
    shebang = "#!/bin/bash",
    validate = FALSE,
    ...
) {
  # Allow body to be NULL, character, or a function returning character
  if (is.null(body)) {
    body <- character()
  } else if (is.function(body)) {
    body <- body()
  } 
  
  body <- as.character(body)

  opts <- list(
    job_name = job_name,
    partition = partition,
    time = time,
    mem = mem,
    cpus = cpus,
    nodes = nodes,
    output = output,
    error = error,
    ...
  )

  job <- structure(
    list(
      shebang = shebang,
      options = opts,
      body = body
    ),
    class = "slurm_job"
  )
  if (validate) validate_slurm(job)
  job
}

# ------------------------------------------------------------
# Validation (internal)
# ------------------------------------------------------------

#' Validate a Slurm job object
#'
#' Performs basic consistency checks on a \code{slurm_job} object.
#' Called automatically during rendering and submission. Can also be called
#' manually to check job validity before further processing.
#'
#' @param job A \code{slurm_job} object.
#'
#' @return Invisibly returns TRUE if validation passes.
#'
#'
#' @keywords internal
validate_slurm <- function(job) {
  if (!inherits(job, "slurm_job")) {
    stop("Expected a slurm_job object")
  }

  o <- job$options

  if (!is.null(o$mem) && !is.null(o$mem_per_cpu)) {
    stop("Use only one of `mem` or `mem_per_cpu`")
  }

  if (!is.null(o$ntasks) && !is.null(o$ntasks_per_node)) {
    stop("Use only one of `ntasks` or `ntasks_per_node`")
  }

  invisible(TRUE)
}
