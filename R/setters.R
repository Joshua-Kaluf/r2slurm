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
