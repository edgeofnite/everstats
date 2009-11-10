class GeoviewsController < ApplicationController
  layout 'default'
  @page_title = "Activity"

  # GET /geoviews/avgslices
  def avgslices
        basic_query_str = '''select 0 as id, -1 as slice_id, node_id, curdate() as day, sum(number_of_samples) as number_of_samples,
        avg(nitems) as nitems, SUM(total_activity_minutes) as total_activity_minutes, 
        sum(total_send_BW) as total_send_BW, sum(total_recv_BW) as total_recv_BW, 
        avg(avg_cpu) as avg_cpu, sum(total_cpu) as total_cpu,
        avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW,
        avg(avg_procs) as avg_procs, max(max_procs) as max_procs,
        avg(avg_runprocs) as avg_runprocs, max(max_runprocs) as max_runprocs,
        max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW,
        avg(avg_pctmem) as avg_pctmem, max(max_pctmem) as max_pctmem,
        avg(avg_phymem) as avg_phymem, max(max_phymem) as max_phymem,
        avg(avg_virmem) as avg_virmem, max(max_virmem) as max_virmem,
        from dayusagesummaries where slice_id = -1 and node_id != -1 group by node_id'''

        @avgslices = Dayusagesummary.find_by_sql basic_query_str
        @nodes = Node.find(:all)
  end
end
