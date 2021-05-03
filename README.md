# SGE submission tutorial
3 May 2021


The Sun Grid Engine (SGE) scheduler is used to run jobs in a semi-organized way that maximizes resources and fair use between users. There are mutlipe ways to interact wtih the scheduler and a full manual can be cound here: http://gridscheduler.sourceforge.net/htmlman/manuals.html.  Below are some of the most common.  More advanced techniques can be discussed later (ex. job arrays).

## qsub
Submits batch/non-interactive jobs to the scheduler. This can be done in (atleast) three seperate ways:

1) submit from a sge script

```
qsub code/hello_world.sge.sh
```

2) submit from shell script
```
qsub -N -P ... code/hello_world.sh
```

3) submit from cmd line
```
echo "echo hello world from the command line" | qsub -N -P ... 
```

## qrsh/qlogin
Use `qrsh` or `qlogin` when you need to run interactive jobs

```
qlogin
``` 
works but 
```
qlogin -pe smp 12 -N i_hello_world -q high_mem.q
```
is better

## qstat
To see what is running 
```
qstat -g c
```
```
qstat -u \*
```

## qdel
To delete running jobs


## qhold
to pause queued jobs




## Other
`qalter`

`-job_hold_id`
blank
