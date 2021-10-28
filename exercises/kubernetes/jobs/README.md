# Jobs

Jobs are special kind of pods. A Job will make sure **that a job completed successfully, aka the pod will exit successfully**

## Parallelism

By default you can have different kind of setups:  

1. if you set `.spec.completions` to a number different than one, Kubernetes will make sure that a N jobs are completed successfully starting a new job as soon as the current one is finished
2. if you set `.spec.completions != 1` and `.spec.parallelism != 0` kubernetes not only will make sure that N jobs ran to completion, it will also execute them in parallel as specified
3. if you set `.spec.parallelism=0` you will effectively create the job and pause it. It will be up to the operatore do scale it: `kubectl scale  --replicas=$N jobs/myjob`

## Failing Jobs

If a Job fails, kubernetes will try to keep executing them. That might be a good thing if the job depends on an external service which is temporarily unavailable. But it could cause a serious overhead on your infrastructure. 

`activeDeadlineSeconds: 100` will effectively put a timeout on retries killing the job if the number of seconds is exceeded.
