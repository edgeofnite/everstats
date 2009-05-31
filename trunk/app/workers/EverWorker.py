#!/usr/bin/python
import pdb
import EverDB
import EverConf
import time
import socket
import sys
import httplib
import re
import xmlrpclib
from threading import Thread

EVERSTATS_SITE = EverConf.EVERSTATS_SITE
SLICESTAT_PATH = EverConf.SLICESTAT_PATH
SLICESTAT_PORT = EverConf.SLICESTAT_PORT
DAYS_KEEP_SAMP = EverConf.DAYS_KEEP_SAMP
DEFAULT_TIMEOUT = EverConf.DEFAULT_TIMEOUT

#loop time for Update
UPDATE_NODE_LOOP_TIME = EverConf.UPDATE_NODE_LOOP_TIME
#loop time for Get
GET_NODE_LOOP_TIME = EverConf.GET_NODE_LOOP_TIME
MAX_THREADS = EverConf.MAX_THREADS

SLICESTAT_SLICE_NAME_INDEX = EverConf.SLICESTAT_SLICE_NAME_INDEX #Slice name 
SLICESTAT_CPU_INDEX = EverConf.SLICESTAT_CPU_INDEX #CPU consumption(%) 
SLICESTAT_SEND_BW_INDEX = EverConf.SLICESTAT_SEND_BW_INDEX #Average sending bandwidth for last 5 min(in Kbps)
SLICESTAT_RECV_BW_INDEX = EverConf.SLICESTAT_RECV_BW_INDEX #Average receiving bandwidth for last 5 min(in Kbps) 

NODES = []
NODES_DATA = {}

DB = EverDB.EverDB(EverConf.EVERSTATS_USER,EverConf.SLICESTAT_PASS,EverConf.EVERSTATS_DB)

class RequestNode(Thread):
	'''Handles singe Node collection thread'''
	
	def __init__ (self,host,path,port):
		'''Initializing the thread with the data about the connection'''
		Thread.__init__(self)
		self.host = host
		self.path = path
		self.port = port

	def run(self):
		'''Connects with http to the node and polling the data'''
		global NODES_DATA
		try:
			data = http_request(self.host,self.path,self.port)
			#in case we managed to get the data we send it to parsing.
			NODES_DATA[self.host] = self.parseSample(data)
		except:
			#in case of error we continue, there is nothing to do about it in that round.
			if NODES_DATA.has_key(self.host):
				del NODES_DATA[self.host]
			pass
				
	def parseSample(self, data):
		'''Parsing single node data'''
		res = []
		#splitting the data to lines, each line is a sample
		tokens = data.split("\n")
		for i in range(len(tokens)):
			#splitting the lines to ','-tokens, each token is a data about a sample, we only care about few of them.
			sub_tokens = tokens[i].split(",")
			if (len(sub_tokens) > max(SLICESTAT_SLICE_NAME_INDEX,SLICESTAT_CPU_INDEX,SLICESTAT_SEND_BW_INDEX,SLICESTAT_RECV_BW_INDEX)):
				sub_res = []
				sub_res.append(sub_tokens[SLICESTAT_SLICE_NAME_INDEX])
				sub_res.append(sub_tokens[SLICESTAT_CPU_INDEX])
				sub_res.append(sub_tokens[SLICESTAT_SEND_BW_INDEX])
				sub_res.append(sub_tokens[SLICESTAT_RECV_BW_INDEX])
			res.append(sub_res)
		return res

class NSLookup(Thread):
	'''Handles gethostbyname method'''
	
	def __init__ (self,host):
		'''saves the ip of the host'''
		Thread.__init__(self)
		self.host = host
		
	def run(self):
		'''gets the name, or gives a default one in case of error'''
		try:
			#get the name of the host
			self.ip = socket.gethostbyname(self.host)
		except:
			self.ip = "unknown"

def http_request (host, path, port):
	'''http connect for host path and port'''
	conn = httplib.HTTPConnection(host,port)
	conn.request("GET", path)
	response = conn.getresponse()
	conn.close()
	return response.read()

def https_request (host, path):
	'''https connect for host and path'''
	conn = httplib.HTTPSConnection(host)
	conn.request("GET", path)
	response = conn.getresponse()
	conn.close()
	return response.read()

	
def update_nodes():
	'''Updates the nodes from the pre-configured site'''
	global NODES
	try:
		auth = {'AuthMethod' : 'anonymous'}
		api_server = xmlrpclib.ServerProxy('https://' + EVERSTATS_SITE + '/PLCAPI/', allow_none=True)
		nodes = api_server.GetNodes(auth,{'peer_id': None},['hostname'])
		NODES = [x['hostname'] for x in nodes]
		parse_nodes_data()
	except:
		#some error occured while connecting to the site, nothing to do.
		PrintMe(logFile,  "Can't update nodes")
		res = ""

def parse_nodes_data():
	'''Parses nodes data, retrieving all the ip addresses of the nodes'''
	global NODES
	newDataNodes = []
	max_id = DB.GetMaxIDNodes()

	#filtering out the nodes we already have in the db
	curOff = 0
	#splitting all the offsets to chunks of threads, running chunk after chunk
	while (curOff < len(NODES)):
		thread_list = []
		curLen = min(curOff+MAX_THREADS,len(NODES))

		for node in NODES[curOff:curLen]:
			current = NSLookup(node)
			thread_list.append(current)
			current.start();

		#wait for all threads to finish
		for thr in thread_list:
			thr.join()
			if not Origin_Nodes.has_key(thr.host):
				newDataNodes.append((max_id, thr.host, thr.ip, 0))
				PrintMe(logFile, "\tInserting new Node : %s" % thr.host)
				Origin_Nodes[thr.host] = (max_id, thr.ip, 0)
				max_id = max_id+1
		
		curOff = curOff+MAX_THREADS
		
	#if there are nodes needed to be inserted into the db.
	if (len(newDataNodes) > 0) :
		DB.AddNewNodes(tuple(newDataNodes))
		
def get_nodes(ReCheckDeadNodes = 1):
	'''returns the nodes, parsed. using threads.'''
	curOff = 0
	#splitting all the offsets to chunks of threads, running chunk after chunk
	while (curOff < len(NODES)):
		thread_list = []
		curLen = min(curOff+MAX_THREADS,len(NODES))
		PrintMe(logFile, "\tWorking on :"+str(curOff)+"-"+str(curLen))
		for node in NODES[curOff:curLen]:
			if Origin_Nodes[node][2] == 1 or ReCheckDeadNodes:
				current = RequestNode(node, SLICESTAT_PATH, SLICESTAT_PORT)
				thread_list.append(current)
				current.start();
		
		#wait for all threads to finish
		for thr in thread_list:
			thr.join()
		
		curOff = curOff+MAX_THREADS
	

def insert_nodes():
	'''insert the new nodes, slices and samples into the db.'''
	global NODES_DATA

	#going over all the nodes and updating the online column
	for node in Origin_Nodes:
		DB.UpdateOnlineNode(node ,node in NODES_DATA)
		Origin_Nodes[node] = (Origin_Nodes[node][0], Origin_Nodes[node][1], node in NODES_DATA)

	#first we check that we have all the slices in the slices table
	max_id = DB.GetMaxIDSlices()
	newDataSlices = []	
	for node in NODES_DATA:
		for slice in NODES_DATA[node]:
			#We don't have the slice id in the db, we need to add it
			if not (Origin_Slices.has_key(slice[0])):
				PrintMe(logFile, "\tWarning: Encountered new Slice %s, adding it to DB" % (slice[0]))
				newDataSlices.append((max_id, slice[0],EverConf.DEF_SLICE_GROUP_ID))
				Origin_Slices[slice[0]] = max_id
				max_id = max_id+1
	#if we have new slices to insert into the db.
	if (len(newDataSlices) > 0) :
		DB.AddNewSlices(tuple(newDataSlices))

	
	# we go over the samples adding them, getting the node_id from pre-made table
	newDataSamples  = []
	max_id = DB.GetMaxIDSamples()
	max_dayUsage_id = int(DB.GetMaxIDDayUsages())
	lt = time.localtime()
	#making the daytime as it should be inserted into the db.
	dayTime = "%s-%s-%s %s:%s:%s"%(lt[0],lt[1],lt[2],lt[3],lt[4],lt[5])
	day = "%s-%s-%s" %(lt[0],lt[1],lt[2])
	existingDayUsages = DB.GetAllDayUsages(day)
	for node in NODES_DATA:
		node_id = Origin_Nodes[node][0]
		for slice in NODES_DATA[node]:
			slice_id = Origin_Slices[slice[0]]
			newDataSamples.append((max_id, slice_id, node_id, dayTime, slice[1], slice[2], slice[3], GET_NODE_LOOP_TIME))
			max_id = max_id + 1
			max_dayUsage_id = update_day_usage(max_dayUsage_id, node_id, slice_id, existingDayUsages[node_id][slice_id], slice, day, dayTime);
	if (len(newDataSamples) > 0):
		DB.AddNewSamples(tuple(newDataSamples))

def update_day_usage(max_dayUsage_id, node_id, slice_id, record, slicedata, day, dayTime):
	'''Given a node and new slice data, retrieve the day usage and update it
	as necessary.
	    if exists:
	           add to totals, number_of_samples(+1)
		          update max values and avgs
			         update last_update = starting_daytime
				     else:
				     insert
	    returns the max_dayUsage_id (incremented if necessary)
	    '''
	if record == []:
		#id, slice_id, node_id, day, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update
		# total = avg = max because there is only one entry!
		cpu = float(slicedata[1])
		send_BW = float(slicedata[2])
		recv_BW = float(slicedata[3])
		DB.AddNewDayUsage(max_dayUsage_id, slice_id, node_id, day, GET_NODE_LOOP_TIME/60, cpu, send_BW, recv_BW, cpu, send_BW, recv_BW, cpu, send_BW, recv_BW, 1, dayTime)
		max_dayUsage_id = max_dayUsage_id+1
	else:
		# we have a record with the current data.  let's update the fields
		# by name (for readability)
		#id, slice_id, node_id, day, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update
		record_id = record[0]
		day = record[3]
		total_activity_minutes = record[4] + (GET_NODE_LOOP_TIME/60)
		# Warning: total_cpu is a sum of percentages and not a value
		# its only use is to calculate the running average!!!
		total_cpu = record[8] + float(slicedata[1])
		total_send_BW = record[9] + float(slicedata[2])
		total_recv_BW = record[10] + float(slicedata[3])
		if record[11] < float(slicedata[1]):
			max_cpu = float(slicedata[1])
		else:
			max_cpu = record[11]
		if record[12] < float(slicedata[2]):
			max_send_BW = float(slicedata[2])
		else:
			max_send_BW = record[12]
		if record[13] < float(slicedata[3]):
			max_recv_BW = float(slicedata[3])
		else:
			max_recv_BW = record[13]
		number_of_samples = record[14] + 1
		avg_cpu = total_cpu / number_of_samples
		avg_send_BW = total_send_BW / number_of_samples
		avg_recv_BW = total_recv_BW / number_of_samples
		last_update = dayTime
		DB.UpdateDayUsage(record_id, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update)
	return max_dayUsage_id
			

def clean():
	'''Cleans old samples from the db''' 
	lt = time.localtime(time.time() - EverConf.DAYS_TO_KEEP_SAMPLES_BACK*24*60*60)
	last_date = "%s-%s-%s %s:%s:%s"%(lt[0],lt[1],lt[2],lt[3],lt[4],lt[5])
	DB.CleanSamples(last_date)

def Run():
	'''Method that runs the collection/insertion/update process forever'''
	global NODES
	global NODES_DATA
	
	next_retry_dead_nodes = 0
	while (True):
		
		#getting the nodes from the nodes publishing site
		NODES = []
		PrintMe(logFile,  "Start  Update nodes at: "+time.asctime())
		update_nodes_time = time.time()
		update_nodes()
		PrintMe(logFile, "Finish Update nodes at: "+time.asctime())
		PrintMe(logFile, "Found total "+str(len(NODES))+" nodes.")
		if (len(NODES) == 0):
			PrintMe(logFile, "\tSleeping for "+str(GET_NODE_LOOP_TIME))
			if (logFile != None):
				logFile.flush()	
			time.sleep(GET_NODE_LOOP_TIME)
			continue
	
		while (time.time() < update_nodes_time + UPDATE_NODE_LOOP_TIME):
			#getting the nodes data and update the right tables in the db.
			NODES_DATA = {}
			
			PrintMe(logFile, "\t\tStart  Getting nodes at: "+time.asctime())
			get_nodes_time = time.time()
			if get_nodes_time > next_retry_dead_nodes:
				get_nodes(1)
			else:
				get_nodes(0)
			PrintMe(logFile, "\t\tget_nodes, done: "+time.asctime())
			insert_nodes()
			PrintMe(logFile, "\t\tinsert_nodes, done:" +time.asctime())
			if get_nodes_time > next_retry_dead_nodes:
				# Only clean the DB once every few hours
				clean()
			PrintMe(logFile, "\tFinish Getting nodes at: "+time.asctime())
			PrintMe(logFile, "\tFound total "+str(len(NODES_DATA))+" active nodes.")
			PrintMe(logFile, "\tSleeping for "+str(max(get_nodes_time+GET_NODE_LOOP_TIME-time.time(),0)))
			PrintMe(logFile, "\t-------")
			time.sleep(max(get_nodes_time+GET_NODE_LOOP_TIME-time.time(),0))
			if get_nodes_time > next_retry_dead_nodes:
				next_retry_dead_nodes = get_nodes_time + EverConf.RETRY_DEAD_NODES_PERIOD


def PrintMe(logFile, data):
	'''Simple print me method.'''
	print >> logFile, data
	if (logFile != None):
		logFile.flush()			
	
if __name__ == "__main__":
	'''Load basic configurations and run the program'''
	Conf = DB.LoadConfigurations()
	Origin_Nodes = DB.LoadNodes()
	Origin_Slices = DB.LoadSlices()

	EVERSTATS_SITE = Conf["nodes_file_comp"]
	DAYS_KEEP_SAMP = int(Conf["days_to_keep_samples"])
	GET_NODE_LOOP_TIME = int(Conf["samples_interval"])

	logFile = None
	if (EverConf.LOGFILE != "")	:
		logFile = open(EverConf.LOGFILE,'w')
	
	#setting the timeout for all http requests
	httplib.socket.setdefaulttimeout(DEFAULT_TIMEOUT)


	s = """EVERSTATS_SITE:\t%s
SLICESTAT_PATH:\t%s
SLICESTAT_PORT:\t%s
UPDATE_NODE_LOOP_TIME:\t%s
GET_NODE_LOOP_TIME:\t%s
DEFAULT_TIMEOUT:\t%s
DAYS TO KEEP SAMPLES BACK:\t%s
-------""" % (EVERSTATS_SITE,SLICESTAT_PATH,SLICESTAT_PORT,UPDATE_NODE_LOOP_TIME,GET_NODE_LOOP_TIME,DEFAULT_TIMEOUT,EverConf.DAYS_TO_KEEP_SAMPLES_BACK)
	
	PrintMe(logFile,s)
	Run()
	
	
