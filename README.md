# r2slurm

r2slurm provides a chainable, user-friendly interface to create, render, and submit Slurm jobs from R. Perfect for labs or projects that rely on Slurm-managed clusters.

------------------------------------------------------------------------

## Features

-   Define Slurm jobs in R using simple functions.
-   Chainable setters for memory, CPUs, walltime, partitions, and job name.
-   Render jobs into SBATCH scripts ready for submission.
-   Submit jobs directly to Slurm via `sbatch`.
-   Preview scripts without submitting using dry-run mode.
-   All functions are individually well-documented with usage examples.

------------------------------------------------------------------------

## Installation

1.  Install devtools if you don't have it

```
install.packages("devtools")
```

2.  Install r2slurm from GitHub

```
devtools::install_github("Joshua-Kaluf/r2slurm")
```

------------------------------------------------------------------------

## Usage

```
library(r2slurm)
```

### Create a Basic Job

`r2slurm` provides two ways to create a simple Slurm job.  

#### Method 1: Chainable setters

```
job <- slurm_job("echo Hello World") %>%
    set_mem("16G") %>%
    set_time("01:00:00") %>%
    set_job_name("hello_job")
```

#### Method 2: Direct arguments in slurm_job

```
job <- slurm_job(
  body     = "echo Hello World",
  mem      = "16G",
  time     = "01:00:00",
  job_name = "hello_job"
)
```

Both methods create an equivalent `slurm_job` object ready for inspection, rendering, or submission.

### Preview the SBATCH script

```
render_script(job)
```

### Write to disk

```
write_slurm_script(job, "hello_job.sh")
```

### Submit to Slurm (dry-run)

You can preview a job submission without actually sending it by using `dry_run = TRUE`.  

```
sbatch(job, dry_run = TRUE)
```

**Optional:** You can also specify the `script` parameter to save the generated `.sh` file.  
If you don’t set `script`, it defaults to a temporary file via `tempfile()`.

### Submit for real

```
sbatch(job)
```

Similarly, you can provide `script = "my_job.sh"` if you want to save the submission script when submitting for real.

------------------------------------------------------------------------

## Chainable Setters

- `set_mem(job, "16G")`
- `set_time(job, "02:00:00")`
- `set_cpus(job, 4)`
- `set_partition(job, "short")`
- `set_job_name(job, "my_job")`
- `add_body(job, "module spider Python")`

### Advanced Options

For advanced users, `set_opt` allows passing named parameters **not currently exposed by the standard r2slurm setters**.  

- Underscores in the parameter names are automatically converted to dashes in the generated SBATCH script.  
  - Example: `mail_user = "me@lab.edu"` becomes `--mail-user=me@lab.edu` in the script.

```
job <- set_opt(job, mail_user = "me@lab.edu", mail_type = "END,FAIL")
```

This allows customization of Slurm directives beyond the standard setters.

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

```
render_script(job)
```

```
sbatch(job, dry_run = TRUE)
```

------------------------------------------------------------------------

### Minimal SRR / FastQC Example

One common use case is wanting to **alter the command for a SLURM submission based on input files**. With `r2slurm`, SLURM submissions are treated as `slurm_job` objects.

#### 1. Initialize a template job

```
fastqc_job <- slurm_job(
  partition  = "normal",
  ntasks     = 1,
  nodes      = 1,
  cpus       = 4,
  time       = "00:30:00",
  mail_user  = "jkaluf2@illinois.edu",
  mail_type  = "ALL",
  body       = c(
    "module purge",
    "module load FastQC/0.11.8-Java-1.8.0_152"
  )
)
```

#### 2. Generate multiple jobs from the template

```
jobs <- list()
files <- c("sample1.fastq.gz", "sample2.fastq.gz", "sample3.fastq.gz")

for (input_file in files) {
  tmp_job <- fastqc_job %>%
    add_body(paste0("fastqc ", input_file))
  jobs <- append(jobs, list(tmp_job))
}
```

#### 3. Submit all jobs to SLURM

```
for (job in jobs) {
  sbatch(job)
}
```

Now each `slurm_job` is submitted to SLURM with the correct command for that input file.
