# ------------------------------------------------------------
# Chainable setters
# ------------------------------------------------------------

#' Set memory for a Slurm job
#'
#' @param job A \code{slurm_job} object.
#' @param mem Memory value (e.g. "16G").
#'
#' @return Updated \code{slurm_job} object.
#'
#' @examples
#' job <- slurm_job("echo Hello") %>% set_mem("16G")
#' job <- set_mem(job, "32G")  # alternative non-pipe usage
#'
#' @export
set_mem <- function(job, mem) {
  job$options$mem <- mem
  job
}

#' Set walltime for a Slurm job
#'
#' @param job A \code{slurm_job} object.
#' @param time Time limit (e.g. "01:00:00").
#'
#' @return Updated \code{slurm_job} object.
#'
#' @examples
#' job <- slurm_job("echo Hello") %>% set_time("02:00:00")
#'
#' @export
set_time <- function(job, time) {
  job$options$time <- time
  job
}

#' Set CPUs per task
#'
#' @param job A \code{slurm_job} object.
#' @param cpus Number of CPUs.
#'
#' @return Updated \code{slurm_job} object.
#'
#' @examples
#' job <- slurm_job("echo Hello") %>% set_cpus(4)
#'
#' @export
set_cpus <- function(job, cpus) {
  job$options$cpus <- cpus
  job
}

#' Set Slurm partition
#'
#' @param job A \code{slurm_job} object.
#' @param partition Partition name.
#'
#' @return Updated \code{slurm_job} object.
#'
#' @examples
#' job <- slurm_job("echo Hello") %>% set_partition("short")
#'
#' @export
set_partition <- function(job, partition) {
  job$options$partition <- partition
  job
}

#' Set Slurm job name
#'
#' @param job A \code{slurm_job} object.
#' @param name Job name.
#'
#' @return Updated \code{slurm_job} object.
#'
#' @examples
#' job <- slurm_job("echo Hello") %>% set_job_name("my_job")
#'
#' @export
set_job_name <- function(job, name) {
  job$options$job_name <- name
  job
}
#' Add commands to a Slurm job body
#'
#' Append, prepend, or insert lines into the `body` of a \code{slurm_job} object.
#' You can pass a character vector of commands, a single string, or a function
#' that returns a character vector (for dynamically generated commands).
#'
#' @param job A \code{slurm_job} object.
#' @param code Character vector, single string, or function returning character
#'   lines to add to the job body.
#' @param position Integer or one of \code{"start"}, \code{"end"}:
#'   - \code{"end"} (default) appends lines,
#'   - \code{"start"} prepends lines,
#'   - numeric inserts at the given index (1-based).
#'
#' @return The updated \code{slurm_job} object, allowing for chaining.
#'
#' @examples
#' # Create a simple job
#' job <- slurm_job("echo Start", job_name = "example")
#'
#' # Append commands
#' job <- add_body(job, c("module load python", "python script.py"))
#' 
#' # Chain Commands
#' job <- slurm_job("echo Start", job_name = "example") %>%
#'        add_body(c("module load python", "python script.py"))
#'
#' # Prepend a command
#' job <- add_body(job, "echo Preparing job", position = "start")
#'
#' # Insert at specific line (before the second command)
#' job <- add_body(job, "echo Inserted line", position = 2)
#'
#' # Use a function to dynamically generate commands
#' job <- add_body(job, function() {
#'   paste("echo Dynamic command", 1:3)
#' })
#'
#' # Render script to see the effect
#' render_script(job)
#'
#' @export
add_body <- function(job, code, position = "end") {
  if (!inherits(job, "slurm_job")) stop("Expected a slurm_job object")
  
  # Convert functions to character if necessary
  if (is.function(code)) code <- code()
  
  # Ignore NULL or length-0 input
  if (is.null(code) || length(code) == 0) return(job)
  
  # Ensure code is character
  code <- as.character(code)
  
  # Append based on position
  if (is.character(position)) {
    if (position == "end") {
      job$body <- c(job$body, code)
    } else if (position == "start") {
      job$body <- c(code, job$body)
    } else {
      stop('position must be "start" or "end" or integer')
    }
  } else if (is.numeric(position)) {
    pos <- as.integer(position)
    if (pos < 1 || pos > length(job$body) + 1) stop("Numeric position out of range")
    job$body <- append(job$body, code, after = pos - 1)
  } else {
    stop("position must be 'start', 'end', or numeric")
  }
  
  # Ensure class is preserved
  class(job) <- c("slurm_job", class(job)[class(job) != "slurm_job"])
  
  job
}


#' Set arbitrary Slurm options on a job
#'
#' Allows setting one or more Slurm options that are not covered by
#' dedicated setter functions (e.g. \code{mail_user}, \code{mail_type},
#' \code{qos}, cluster-specific flags).
#'
#' Option names should be provided using underscore-separated R-style
#' names (e.g. \code{mail_user}), which will automatically be translated
#' to SBATCH flags (e.g. \code{--mail-user}) when rendering.
#'
#' This function is fully chainable and intended as an advanced or
#' escape-hatch interface.
#'
#' @param job A \code{slurm_job} object.
#' @param ... Named Slurm options to set.
#' @param .list An optional named list of Slurm options.
#'
#' @return Updated \code{slurm_job} object.
#'
#' @examples
#' # Set mail notifications
#' job <- slurm_job("echo Hello") %>%
#'   set_opt(mail_user = "me@lab.edu", mail_type = "END,FAIL")
#'
#' # Set a cluster-specific option
#' job <- slurm_job("echo Custom") %>%
#'   set_opt(qos = "high")
#'
#' # Supply options via a list
#' opts <- list(
#'   mail_user = "me@lab.edu",
#'   mail_type = "BEGIN,END"
#' )
#'
#' job <- slurm_job("echo From list") %>%
#'   set_opt(.list = opts)
#'
#' @export
set_opt <- function(job, ..., .list = NULL) {
  if (!inherits(job, "slurm_job")) {
    stop("Expected a slurm_job object")
  }
  
  opts <- c(list(...), .list)
  
  if (length(opts) == 0) {
    return(job)
  }
  
  for (nm in names(opts)) {
    job$options[[nm]] <- opts[[nm]]
  }
  
  job
}

