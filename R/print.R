# ------------------------------------------------------------
# Printing
# ------------------------------------------------------------

#' Print a Slurm job
#'
#' Displays a summary of Slurm options and a preview of the job body.
#' The SBATCH flags are printed using the same mapping as \code{render_sbatch()},
#' so the preview matches exactly what will be written to the script.
#'
#' @param x A \code{slurm_job} object.
#' @param ... Unused.
#'
#' @return Invisibly returns the input \code{slurm_job} object.
#'
#' @examples
#' job <- slurm_job(
#'   body = "echo Hello World",
#'   job_name = "hello",
#'   cpus = 2,
#'   mem = "4G"
#' )
#' print(job)
#'
#' @export
print.slurm_job <- function(x, ...) {
  cat("<slurm_job>\n\n")
  
  # SBATCH options
  opts <- x$options
  if (length(opts) > 0) {
    cat("SBATCH options:\n")
    for (name in names(opts)) {
      value <- opts[[name]]
      if (!is.null(value)) {
        flag <- slurm_flag(name)  # uses same mapping as render_sbatch()
        cat("  ", flag, "=", value, "\n", sep = "")
      }
    }
  } else {
    cat("SBATCH options: <none>\n")
  }
  
  # Full body
  cat("\nBody:\n")
  if (length(x$body) == 0) {
    cat("  <empty>\n")
  } else {
    for (line in x$body) {
      cat("  ", line, "\n", sep = "")
    }
  }
  
  invisible(x)
}

