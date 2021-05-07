# SGE submission tutorial
7 May 2021


The Sun Grid Engine (SGE) scheduler is used to run jobs in a semi-organized way that maximizes resources and fair use between users. There are multiple ways to interact with the scheduler and a full manual can be found here: [http://gridscheduler.sourceforge.net/htmlman/manuals.html](http://gridscheduler.sourceforge.net/htmlman/manuals.html).  Below are some of the most common.  More advanced techniques can be discussed later (ex. job arrays).

## Submitting jobs
### `qsub`: Run batch jobs
Submits batch/non-interactive jobs to the scheduler. This can be done in (at least) three separate
1) Submit from a SGE script

```
[nplatt@zeus sge_tutorial]$ qsub code/hello_world.sge.sh
```

If you look at the top of the `hello_world.sge.sh` script you will see a header that contains options/parameters that the SGE scheduler uses for setting up and running the script.  For more options check out the manual linked above, but some of the most commons options are listed below:

```
# -cwd              run script in current working directory
# -v                exports all environment variables
# -S <..>           shell used for the job
# -j y              merge stderr and stdout to the same file (-o)
# -N <job_id>       sets the name used for the job
# -o <outfile>      output file for stderr (and stdout if -j y)
# -q <queue>        direct the job to this queue (high_mem.q, all.q)
# -pe <env> <#t>    parallel environment (almost always 'smp') and num threads

<some bash code>
```

Often times, it is helpful to add `sge` or some other designator to the file extension to differentiate between pure `bash` scripts and those meant to be sent to the scheduler.  

Ex. `hello_world.sh` vs. `hello_world.sge.sh`

2) Submit from shell script

Alternatively you can enter the same options from the SGE header in `code/hello_world.sh` directly on the command line and for go the SGE header.
```
[nplatt@zeus sge_tutorial]$ qsub -V -cwd -S /bin/bash -q all.q -j y -p -1023 -pe smp 1 -N hello_cl -o hello_cl.log code/hello_world.sh
```
While this option is sometimes convenient, it is less robust/reproducible than including these options directly in the header.

3) Submit code directly from the command line.
Often times, it is useful to submit batch jobs from within another script.  Ex. You write a script that is going to use the scatter/gather method to spawn a bunch of smaller jobs, then merge them again after they have completed.  IN this case, you can submit raw `bash` to the scheduler directly from the command line.  For example, the code below submits the same job 100x.

```
for i in $(seq 1 100); do

    CMD="echo "Hello world from hello_world.sge.sh on "`hostname`"
    
    echo "$CMD"  | qsub -V -cwd -S /bin/bash -q all.q -j y -p -1023 -pe smp 1 -N hello_cl -o hello_cl.log
    
done

```


### `qrsh` or `qlogin`: Run interactive jobs
Use `qrsh` or `qlogin` when you need to run interactive jobs.

The easiest way to do this is:

```
[nplatt@zeus sge_tutorial]$ qlogin
``` 
However, it is HIGHLY RECOMMENDED to populate the request with the appropriate SGE parameters.  This looks much like submitting to a batch job from above.  It is not often that you will need more than the `-q`, `-pe`, and `-N` options.
```
[nplatt@zeus sge_tutorial]$ qlogin -q interactive.q -pe smp 1 -N hello_qlogin
```

*SIDENOTE-1* - I honestly don't understand the functional difference between `qlogin` and `qrsh`.

*SIDENOTE-2* - I rely heavily on `tmux` to be able to log out and in of interactive sessions.


### `qstat`: Checking job status

To check and see what you have running (or queued) use `qstat`
```
[nplatt@zeus sge_tutorial]$  qstat
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
 109153 0.00661 scan_genot nplatt       r     05/06/2021 13:10:29 all.q@compute-1-1536.local         3        
 109154 0.00661 scan_genot nplatt       r     05/06/2021 13:10:29 all.q@compute-1-1536.local         3        
 109164 0.00661 scan_genot nplatt       r     05/06/2021 13:11:14 all.q@compute-1-1420.local         3        
 109165 0.00661 scan_genot nplatt       r     05/06/2021 13:15:44 all.q@compute-1-1564.local         3        
 109166 0.00661 scan_genot nplatt       r     05/06/2021 13:16:44 all.q@compute-1-1338.local         3        
```

There may be instances where you want to see resources are available (or which queue to submit to).  In this case you can use a modified qstat output to check queue availability.
```
[nplatt@zeus sge_tutorial]$ qstat -g c
CLUSTER QUEUE                   CQLOAD   USED    RES  AVAIL  TOTAL aoACDS  cdsuE  
--------------------------------------------------------------------------------
all.q                             0.15   2844      0    528   3612      0    240 
high_mem.q                        0.01    372      0      0    384      0    192 
interactive.q                     0.02     32      0     88    132      0     12 
```
You can even see what other people are running
```
[nplatt@zeus sge_tutorial]$ qstat -u \* | head -n 15
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
  69013 0.50500 notebook   fcheval      r     04/05/2021 21:58:21 interactive.q@compute-1-1685.l     1        
  90842 0.50500 QRLOGIN    fcheval      r     04/20/2021 16:54:41 interactive.q@compute-1-1687.l     1        
  91200 0.51003 snakejob.c fcheval      r     04/26/2021 16:49:07 interactive.q@compute-1-1688.l    10        
  91391 0.51003 snakejob.c fcheval      r     04/30/2021 06:18:26 interactive.q@compute-1-1680.l    10        
  95384 0.60500 msgCluster fcheval      r     04/30/2021 23:47:13 high_mem.q@compute-1-1722.loca   180        
  95385 0.60500 msgCluster fcheval      r     05/01/2021 15:53:43 high_mem.q@compute-1-1723.loca   180        
 103386 0.51003 run_descol fwu          r     05/05/2021 10:48:59 interactive.q@compute-1-1686.l    10        
 109153 0.00661 scan_genot nplatt       r     05/06/2021 13:10:29 all.q@compute-1-1536.local         3        
 109154 0.00661 scan_genot nplatt       r     05/06/2021 13:10:29 all.q@compute-1-1536.local         3        
 109164 0.00661 scan_genot nplatt       r     05/06/2021 13:11:14 all.q@compute-1-1420.local         3        
 109165 0.00661 scan_genot nplatt       r     05/06/2021 13:15:44 all.q@compute-1-1564.local         3        
 109166 0.00661 scan_genot nplatt       r     05/06/2021 13:16:44 all.q@compute-1-1338.local         3        
```

## `qdel`: Delete running jobs
If you want to delete a running job it is as simple as
```
[nplatt@zeus sge_tutorial]$ qdel <job-ID>
```

## `qhold`: Pause queued jobs
In some cases, you may submit a bunch of jobs and need to keep them from running. Ex. maybe you are letting someone else move their jobs up higher in the queue.  To do this use:

```
[nplatt@zeus sge_tutorial]$ qhold <job-ID>
```

For example.  I want to place a hold on job 115279 that is sitting in the queue
```
[nplatt@zeus sge_tutorial]$ qstat
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
 115279 0.01163 nigeria_gd nplatt       qw    05/06/2021 16:15:11                                   12        

[nplatt@zeus sge_tutorial]$ qhold 115279
modified hold of job 115279
```
You can see that the job state has changed from `qw` to `hqw`.
```
[nplatt@zeus sge_tutorial]$ qstat
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
 115279 0.01163 nigeria_gd nplatt       hqw   05/06/2021 16:15:11                                   12        
```

To "release" the jobs use 'qrls`

```
[nplatt@zeus sge_tutorial]$ qrls 115279
modified hold of job 115279

[nplatt@zeus sge_tutorial]$ qstat
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
 115281 0.01163 nigeria_gd nplatt       qw    05/06/2021 16:15:11                                   12        
```

And you can see above that now the jobs is back in the `qw` state. 


## `qalter`: alter some of the SGE parameters of running or queued jobs

Ex: I decide that one of my scheduled jobs needs more processors/threads.  I want to increase it from 3 to 12 without resubmitting.

```
(base) [nplatt@zeus sge_tutorial]$ qstat 
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------     
 116324 0.00000 nigeria_ge nplatt       hqw   05/06/2021 16:15:31                                    3        
```

I can use `qalter` to modify the request
```
(base) [nplatt@zeus sge_tutorial]$ qalter 116324 -pe smp 12
modified parallel environment of job 116324
modified slot range of job 116324

(base) [nplatt@zeus sge_tutorial]$ qstat 
 job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------
 116324 0.00000 nigeria_ge nplatt       hqw   05/06/2021 16:15:31                                   12        
```

## `-hold_jid`: Set job dependency chain. 

Ex.  I want to submit two jobs (jobA and jobB), but jobB needs output from jobA to run.  You can use the `-job_hold_id` to build a dependency chain between the two jobs and tell the scheduler, that "jobB can't run untill jobA is completed".  It will look something like this.

```
(base) [nplatt@zeus sge_tutorial]$ qsub -V -cwd -S /bin/bash -q all.q -j y -pe smp 1 -N jobA -o jobA.log code/jobA.sh
Your job 116338 ("jobA") has been submitted

(base) [nplatt@zeus sge_tutorial]$ qsub -V -cwd -S /bin/bash -q all.q -j y -pe smp 1 -N jobB -o jobB.log  -hold_jid jobA code/jobB.sh
Your job 116339 ("jobB") has been submitted

[nplatt@zeus sge_tutorial]$ qstat | grep job
job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID 
-----------------------------------------------------------------------------------------------------------------     
 116338 0.00000 jobA       nplatt       qw    05/07/2021 10:01:45                                    1        
 116339 0.00000 jobB       nplatt       hqw   05/07/2021 10:01:45                                    1    
```
Keep in mind...this is an SGE parameter and not a command.


