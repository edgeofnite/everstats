class DaterangeviewController < ApplicationController
    layout "default"
    def index
        @page_title = "Advanced Search"
        @slicegroups = Slicegroup.find_by_sql("select * from slicegroups order by name")
        @slices = Slice.find_by_sql("select * from slices order by name")
        @nodes = Node.find_by_sql("select * from nodes order by hostname")
        @display =  ""
        if params["date_options"]
            
            @from_date_str = params["from_year_select"] + "-" +  params["from_month_select"] + "-" + params["from_day_select"]
            @to_date_str = params["to_year_select"] + "-" +  params["to_month_select"] + "-" + params["to_day_select"]
           
            
            if params["date_options"] == "slices"
            
                basic_query_str = "SELECT slice_id,count(distinct node_id) as total_nodes , SUM(total_activity_minutes) as total_activity_minutes, " +
                        "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                       "FROM dayusages,slices where dayusages.slice_id = slices.id " + " and dayusages.day >= '" + @from_date_str + "'" + 
                        " and dayusages.day <= '" + @to_date_str + "'" + " GROUP BY slice_id"
                @display = @display +  "<h4>Results: slices consumption from " + @from_date_str + " to " + @to_date_str + "</h4><br>"
                @display = @display + '<table border="1"><tr>
                              <td width="20%"><p align="center"><i><b>Slice</b></i></td>
                              <td width="16%"><p align="center"><i><b>#Nodes</b></i></td>
                              <td width="16%"><p align="center"><i><b>Total CPU Hours (on all nodes)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average CPU%</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Sending BW (in Kbps)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Receiving BW (in Kbps) </b></i></td>
                             </tr>'
               results = Dayusage.find_by_sql(basic_query_str)
               results.each{ |item| 
                    @display = @display + '<tr>' + 
                            '<td>' + item.slice.name + '</td>' +
                            '<td>' + item.total_nodes+ '</td>' +
                            '<td>' +  ("%.2f" %  (item.total_activity_minutes.to_f() * item.avg_cpu.to_f()/60.0/100.0).to_s) + '</td>' +
                           '<td>' + "%.2f" % item.avg_cpu + '</td>' +
                            '<td>' + "%.2f" % item.avg_send_BW + '</td>' +
                            '<td>' + "%.2f" % item.avg_recv_BW + '</td></tr>'}
                @display = @display + "</table>"
            
                
            end 
            if params["date_options"] == "nodes"
                
                basic_query_str = "SELECT node_id, count(distinct slice_id) as total_slices , SUM(total_activity_minutes) as total_activity_minutes, " +
                             "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                              "FROM dayusages " + " WHERE day >= '" + @from_date_str + "'" + 
                              " and day <= '" + @to_date_str + "'" + " GROUP BY node_id"
                @display = @display +  "<h4>Results: Node usage from " + @from_date_str + " to " + @to_date_str + "</h4><br>"
                @display = @display + '<table border="1"><tr>
                              <td width="20%"><p align="center"><i><b>Node</b></i></td>
                              <td width="16%"><p align="center"><i><b>#Slices</b></i></td>
                              <td width="16%"><p align="center"><i><b>Total CPU Hours (sum for all slices)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average CPU%</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Sending BW (in Kbps)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Receiving BW (in Kbps) </b></i></td>
                             </tr>'
                
            
                results = Dayusage.find_by_sql(basic_query_str)
                results.each{ |item| 
                    @display = @display + '<tr>' + 
                            '<td>' + item.node.hostname + '</td>' +
                            '<td>' + item.total_slices+ '</td>' +
                            '<td>' +  ("%.2f" %  (item.total_activity_minutes.to_f() * item.avg_cpu.to_f()/60.0/100.0).to_s) + '</td>' +
                           '<td>' + "%.2f" % item.avg_cpu + '</td>' +
                            '<td>' + "%.2f" % item.avg_send_BW + '</td>' +
                            '<td>' + "%.2f" % item.avg_recv_BW + '</td></tr>'}
                @display = @display + "</table>"
            
            end
             if params["date_options"] == "slicegroup"
                basic_query_str = "SELECT slice_id,count(distinct node_id) as total_nodes , SUM(total_activity_minutes) as total_activity_minutes, " +
                        "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                       "FROM dayusages,slices where dayusages.slice_id = slices.id " + " and dayusages.day >= '" + @from_date_str + "'" + 
                        " and dayusages.day <= '" + @to_date_str + "'" + " and slices.slicegroup_id= " + params["slicegroup_select"] +  " GROUP BY slice_id"
                @display = @display +  "<h4>Results: slices consumption from " + @from_date_str + " to " + @to_date_str +  " for slice group <i>" +
                                           Slicegroup.find(params["slicegroup_select"]).name + "</i></h4><br>"
                @display = @display + '<table border="1"><tr>
                              <td width="20%"><p align="center"><i><b>Slice</b></i></td>
                              <td width="16%"><p align="center"><i><b>#Nodes</b></i></td>
                              <td width="16%"><p align="center"><i><b>Total CPU Hours (on all nodes)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average CPU%</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Sending BW (in Kbps)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Receiving BW (in Kbps) </b></i></td>
                             </tr>'
               results = Dayusage.find_by_sql(basic_query_str)
               results.each{ |item| 
                    @display = @display + '<tr>' + 
                            '<td>' + item.slice.name + '</td>' +
                            '<td>' + item.total_nodes+ '</td>' +
                            '<td>' +  ("%.2f" %  (item.total_activity_minutes.to_f() * item.avg_cpu.to_f()/60.0/100.0).to_s) + '</td>' +
                           '<td>' + "%.2f" % item.avg_cpu + '</td>' +
                            '<td>' + "%.2f" % item.avg_send_BW + '</td>' +
                            '<td>' + "%.2f" % item.avg_recv_BW + '</td></tr>'}
                @display = @display + "</table>"
            end
            if params["date_options"] == "slice"
                    basic_query_str = "SELECT node_id , SUM(total_activity_minutes) as total_activity_minutes, " +
                        "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                       "FROM dayusages WHERE dayusages.day >= '" + @from_date_str + "'" + 
                        " and dayusages.day <= '" + @to_date_str + "'" + " and slice_id = " + params["slice_select"] + " GROUP BY node_id" 
                      @display = @display +  "<h4>Results: Slice consumption from " + @from_date_str + " to " + @to_date_str +  " for slice <i>" +
                                           Slice.find(params["slice_select"]).name + "</i></h4><br>"
                     results = Dayusage.find_by_sql(basic_query_str)
                     @display = @display + '<table border="1"><tr>
                              <td width="16%"><p align="center"><i><b>Node</b></i></td>
                              <td width="16%"><p align="center"><i><b>Total CPU Hours (on all nodes)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average CPU%</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Sending BW (in Kbps)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Receiving BW (in Kbps) </b></i></td>
                             </tr>'
                     results.each{ |item| 
                    @display = @display + '<tr>' + 
                            '<td>' + item.node.hostname + '</td>' +
                            '<td>' +  ("%.2f" %  (item.total_activity_minutes.to_f() * item.avg_cpu.to_f()/60.0/100.0).to_s) + '</td>' +
                           '<td>' + "%.2f" % item.avg_cpu + '</td>' +
                            '<td>' + "%.2f" % item.avg_send_BW + '</td>' +
                            '<td>' + "%.2f" % item.avg_recv_BW + '</td></tr>'}
                     @display = @display + "</table>"
                    
            end
            if params["date_options"] == "node"
                basic_query_str = "SELECT slice_id , SUM(total_activity_minutes) as total_activity_minutes, " +
                        "AVG(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW " +
                       "FROM dayusages WHERE dayusages.day >= '" + @from_date_str + "'" + 
                        " and dayusages.day <= '" + @to_date_str + "' and node_id=" + params["node_select"] + " GROUP BY slice_id"
                @display = @display +  "<h4>Results: node usage from " + @from_date_str + " to " + @to_date_str +  " for node <i>" +
                                Node.find(params["node_select"]).hostname + "</i></h4><br>"
                results = Dayusage.find_by_sql(basic_query_str)
                @display = @display + '<table border="1"><tr>
                              <td width="16%"><p align="center"><i><b>Slice</b></i></td>
                              <td width="16%"><p align="center"><i><b>Total CPU Hours (sum for all slices)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average CPU%</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Sending BW (in Kbps)</b></i></td>
                              <td width="16%"><p align="center"><i><b>Average Receiving BW (in Kbps) </b></i></td>
                             </tr>'
                              results.each{ |item| 
                     @display = @display + '<tr>' + 
                            '<td>' + item.slice.name + '</td>' +
                            '<td>' +  ("%.2f" %  (item.total_activity_minutes.to_f() * item.avg_cpu.to_f()/60.0/100.0).to_s) + '</td>' +
                           '<td>' + "%.2f" % item.avg_cpu + '</td>' +
                            '<td>' + "%.2f" % item.avg_send_BW + '</td>' +
                            '<td>' + "%.2f" % item.avg_recv_BW + '</td></tr>'}
                     @display = @display + "</table>"
                    
            end
        
        end
    end
end
