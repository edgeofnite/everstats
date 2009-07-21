import MySQLdb
import EverConf
import time
import datetime

class Ddict(dict):
	def __init__(self, default=None):
		self.default = default

	def __getitem__(self,key):
		if not self.has_key(key):
			self[key] = self.default()
		return dict.__getitem__(self,key)


class EverDB:
	'''Class that allows easy access to EverStats DB'''

	def __init__(self,_user,_passwd,_db):
		'''Connects to the Database'''
		self.db=db = MySQLdb.connect(user=_user,passwd=_passwd,db=_db)
		self.c = self.db.cursor()

	def GetMaxID(self, table):
		'''Returns the MaxId for given table''' 
		self.c.execute("select max(id) from %s" % table)
		id =  self.c.fetchone()[0]
		if id == None : return 1
		return id+1

	def GetMaxIDSamples(self):
		'''Returns the maxID for Samples table'''
		return self.GetMaxID("samples")
	def GetMaxIDNodes(self):
		'''Returns the maxID for Nodes table'''
		return self.GetMaxID("nodes")
	def GetMaxIDSlices(self):
		'''Returns the maxID for Slices table'''
		return self.GetMaxID("slices")
	def GetMaxIDDayUsages(self):
		'''Returns the maxID for DayUsages table'''
		return self.GetMaxID("dayusages")

	def LoadConfigurations(self):
		'''Returns the basic configurations from the configurations table. The data returned in a dictionary'''
		self.c.execute("SELECT config_key, config_value FROM configurations")
		data={}
		for config_key, config_value in self.c:
			data[config_key] = config_value
		return data

	def LoadNodes(self):
		'''Returns the Nodes written to the DB in a dictionary using primayipaddress as the key'''
		self.c.execute("SELECT primaryipaddress, id, hostname, online FROM nodes")
		data={}
		for primaryipaddress, id, hostname, online in self.c:
			data[hostname] = (id, primaryipaddress, online)
		return data
		
	def LoadSlices(self):
		'''Returns the Slices written to the DB in a dictionary using name as the key'''
		self.c.execute("SELECT name, id FROM slices")
		data={}
		for name, id in self.c:
			data[name] = id
		return data

	def AddNewData(self, query, data):
		'''Adding new lines acorting to the given query into the db. handles multiple writting.'''
		curOff = 0
		MAX_LEN = EverConf.MAX_QUERY_SIZE
		while(curOff < len(data)):
			curLen = min(curOff+MAX_LEN,len(data))
			self.c.executemany(query, data[curOff:curLen])
			self.db.commit()
			curOff = curOff+MAX_LEN
		
	def AddNewSlices(self, slices):
		'''Adding new Slices to the DB.'''
		#id, name, slicegroup_id
		self.AddNewData("Insert into slices values(%s,%s,%s)", slices)

	def AddNewNodes(self, nodes):
		'''Adding new Nodes to the DB.'''
		#id, hostname, primaryipaddress, online
		self.AddNewData("Insert into nodes values(%s,%s,%s,%s)", nodes)
		
	def AddNewSamples(self, samples):
		'''Adding new Samples to the DB.'''
		#id, slice_id, node_id, dayAndTime, cpu, avgSendBW, avgRecvBW, sampleInterval, pctmem, phymem, virmem, procs, runprocs
		self.AddNewData("Insert into samples values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", samples)
			   
	def CleanSamples(self,last_date):
		'''Cleans old Samples from the DB.
		This is painfully slow.  To make it faster, we create a new
		table and copy from the old into the new.  its a few seconds
		versus a few minutes!  MYSQL 5.0.1 does not handle this kind
		of operation very well.'''
		#self.c.execute("DELETE FROM samples WHERE dayAndTime < %s",(last_date))
		self.c.execute("create table samples1 like samples")
		self.c.execute("insert into samples1 select * from samples WHERE dayAndTime > %s",(last_date))
		self.c.execute("drop table samples")
		self.c.execute("alter table samples1 rename samples")
	
	def UpdateOnlineNode(self, node, onlineStatus):
		'''Updating the online column for all the nodes.'''
		onlineValue = 0
		if onlineStatus:
			onlineValue = 1
		self.c.execute("UPDATE nodes SET online = %s WHERE hostname = %s", (onlineValue, node))

	def GetDayUsage(self, node_id, slice_id, day):
		'''Returns the day usage record if it exists.  Returns None if the
		record does not exist:  Fields returned are:
		0	id
		1	slice_id
		2	node_id
		3	day
		4	total_activity_minutes
		5	avg_cpu
		6	avg_send_BW
		7	avg_recv_BW
		8	total_cpu
		9	total_send_BW
		10	total_recv_BW
		11	max_cpu
		12	max_send_BW
		13	max_recv_BW
		14	number_of_samples
		15	last_update
		16	avg_pctmem
		17	total_pctmem
		18	max_pctmem
		19	avg_phymem
		20	total_phymem
		21	max_phymem
		22	avg_virmem
		23	total_virmem
		24	max_virmem
		25	avg_procs
		26	total_procs
		27	max_procs
		28	avg_runprocs
		29	total_runprocs
		30	max_runprocs
'''
		self.c.execute("SELECT * FROM dayusages where slice_id = %s and node_id = %s and day = '%s'"%(slice_id, node_id, day))
		record =  self.c.fetchone()
		return record

	def UpdateDayUsage(self, record_id, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update, avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs):
		'''Updating an existing dayusage record. id, node_id, slice_id and day are constants'''
		self.c.execute("UPDATE dayusages SET total_activity_minutes = %s, avg_cpu = %s, avg_send_BW = %s, avg_recv_BW = %s, total_cpu = %s, total_send_BW = %s, total_recv_BW = %s, max_cpu = %s, max_send_BW = %s, max_recv_BW = %s, number_of_samples = %s, last_update = '%s', avg_pctmem = '%s',total_pctmem = '%s',max_pctmem = '%s',avg_phymem = '%s',total_phymem = '%s',max_phymem = '%s',avg_virmem = '%s',total_virmem = '%s',max_virmem = '%s',avg_procs = '%s',total_procs = '%s',max_procs = '%s',avg_runprocs = '%s',total_runprocs = '%s',max_runprocs = '%s' WHERE id = %s" % (total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update, avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs,record_id))

	def AddNewDayUsage(self, record_id, slice_id, node_id, day, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update, avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs):
		self.AddNewData("Insert into dayusages  values (%s, %s,%s,%s,%s,%s,%s,%s,%s, %s, %s, %s, %s ,%s ,%s ,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", ((record_id, slice_id, node_id, day, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update, avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs,),))

	def GetAllDayUsages(self, day):
		self.c.execute("SELECT id, node_id, slice_id, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update, avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs from dayusages where day = '%s'" % day)
		data=Ddict(lambda: Ddict( list ))
		for id, node_id, slice_id, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update, avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs in self.c:
			data[node_id][slice_id] = [id, node_id, slice_id, day, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, last_update,avg_pctmem,total_pctmem,max_pctmem,avg_phymem,total_phymem,max_phymem,avg_virmem,total_virmem,max_virmem,avg_procs,total_procs,max_procs,avg_runprocs,total_runprocs,max_runprocs];
		return data
		
if __name__ == "__main__":
	'''Load basic configurations and run some tests'''
	DB = EverDB(EverConf.EVERSTATS_USER,EverConf.SLICESTAT_PASS,EverConf.EVERSTATS_DB)
	import pdb
	pdb.set_trace()
	existingDayUsages = DB.GetAllDayUsages("2009-04-26")
	print existingDayUsages[41][1]
