# r2slurm

r2slurm provides a chainable, user-friendly interface to create, render, and submit Slurm jobs from R. Perfect for labs or projects that rely on Slurm-managed clusters.

---

## Features

- Define Slurm jobs in R using simple functions.
- Chainable setters for memory, CPUs, walltime, partitions, and job name.
- Render jobs into SBATCH scripts ready for submission.
- Submit jobs directly to Slurm via `sbatch`.
- Preview scripts without submitting using dry-run mode.

---

## Installation

# Install devtools if you don't have it
install.packages("devtools")

# Install r2slurm from GitHub
devtools::install_github("yourusername/r2slurm")
# Replace 'yourusername' with your GitHub username

---

## Usage

library(r2slurm)

# Create a basic job
job <- slurm_job("echo Hello World") %>%
  set_mem("16G") %>%
  set_time("01:00:00") %>%
  set_job_name("hello_job")

# Preview the SBATCH script
render_script(job)

# Write to disk
write_slurm_script(job, "hello_job.sh")

# Submit to Slurm (dry-run)
sbatch(job, dry_run = TRUE)

# et_cpus(job, 4)
- set_partition(job, "short")
- set_job_name(job, "my_job")

---

## License

MIT License — see LICENSE for details.

---

## Exlysis.py")) %>%
  set_mem("32thon_analysis")

# Inspect and submit
render_script(job)
sbatch(job, dry_run = TRUE)
