class FixSliceAggregationDayusagesummaries < ActiveRecord::Migration
  def self.up
    # Drop all entries in the dayusagesummaries and re-insert
    sql = "delete from dayusagesummaries where node_id = -1"
    ActiveRecord::Base.connection.execute(sql)

    # now by slice
    sql2 = <<-SQL
       insert into dayusagesummaries (slice_id, node_id, day, nitems, total_activity_minutes, avg_cpu, avg_send_BW, avg_recv_BW, total_cpu, total_send_BW, total_recv_BW, max_cpu, max_send_BW, max_recv_BW, number_of_samples, avg_pctmem, max_pctmem, avg_phymem, max_phymem, avg_virmem, max_virmem, avg_procs, max_procs, avg_runprocs, max_runprocs)
          select slice_id, -1, day, 
              count(distinct node_id),
              avg(total_activity_minutes),
              avg(avg_cpu),
              avg(avg_send_BW)/1024,
              avg(avg_recv_BW)/1024,
              count(distinct node_id)*avg(total_activity_minutes)*avg(avg_cpu)/100/60 as total_cpu,
              60*avg(total_activity_minutes)*sum(avg_send_BW)/1024 as total_send_BW,
              60*avg(total_activity_minutes)*sum(avg_recv_BW)/1024 as total_recv_BW,
              max(max_cpu),
              max(max_send_BW)/1024,
              max(max_recv_BW)/1024,
              avg(number_of_samples),
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
  end

  def self.down
  end
end
