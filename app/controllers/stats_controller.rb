class StatsController < ApplicationController
  layout "default"

    def nodeview
        @page_title = "Node Activity"

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
        avg(avg_virmem) as avg_virmem, max(max_virmem) as max_virmem
        from dayusagesummaries where slice_id = -1 and node_id != -1 '''

        past_week_query_str = basic_query_str + "and day > date_add(curdate(), interval -7 day) GROUP BY node_id"
        past_month_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 month) GROUP BY node_id"
        past_year_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 year) GROUP BY node_id"
        @past_week_node_usages = Dayusage.find_by_sql past_week_query_str
        @past_month_node_usages = Dayusage.find_by_sql past_month_query_str
        @past_year_node_usages = Dayusage.find_by_sql past_year_query_str

    
      respond_to do |format|
        format.xml  { render :xml => @past_year_node_usages }
        format.xls  do
          e = Excel::Workbook.new
          e.addWorksheetFromActiveRecord "past week", "Dayusagesummary", @past_week_node_usages
          e.addWorksheetFromActiveRecord "past month", "Dayusagesummary", @past_month_node_usages
          e.addWorksheetFromActiveRecord "past year", "Dayusagesummary", @past_year_node_usages
          nodes = Node.find(:all)
          e.addWorksheetFromActiveRecord "nodes", "Nodes", nodes
          headers['Content-Type'] = 'application/vnd.ms-excel'
          render :text => e.build
        end
        format.html
      end

    end

    def sliceview
        @page_title = "Slice Activity"
        if(params["id"])
            @slices_display = Slicegroup.find(params["id"]).name + " Slice Group"
        else
            @slices_display = "all slices"
        end
        
        basic_query_str = '''select 0 as id, -1 as node_id, curdate() as day, sum(number_of_samples) as number_of_samples, slice_id,
        avg(nitems) as nitems, sum(total_send_BW) as total_send_BW, 
	sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, sum(total_cpu) as total_cpu,
        sum(total_send_BW) as total_send_BW, sum(total_recv_BW) as total_recv_BW, 
        avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW,
        avg(avg_procs) as avg_procs, max(max_procs) as max_procs,
        avg(avg_runprocs) as avg_runprocs, max(max_runprocs) as max_runprocs,
        max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW,
        avg(avg_pctmem) as avg_pctmem, max(max_pctmem) as max_pctmem,
        avg(avg_phymem) as avg_phymem, max(max_phymem) as max_phymem,
        avg(avg_virmem) as avg_virmem, max(max_virmem) as max_virmem
        from dayusagesummaries,slices
        where node_id = -1 and slice_id != -1  and dayusagesummaries.slice_id = slices.id '''

        if params["id"] 
            past_week_query_str = basic_query_str + "and day > date_add(curdate(), interval -7 day) and slices.slicegroup_id=" + params["id"] + " GROUP BY slice_id"
            past_month_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 month) and slices.slicegroup_id=" + params["id"] + " GROUP BY slice_id"
            past_year_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 year) and slices.slicegroup_id=" + params["id"] + " GROUP BY slice_id"
        else
           past_week_query_str = basic_query_str + "and day > date_add(curdate(), interval -7 day) GROUP BY slice_id"
           past_month_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 month) GROUP BY slice_id"
           past_year_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 year) GROUP BY slice_id" 
          
        end
        @past_week_usages = Dayusagesummary.find_by_sql past_week_query_str
        @past_month_usages = Dayusagesummary.find_by_sql past_month_query_str
        @past_year_usages = Dayusagesummary.find_by_sql past_year_query_str
    
      respond_to do |format|
        format.xml  { render :xml => @past_year_usages }
        format.xls  do
          e = Excel::Workbook.new
          e.addWorksheetFromActiveRecord "past week", "Dayusagesummary", @past_week_usages
          e.addWorksheetFromActiveRecord "past month", "Dayusagesummary", @past_month_usages
          e.addWorksheetFromActiveRecord "past year", "Dayusagesummary", @past_year_usages
          slices = Slice.find(:all)
          e.addWorksheetFromActiveRecord "slices", "Slices", slices
          headers['Content-Type'] = 'application/vnd.ms-excel'
          render :text => e.build
        end
        format.html
      end

    end

  def singlenodeview
    @node = Node.find(params["id"])
    @page_title = "Node Activity for %s" % @node.hostname

    basic_query_str = '''SELECT slice_id,
      avg(avg_cpu) as avg_cpu, sum(avg_send_BW)/1024 as avg_send_BW, sum(avg_recv_BW)/1024 as avg_recv_BW,
      count(distinct node_id)*avg(total_activity_minutes)*avg(avg_cpu)/100/60 as total_cpu,
      60*avg(total_activity_minutes)*sum(avg_send_BW)/1024 as total_send_BW,
      60*avg(total_activity_minutes)*sum(avg_recv_BW)/1024 as total_recv_BW,
      max(max_cpu) as max_cpu, max(max_send_BW)/1024 as max_send_BW, max(max_recv_BW)/1024 as max_recv_BW,
      sum(number_of_samples) as number_of_samples, avg(avg_procs) as avg_procs, avg(avg_runprocs) as avg_runprocs
      FROM dayusages '''
    past_week_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -7 day) and node_id=" + params["id"] + " GROUP BY slice_id"
    past_month_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 month) and node_id=" + params["id"] + " GROUP BY slice_id"
    past_year_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 year) and node_id=" + params["id"] + " GROUP BY slice_id"

    @past_week_node_usages = Dayusage.find_by_sql past_week_query_str
    @past_month_node_usages  = Dayusage.find_by_sql past_month_query_str
    @past_year_node_usages = Dayusage.find_by_sql past_year_query_str
  end

  def singlesliceview
    @slice = Slice.find(params["id"])
    @page_title = "Slice Activity for %s" % @slice.name
    basic_query_str = '''SELECT node_id,
      avg(avg_cpu) as avg_cpu, avg(avg_send_BW)/1024 as avg_send_BW, avg(avg_recv_BW)/1024 as avg_recv_BW,
      avg(total_activity_minutes)*avg(avg_cpu)/100/60 as total_cpu,
      60*avg(total_activity_minutes)*sum(avg_send_BW)/1024 as total_send_BW,
      60*avg(total_activity_minutes)*sum(avg_recv_BW)/1024 as total_recv_BW,
      max(max_cpu) as max_cpu, max(max_send_BW)/1024 as max_send_BW, max(max_recv_BW)/1024 as max_recv_BW,
      sum(number_of_samples) as number_of_samples, avg(avg_procs) as avg_procs, avg(avg_runprocs) as avg_runprocs
      FROM dayusages '''

    past_week_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -7 day) and slice_id=" + params["id"] + " GROUP BY node_id"
    past_month_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 month) and slice_id=" + params["id"] + " GROUP BY node_id"
    past_year_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 year) and slice_id=" + params["id"] + " GROUP BY node_id"

    @past_week_node_usages = Dayusage.find_by_sql past_week_query_str
    @past_month_node_usages  = Dayusage.find_by_sql past_month_query_str
    @past_year_node_usages = Dayusage.find_by_sql past_year_query_str
  end

end
