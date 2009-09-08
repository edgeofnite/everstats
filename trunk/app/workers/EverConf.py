#EVERSTATS_DB = "everstatsdb"
EVERSTATS_DB = "planetstatsdb"
EVERSTATS_USER = "everstats"
EVERSTATS_DBHOST = "127.0.0.1"
SLICESTAT_PASS = "password"

LOGFILE = "EverLog.log"
#LOGFILE = ""

EVERSTATS_SITE = ""
SLICESTAT_PATH = "/slicestat"
SLICESTAT_PORT = 3100
DAYS_KEEP_SAMP = 0
DEFAULT_TIMEOUT = 30

UPDATE_NODE_LOOP_TIME = 60*60 #loop time for Update
GET_NODE_LOOP_TIME = 0 #loop time for Get


MAX_THREADS = 100 # max allowed threads for I/O while node collection

SLICESTAT_SLICE_NAME_INDEX = 0 #Slice name 
SLICESTAT_CPU_INDEX = 2 #CPU consumption(%) 
SLICESTAT_SEND_BW_INDEX = 8 #Average sending bandwidth for last 5 min(in Kbps)
SLICESTAT_RECV_BW_INDEX = 11 #Average receiving bandwidth for last 5 min(in Kbps) 
SLICESTAT_PCTMEM_INDEX = 3 # Percent memory used 
SLICESTAT_PHYMEM_INDEX = 4 # Physical memory used
SLICESTAT_VIRMEM_INDEX = 5 # Virtual memory used
SLICESTAT_PROCS_INDEX = 6 # Allocated Processes
SLICESTAT_RUNPROCS_INDEX = 14 # Running Processes 

SLICESTAT_MAX_INDEX = 14 # last index that we care about

DEF_SLICE_GROUP_ID = 1 #Default value for the slice group
DAYS_TO_KEEP_SAMPLES_BACK = 2 #Default time to keep samples

MAX_QUERY_SIZE = 1000 #max allowed size for 1 insert query into database (for too many lines the update will fail)

RETRY_DEAD_NODES_PERIOD = 60*60*6 # retry dead nodes every six hours (in seconds)

