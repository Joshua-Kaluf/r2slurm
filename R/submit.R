# ------------------------------------------------------------
# Writing to disk
# ------------------------------------------------------------


#' Write a Slurm submission script to disk
#'
#' Converts a \code{slurm_job} object into a bash script and writes
#' it to the specified path. Automatically creates directories if needed.
#'
#' @param job A \code{slurm_job} object.
#' @param path File path where the script should be written.
#'
#' @return Invisibly returns the path to the written script.
#'
#' @examples
#' job <- slurm_job("echo Hello", job_name = "hello")
#' tmpfile <- tempfile(fileext = ".sh")
#' write_slurm_script(job, tmpfile)
#' cat(readLines(tmpfile), sep = "\n")
#'
#' @export
write_slurm_script <- function(job, path) {
  if (!inherits(job, "slurm_job")) {
    stop("Expected a slurm_job object")
  }

  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(render_script(job), path)
  invisible(path)
}

# ------------------------------------------------------------
# Submission
# ------------------------------------------------------------

#' Submit a Slurm job using sbatch
#'
#' Writes a submission script and submits it to Slurm. Can also run
#' in dry-run mode to inspect the script without submitting.
#'
#' @param job A \code{slurm_job} object.
#' @param script File path to write the temporary script.
#' @param dry_run Logical; if TRUE, do not submit the job, just write the script.
#'
#' @return In dry-run mode, returns the script path. Otherwise, returns
#' the output of \code{system2("sbatch", script)}.
#'
#' @examples
#' job <- slurm_job("echo Hello", job_name = "hello")
#'
#' # Dry run: inspect script without submitting
#' sbatch(job, dry_run = TRUE)
#'
#' # Actual submission (requires Slurm)
#' \dontrun{
#' sbatch(job)
#' }
#'
#' @export
sbatch <- function(job,
                   script = tempfile(fileext = ".sh"),
                   dry_run = FALSE) {
  write_slurm_script(job, script)

  if (dry_run) {
    message("Dry run - script written to: ", script)
    return(script)
  }

  system2("sbatch", script)
}
