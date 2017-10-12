import spconst

# Mapping: a 'key' event into the corresponding tuple of 'value' pipeline with starting 'status'
event_pipeline_mapping = {
    spconst.EVENT_CDS_VARIABLE: ('republication', spconst.PPPRUN_STATUS_WAITING)
}

# Maybe IPSL_DATASET may be done while IPSL_VARIABLE is running to trigger CDF_VARIABLE in parallel...

# Mapping: when a 'key' pipeline has ended, start the corresponding 'value' pipeline
# This means to change the status of the 'value' pipeline from 'pause' to 'waiting'
# when the 'key' pipeline reach the 'done' status
trigger = {}
