# ------------------------------------------------------------
# Rendering
# ------------------------------------------------------------

# ------------------------------------------------------------
# Helper: SBATCH flag mapping (internal)
# ------------------------------------------------------------

#' Map R option names to SBATCH flags
#'
#' Converts the R-style option names used in a \code{slurm_job} object
#' into the corresponding Slurm \code{#SBATCH} flags.
#' This function is used internally by \code{render_sbatch()} and
#' can also be used by \code{print.slurm_job()} to maintain consistency.
#'
#' @param name Character. The R-style option name (e.g., "cpus", "mem_per_cpu").
#'
#' @return Character. The corresponding \code{#SBATCH} flag.
#'
#' @keywords internal
slurm_flag <- function(name) {
  switch(
    name,
    job_name = "--job-name",
    partition = "--partition",
    time = "--time",
    mem = "--mem",
    cpus = "--cpus-per-task",
    nodes = "--nodes",
    mem_per_cpu = "--mem-per-cpu",
    ntasks_per_node = "--ntasks-per-node",
    output = "--output",
    error = "--error",
    "-o" = "-o",
    "-e" = "-e",
    array = "--array",
    NULL
  ) %||% paste0("--", gsub("_", "-", name))
}

# ------------------------------------------------------------
# Render SBATCH lines
# ------------------------------------------------------------

#' Render SBATCH header lines
#'
#' Converts a named list of Slurm options into \code{#SBATCH} directives
#' suitable for inclusion at the top of a submission script.
#'
#' @param opts Named list of Slurm options (as used in a \code{slurm_job} object).
#'
#' @return Character vector of \code{#SBATCH} lines.
#'
#' @examples
#' render_sbatch(list(job_name = "test", cpus = 4, mem = "8G"))
#'
#' @export
render_sbatch <- function(opts) {
  lines <- character()

  for (name in sort(names(opts))) {
    value <- opts[[name]]
    if (is.null(value)) next

    flag <- slurm_flag(name)

    if (isTRUE(value)) {
      lines <- c(lines, sprintf("#SBATCH %s", flag))
      next
    }
    if (isFALSE(value)) next

    if (name == "array" && is.numeric(value)) {
      value <- paste0(min(value), "-", max(value))
    }

    if (is.atomic(value) && length(value) > 1) {
      value <- paste(value, collapse = ",")
    }

    lines <- c(lines, sprintf("#SBATCH %s=%s", flag, value))
  }

  lines
}

# ------------------------------------------------------------
# Render full script
# ------------------------------------------------------------

#' Render a complete Slurm submission script
#'
#' Validates a \code{slurm_job} object and converts it into a full bash script
#' suitable for submission with \code{sbatch}.
#'
#' @param job A \code{slurm_job} object.
#'
#' @return Character vector containing the complete script.
#'
#' @examples
#' job <- slurm_job("echo Hello World", job_name = "hello", cpus = 2)
#' cat(render_script(job), sep = "\n")
#'
#' @export
render_script <- function(job) {
  if (!inherits(job, "slurm_job")){
    stop("Expected a slurm_job object")
  }

  validate_slurm(job)

  c(
    job$shebang,
    render_sbatch(job$options),
    "",
    "set -euo pipefail",
    "",
    job$body
  )
}
