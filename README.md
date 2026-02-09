
# r2slurm

r2slurm provides a chainable, user-friendly interface to create, render,
and submit Slurm jobs from R. Perfect for labs or projects that rely on
Slurm-managed clusters.

------------------------------------------------------------------------

## Features

-   Define Slurm jobs in R using simple functions.
-   Chainable setters for memory, CPUs, walltime, partitions, and job
    name.
-   Render jobs into SBATCH scripts ready for submission.
-   Submit jobs directly to Slurm via `sbatch`.
-   Preview scripts without submitting using dry-run mode.

------------------------------------------------------------------------

## Installation

1. Install devtools if you don't have it

`install.packages("devtools")`

2. Install r2slurm from GitHub

`devtools::install_github("Joshua-Kaluf/r2slurm")`

------------------------------------------------------------------------

## Usage

`library(r2slurm)`

### Create a basic job

```
job <- slurm_job("echo Hello World") %>%
    set_mem("16G") %>%
    set_time("01:00:00") %>%
    set_job_name("hello_job")
```

### Preview the SBATCH script

`render_script(job)`

### Write to disk

`write_slurm_script(job, "hello_job.sh")`

### Submit to Slurm (dry-run)

`sbatch(job, dry_run = TRUE)`

### Submit for real 

`sbatch(job)`

------------------------------------------------------------------------

## Chainable Setters

-   `set_mem(job, "16G")`
-   `set_time(job, "02:00:00")`
-   `set_cpus(job, 4)`
-   `set_partition(job, "short")`
-   `set_job_name(job, "my_job")`

------------------------------------------------------------------------

## License

MIT License — see LICENSE for details.

------------------------------------------------------------------------

## Example Workflow

### Create a Slurm job to run a Python script

```
job <- slurm_job(c("module load python", "python analysis.py")) %>%
    set_mem("32G") %>%
    set_time("04:00:00") %>%
    set_cpus(8) %>%
    set_partition("long") %>%
    set_job_name("python_analysis")
```

# Inspect and submit

`render_script(job)`

`sbatch(job, dry_run = TRUE)`
