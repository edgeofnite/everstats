class CreateDayusagesummaries < ActiveRecord::Migration
  def self.up
    # this table summarizes the day usages data.
    # records either have a -1 in the slice_id field or the node_id field.
    # this means that the record is for all nodes or slices on that day. (respectively).
    # the nitems field records the number of slices or nodes included summarized in that record (respectively)
    # some fields from the dayusage records are removed since they are used to calculate averages
    # which we already have.
    create_table "dayusagesummaries", :force => true do |t|
      t.integer  "slice_id",               :default => 0,                     :null => false
      t.integer  "node_id",                :default => 0,                     :null => false
      t.date     "day",                                                       :null => false
      t.integer  "nitems",                :default => 0,                     :null => false
      t.integer  "total_activity_minutes", :default => 0,                     :null => false
      t.float    "avg_cpu",                :default => 0.0,                   :null => false
      t.float    "avg_send_BW",            :default => 0.0,                   :null => false
      t.float    "avg_recv_BW",            :default => 0.0,                   :null => false
      t.float    "total_cpu",              :default => 0.0,                   :null => false
      t.float    "total_send_BW",          :default => 0.0,                   :null => false
      t.float    "total_recv_BW",          :default => 0.0,                   :null => false
      t.float    "max_cpu",                :default => 0.0,                   :null => false
      t.float    "max_send_BW",            :default => 0.0,                   :null => false
      t.float    "max_recv_BW",            :default => 0.0,                   :null => false
      t.integer  "number_of_samples",      :default => 0,                     :null => false
      t.float    "avg_pctmem",             :default => 0.0
      t.float    "max_pctmem",             :default => 0.0
      t.float    "avg_phymem",             :default => 0.0
      t.integer  "max_phymem",             :default => 0
      t.float    "avg_virmem",             :default => 0.0
      t.integer  "max_virmem",             :default => 0
      t.float    "avg_procs",              :default => 0.0
      t.integer  "max_procs",              :default => 0
      t.float    "avg_runprocs",           :default => 0.0
      t.integer  "max_runprocs",           :default => 0
    end

    add_index "dayusagesummaries", ["node_id", "slice_id"]
    add_index "dayusagesummaries", ["day"]

    sql = <<-SQL
       insert into dayusagesummaries (slice_id, node_id, day, nitems, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, avg_pctmem,  max_pctmem, avg_phymem, max_phymem, avg_virmem, max_virmem, avg_procs, max_procs, avg_runprocs, max_runprocs)
          select -1, node_id, day, 
              count(distinct slice_id),
              sum(total_activity_minutes),
              avg(avg_cpu),
              avg(avg_send_BW),
              avg(avg_recv_BW),
              sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,
              60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples) as total_send_BW,
              60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples) as total_recv_BW,
              max(max_cpu),
              max(max_send_BW),
              max(max_recv_BW),
              sum(number_of_samples),
              avg(avg_pctmem),
              max(max_pctmem),
              avg(avg_phymem),
              max(max_phymem),
              avg(avg_virmem),
              max(max_virmem),
              avg(avg_procs),
              max(max_procs),
              avg(avg_runprocs),
              max(max_runprocs)
           from dayusages where node_id != -1 and slice_id != -1 group by day, node_id 
    SQL
    ActiveRecord::Base.connection.execute(sql)
    
    # now by slice
    sql2 = <<-SQL
       insert into dayusagesummaries (slice_id, node_id, day, nitems, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, avg_pctmem, max_pctmem, avg_phymem, max_phymem, avg_virmem, max_virmem, avg_procs, max_procs, avg_runprocs, max_runprocs)
          select slice_id, -1, day, 
              count(distinct node_id),
              sum(total_activity_minutes),
              avg(avg_cpu),
              avg(avg_send_BW),
              avg(avg_recv_BW),
              sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,
              60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples) as total_send_BW,
              60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples) as total_recv_BW,
              max(max_cpu),
              max(max_send_BW),
              max(max_recv_BW),
              sum(number_of_samples),
              avg(avg_pctmem),
              max(max_pctmem),
              avg(avg_phymem),
              max(max_phymem),
              avg(avg_virmem),
              max(max_virmem),
              avg(avg_procs),
              max(max_procs),
              avg(avg_runprocs),
              max(max_runprocs)
           from dayusages where node_id != -1 and slice_id != -1 group by day, slice_id
    SQL
    ActiveRecord::Base.connection.execute(sql2)

    Slicegroup.create(:id => -1, :name => "Summary Slice Group for internal use only", :description => "Summary Slice Group for internal use only" )
    Slice.create(:id => -1, :name => "Summary Slice for internal use only", :slicegroup_id => -1)
    Node.create(:id => -1, :hostname => "Summary, for internal use only", :online => false)
  end

  def self.down
    Slicegroup.delete(-1)
    Slice.delete(-1)
    Node.delete(-1)
    drop_table :dayusagesummaries
  end
end
