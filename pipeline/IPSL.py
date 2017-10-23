#!/usr/bin/env python
# -*- coding: ISO-8859-1 -*-

##################################
#  @program        synda
#  @description    climate models data transfer program
#  @copyright      Copyright (c)2009 Centre National de la Recherche Scientifique CNRS. All Rights Reserved€
#  @license        CeCILL (https://raw.githubusercontent.com/Prodiguer/synda/master/sdt/doc/LICENSE)
##################################

"""
Contains whole variable default pipeline definition.

"""

from sppipelineutils import build_pipeline


def get_pipeline():

    # Pipeline name
    name = 'IPSL'

    # Pipeline transitions
    # End "None" transition is mandatory
    transitions = ['suppression_variable',
                   'coalesce',
                   'time_axis_normalization',
                   'overlap',
                   'suppression_variable',
                   'copy',
                   'cdscan',
                   'latest',
                   'mapfile',
                   'publication',
                   None]

    # Pipeline initial state
    state = 100

    return build_pipeline(name, transitions, state)
