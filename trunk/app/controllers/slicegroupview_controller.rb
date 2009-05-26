class SlicegroupviewController < ApplicationController
  layout "default"
      def show
        @page_title = "Slice Activity by groups" 
        basic_query_str = "SELECT slicegroups.id as slicegroup_id,slicegroups.name as slicegroup_name ,count(distinct node_id) as total_nodes , SUM(total_activity_minutes) as total_activity_minutes, " +
                        "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                       "FROM dayusages,slices,slicegroups where dayusages.slice_id = slices.id and slices.slicegroup_id = slicegroups.id "
        past_week_query_str = basic_query_str + "and day > date_add(curdate(), interval -7 day) GROUP BY slices.slicegroup_id"
        past_month_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 month) GROUP BY slices.slicegroup_id"
        past_year_query_str = basic_query_str + "and day > date_add(curdate(), interval -1 year) GROUP BY slices.slicegroup_id"
    
        @past_week_usages = Sample.find_by_sql past_week_query_str
        @past_month_usages = Sample.find_by_sql past_month_query_str
        @past_year_usages = Sample.find_by_sql past_year_query_str
    
        
     #   slices = Slice.find(:all)
        @slicegroups = Slicegroup.find(:all)
        @slicegorup_id_to_group_map = {}
        @slicegroups.each{ |group| 
             @slicegorup_id_to_group_map[group.id] = group }

       
        #~ @slicegroup_id_to_slices_map = {}
         #~ slicegroups.each{ |group| 
            #~ @slicegroup_id_to_slices_map[group.id] = [] }

        #~ slices.each{ |slice| 
            #~ @slicegroup_id_to_slices_map[slice.slicegroup_id] = slice.id }
    end
end
