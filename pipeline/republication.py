#!/usr/bin/env python

#import sppostprocessingutils
from sppipelineutils import build_pipeline

def get_pipeline():
    return ppp

# Pipeline name
name='republication'

# Transitions/tasks list
tasks=['migration', 'mapfile','publication']

#ppp = sppostprocessingutils.build_light_pipeline(name, tasks)
ppp = build_pipeline(name, tasks)
