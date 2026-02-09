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
  cat("<slurm_job>\n")

  opts <- x$options
  if (length(opts) > 0) {
    cat("SBATCH options:\n")
    for (name in names(opts)) {
      value <- opts[[name]]
      if (!is.null(value)) {
        # Use the same flag mapping as render_sbatch()
        flag <- slurm_flag(name)
        cat("  ", flag, "=", value, "\n", sep = "")
      }
    }
  } else {
    cat("SBATCH options: <none>\n")
  }

  cat("\nBody:\n")
  body_lines <- strsplit(x$body, "\n")[[1]]
  preview <- head(body_lines, 5)

  for (line in preview) {
    cat("  ", line, "\n", sep = "")
  }

  if (length(body_lines) > 5) cat("  ...\n")

  invisible(x)
}
