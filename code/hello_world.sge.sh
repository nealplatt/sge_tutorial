#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -N submit_hw
#$ -o submit_hw.stdeo
#$ -j y
#$ -q all.q
#$ -pe smp 1

echo "Hello world from "`hostname`
	
