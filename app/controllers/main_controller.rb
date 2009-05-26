class MainController < ApplicationController
  layout 'default'
  @page_title = "EverStats Monitoring System"
  def index
    @page_title = "EverStats Monitoring System"
    @count = "5"
    @days = "7"
    @dayusages = Dayusage.find_by_sql("select 0 as id, slice_id, count(distinct node_id) as node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu, sum(total_send_BW) as total_send_BW, sum(total_recv_BW) as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by slice_id order by sum(total_send_BW) desc limit " + @count)

    title = Title.new("Top %s slices\nTotal Sending Bandwidth\nfor the past %s days" % [@count, @days])
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#label# - #val# Kb'
    vals = []
    @dayusages.each do |item|
      vals << PieValue.new(item.total_send_BW,item.slice.name)
    end
    pie.set_values(vals)
    @chart = OpenFlashChart.new
    @chart.set_title(title)
    @chart.add_element(pie)
  end

  def about_data
    @page_title = "EverStats Monitoring System: Data Collection"
  end
end
