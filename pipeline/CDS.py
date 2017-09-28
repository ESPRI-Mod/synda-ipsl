#!/usr/bin/env python
# -*- coding: ISO-8859-1 -*-

##################################
#  @program        synda
#  @description    climate models data transfer program
#  @copyright      Copyright (c)2009 Centre National de la Recherche Scientifique CNRS. All Rights Reserved€
#  @license        CeCILL (https://raw.githubusercontent.com/Prodiguer/synda/master/sdt/doc/LICENSE)
##################################

"""
Contains whole CDS republication pipeline definition.

"""

from sppipelineutils import build_pipeline


def get_pipeline():

    # Pipeline name
    name = 'CDS'

    # Pipeline transitions
    # End "None" transition is mandatory
    transitions = ['mapfile',
                   'publication',
                   None]

    # Pipeline initial state
    state = 900

    return build_pipeline(name, transitions, state)
