#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=06:00:00
#SBATCH --partition=normal
#SBATCH --output=.jupyterdask/%x-%j.out
#SBATCH --reservation=hpcdat 
# Remove the line above to run without a reservation

# APPTAINER_IMAGE="oras://ghcr.io/davidverbruggen04/eoschool2026hpcworkflows:latest"
APPTAINER_IMAGE="oras://ghcr.io/hpc-dat/eocouncil_autumnschool_2026:latest"

# Bind all paths from host system within the container
_DIRS=`/usr/bin/ls -1 / | /usr/bin/awk '!/dev/' | /usr/bin/sed 's/^/\//g' `
export APPTAINER_BIND=`echo ${_DIRS} | /usr/bin/sed 's/ /,/g' `

# Use Python interpreter from the container image
PYTHON="apptainer run ${APPTAINER_IMAGE} python"

# Configure default Dask cluster settings
export DASK_DISTRIBUTED__DASHBOARD__LINK="/proxy/{port}/status"
export DASK_LABEXTENSION__FACTORY__MODULE="dask_jobqueue"
export DASK_LABEXTENSION__FACTORY__CLASS="SLURMCluster"
export DASK_JOBQUEUE__SLURM__DEATH_TIMEOUT=60
export DASK_JOBQUEUE__SLURM__PYTHON=${PYTHON}
# run without reservation
#export DASK_JOBQUEUE__SLURM__JOB_EXTRA_DIRECTIVES="['--output', '.jupyterdask/%x-%j.out']"
# run with reservation (during the workshop)
export DASK_JOBQUEUE__SLURM__JOB_EXTRA_DIRECTIVES="['--output', '.jupyterdask/%x-%j.out', '--reservation', 'hpcdat']"
export DASK_JOBQUEUE__SLURM__PROCESSES=1
export DASK_JOBQUEUE__SLURM__CORES=2
export DASK_JOBQUEUE__SLURM__MEMORY="24GiB"
export DASK_JOBQUEUE__SLURM__WALLTIME="02:00:00"
export DASK_JOBQUEUE__SLURM__QUEUE="normal"
export DASK_JOBQUEUE__SLURM__LOCAL_DIRECTORY="\$TMPDIR"

# Configure dCache access
export FSSPEC_DCACHE_API_URL="https://dcacheview.grid.surfsara.nl:22880/api/v1"
export FSSPEC_DCACHE_WEBDAV_URL="https://webdav.grid.surfsara.nl:2880"
export FSSPEC_DCACHE_TOKEN="MDAxY2xvY2F0aW9uIE9wdGlvbmFsLmVtcHR5CjAwMThpZGVudGlmaWVyIGxNUTdTaHRGCjAwMTVjaWQgaWlkOnU1S2F4cDl4CjAwMmVjaWQgaWQ6NTgwMTM7NTc1NDA7cmVtb3Rlc2Vuc2luZy1tZ3Jvb3RlcwowMDJlY2lkIGJlZm9yZToyMDI2LTExLTA4VDIzOjQ5OjUwLjczMzUzNTg0MFoKMDAzM2NpZCBob21lOi9wbmZzL2dyaWQuc2FyYS5ubC9kYXRhL3JlbW90ZXNlbnNpbmcKMDAzOGNpZCByb290Oi9wbmZzL2dyaWQuc2FyYS5ubC9kYXRhL3JlbW90ZXNlbnNpbmcvZGlzawowMDJkY2lkIGFjdGl2aXR5OkxJU1QsUkVBRF9NRVRBREFUQSxET1dOTE9BRAowMGJjY2lkIGlwOjE0NS4zOC4wLjAvMTYsMTQ1LjEwMC41LjAvMjcsMTQ1LjEwMC41LjIxMC8yNiwxNDUuMTAwLjMyLjAvMjIsMTQ1LjEwMC40OC4wLzIzLDE0NS4xMDAuNTAuMC8yMywxNDUuMTAwLjIwMC4wLzIxLDE0NS4xMDAuOS42NC8yOSwxNDUuMTAxLjMyLjAvMjEsMTQ1LjEwMC41Ni4wLzIyLDIwMDE6NjEwOjEwODo6LzQ4CjAwMmZzaWduYXR1cmUgYuvDgU5n5M87PTC5U2bduEPxnfYpwIxcavhmieBfprQK"

# Start the Jupyter server
${PYTHON} \
  -m jupyterlab \
  --no-browser \
  --port=`shuf -i 8400-9400 -n 1` \
  --ip=`hostname -s`
