# tests/testthat/test-slurm_job.R

library(testthat)
library(r2slurm)  # make sure your package name matches DESCRIPTION

# ------------------------------------------------------------
# Creation
# ------------------------------------------------------------
test_that("slurm_job creates a valid job object", {
  job <- slurm_job("echo Hello", job_name = "hello", cpus = 2)
  
  expect_s3_class(job, "slurm_job")
  expect_equal(job$options$job_name, "hello")
  expect_equal(job$options$cpus, 2)
  expect_true(is.character(job$body))
})

test_that("slurm_job validates input", {
  expect_error(slurm_job(123), "`body` must be a character vector")
  expect_error(slurm_job(), "`body` is required")
})

# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
test_that("validate_slurm works as expected", {
  job <- slurm_job("echo Hello", mem = "4G")
  expect_true(invisible(validate_slurm(job)))
  
  bad_job <- slurm_job("echo Fail", mem = "4G", mem_per_cpu = "2G")
  expect_error(validate_slurm(bad_job), "Use only one of `mem` or `mem_per_cpu`")
})

# ------------------------------------------------------------
# Rendering
# ------------------------------------------------------------
test_that("render_sbatch produces expected SBATCH lines", {
  opts <- list(job_name = "test", cpus = 2, array = 1:5, output = "logs/%x.out")
  lines <- render_sbatch(opts)
  
  expect_true(any(grepl("--job-name=test", lines)))
  expect_true(any(grepl("--cpus-per-task=2", lines)))
  expect_true(any(grepl("--array=1-5", lines)))
  expect_true(any(grepl("--output=logs/%x.out", lines)))
})

test_that("render_script produces a full script", {
  job <- slurm_job("echo Hello", job_name = "test")
  script <- render_script(job)
  
  expect_true(any(grepl("#!/bin/bash", script)))
  expect_true(any(grepl("echo Hello", script)))
  expect_true(any(grepl("--job-name=test", script)))
})

# ------------------------------------------------------------
# Setters
# ------------------------------------------------------------
test_that("setter functions update job options", {
  job <- slurm_job("echo Hello")
  job <- set_mem(job, "16G")
  job <- set_time(job, "01:00:00")
  job <- set_cpus(job, 4)
  job <- set_job_name(job, "myjob")
  job <- set_partition(job, "short")
  
  expect_equal(job$options$mem, "16G")
  expect_equal(job$options$time, "01:00:00")
  expect_equal(job$options$cpus, 4)
  expect_equal(job$options$job_name, "myjob")
  expect_equal(job$options$partition, "short")
})

# ------------------------------------------------------------
# Writing and Submission (dry-run)
# ------------------------------------------------------------
test_that("write_slurm_script writes to disk", {
  job <- slurm_job("echo Hello", job_name = "write_test")
  tmp <- tempfile(fileext = ".sh")
  
  path <- write_slurm_script(job, tmp)
  expect_true(file.exists(path))
  
  content <- readLines(path)
  expect_true(any(grepl("echo Hello", content)))
})

test_that("sbatch dry-run works", {
  job <- slurm_job("echo Hello", job_name = "dryrun_test")
  tmp <- sbatch(job, dry_run = TRUE)
  
  expect_true(file.exists(tmp))
  content <- readLines(tmp)
  expect_true(any(grepl("echo Hello", content)))
})
