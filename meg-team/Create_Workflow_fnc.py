# -*- coding: utf-8 -*-
"""
Created on Mon Sep 14 14:09:44 2015

@author: bgauthie & laetitia grabot
"""
####################################################################
# This script generate jobs.py files and creates a somwf file
# containing the jobs to be send to the cluster with soma_workflow
# you can then launch and follow the processing with soma_workflow interface

####################################################################
# import libraries
from soma_workflow.client import Job, Workflow, Helper
import os
#os.chdir("/neurospin/meg/meg_tmp/tools_tmp/MEG_DEMO_SOMAWF")
cwd = os.path.dirname(os.path.abspath(__file__)) # where the scripts are
os.chdir(cwd)

from configuration import ( wdir )

#######################################################################
# List of parameters to parallelize
ListSubject  = ['pf120155','pe110338','cj100142','jm100042','jm100109','sb120316',
            'tk130502', 'sl130503', 'rl130571','bd120417','rb130313', 'mp140019']
                 
ListCondition = [['PSS_Vfirst', 'PSS_Afirst'],
                 ['JND1_Vfirst', 'JND1_Afirst'],
                 ['JND2_Vfirst', 'JND2_Afirst']]
                 
####################################################################       
# init jobs file content and names
List_python_files = []

initbody  = 'import sys \n'
initbody  = initbody + "sys.path.append(" + "'" + cwd + "')\n"
initbody  = initbody + 'import Compute_Epochs_fnc as CE\n'
initbody2 = 'import Plot_groupERF_fnc as ERF\n'

# write job files
# (basically a python script calling the function of interest with arguments of interest)
python_file, Listfile, ListJobName = [], [], []

for c,condcouple in enumerate(ListCondition):
    for s,subject in enumerate(ListSubject):
        
        body = initbody + "CE.Compute_Epochs_fnc('" + wdir + "',"   
        body = body + str(condcouple) +","
        body = body + "'" + subject + "')"
        
        # use a transparent and complete job name referring to arguments of interest    
        jobname = subject
        for cond in condcouple:
            jobname = jobname + '_' + cond 
        ListJobName.append(jobname)     
            
        # write jobs in a dedicated folder
        name_file = []
        name_file = os.path.join(wdir, ('somawf/jobs/Demo_' + jobname + '.py'))
        Listfile.append(name_file)
        with open(name_file, 'w') as python_file:
            python_file.write(body)
    
    # once all evoked are computed, for one condcouple, plot grand average
    body = (initbody2 + 'ERF.Plot_groupERF_fnc(' +
    str(condcouple) + ',' + str(ListSubject) + ')')
    
    jobname = condcouple[0] + '_' + condcouple[1] 
    ListJobName.append(jobname)
    
    name_file = []
    name_file = os.path.join(wdir, ('somawf/jobs/Demo_' + jobname + '.py'))
    Listfile.append(name_file)
    with open(name_file, 'w') as python_file:
        python_file.write(body)  
   
###############################################################################
# create workflow   
jobs = []
for i in range(len(Listfile)):
    JobVar = Job(command=['python', Listfile[i]], name = ListJobName[i],
                 native_specification = '-l walltime=4:00:00, -l nodes=1:ppn=2')
    jobs.append(JobVar)       

# define dependancies (tuples of two jobs)
# the second job will be executed after the first  
# here, plot the grand average after having written evoked for each subject
n = len(ListSubject)
dependencies =  [(jobs[c*n + s + c],jobs[(c + 1)*n + c])
                for s,subject in enumerate(ListSubject)
                for c,condcouple in enumerate(ListCondition)]   
                
# save the workflow into a file    
WfVar = Workflow(jobs=jobs, dependencies=dependencies)
somaWF_name = os.path.join(wdir, 'somawf/workflows/DEMO_WF')
Helper.serialize(somaWF_name, WfVar)

        




     
                 