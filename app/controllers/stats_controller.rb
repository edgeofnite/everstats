class StatsController < ApplicationController
  layout "default"

    def nodeview
        @page_title = "Node Activity"
        basic_query_str = "SELECT node_id, count(distinct slice_id) as total_slices , SUM(total_activity_minutes) as total_activity_minutes, " +
                             "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                              "FROM dayusages "
        past_week_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -7 day) GROUP BY node_id"
        past_month_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 month) GROUP BY node_id"
        past_year_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 year) GROUP BY node_id"
        @past_week_node_usages = Dayusage.find_by_sql past_week_query_str
        @past_month_node_usages = Dayusage.find_by_sql past_month_query_str
        @past_year_node_usages = Dayusage.find_by_sql past_year_query_str
    end

    def sliceview
        @page_title = "Slice Activity"
        if(params["id"])
            @slices_display = Slicegroup.find(params["id"]).name + " Slice Group"
        else
            @slices_display = "all slices"
        end
        
        basic_query_str = "SELECT slice_id,count(distinct node_id) as total_nodes , SUM(total_activity_minutes) as total_activity_minutes, " +
                        "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                       "FROM dayusages,slices where dayusages.slice_id = slices.id "
        if params["id"] 
            past_week_query_str = basic_query_str + "and day > date_add(curdate(), interval -7 day) and slices.slicegroup_id=" + params["id"] + " GROUP BY slice_id"
            past_month_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 month) and slices.slicegroup_id=" + params["id"] + " GROUP BY slice_id"
            past_year_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 year) and slices.slicegroup_id=" + params["id"] + " GROUP BY slice_id"
        else
           past_week_query_str = basic_query_str + "and day > date_add(curdate(), interval -7 day) GROUP BY slice_id"
           past_month_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 month) GROUP BY slice_id"
           past_year_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 year) GROUP BY slice_id" 
          
        end
        @past_week_usages = Dayusage.find_by_sql past_week_query_str
        @past_month_usages = Dayusage.find_by_sql past_month_query_str
        @past_year_usages = Dayusage.find_by_sql past_year_query_str
    
    end

  def singlenodeview
    @node = Node.find(params["id"])
    @page_title = "Node Activity for %s" % @node.hostname
    basic_query_str = "SELECT slice_id , SUM(total_activity_minutes) as total_activity_minutes, " +
      "avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, " +
      "sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu, 60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update " +
      "FROM dayusages "
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
    basic_query_str = "SELECT node_id , SUM(total_activity_minutes) as total_activity_minutes, " +
      "avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, " +
      "sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu, 60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update " +
      "FROM dayusages "
    past_week_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -7 day) and slice_id=" + params["id"] + " GROUP BY node_id"
    past_month_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 month) and slice_id=" + params["id"] + " GROUP BY node_id"
    past_year_query_str = basic_query_str + "WHERE day > date_add(curdate(), interval -1 year) and slice_id=" + params["id"] + " GROUP BY node_id"

    @past_week_node_usages = Dayusage.find_by_sql past_week_query_str
    @past_month_node_usages  = Dayusage.find_by_sql past_month_query_str
    @past_year_node_usages = Dayusage.find_by_sql past_year_query_str
  end

end
