class MainController < ApplicationController
  layout 'default'
  @page_title = "EverStats Monitoring System"
  def index
    @page_title = "EverStats Monitoring System"
    @count = "5"
    @days = "7"
    @dayusages = Dayusagesummary.find_by_sql("select 0 as id, slice_id as slice_id, sum(total_send_BW) as total_send_BW from dayusagesummaries where day > date_sub(now(), interval " + @days +" day) and slice_id != -1 group by slice_id order by sum(total_send_BW) desc limit " + @count)

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
