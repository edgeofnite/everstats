class OverallController < ApplicationController
  layout 'default'
  @page_title = "System-Wide Activity"

  def doLineChart(title, xlegend, ylegend, hashOfValues, tooltip, startDate, endDate)
    colors = ['#DFC329', '#6363AC', '#5E4725', "#459a89", "#9a89f9", "#666666"]

    title = Title.new(title)

    x_legend = XLegend.new(xlegend)
    x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new(ylegend)
    y_legend.set_style('{font-size: 20px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    maxx = 0
    maxy = 0
    index = 0
    hashOfValues.each do |label, values|
      line = ScatterLine.new(colors[index], 3)
      line.text = label
      line.width = 2
      line.tooltip = tooltip
      line.set_values(values)
      maxy = values.inject(maxy) {|max, val| (max < val.instance_values['y']) ? val.instance_values['y'] : max }
      maxx = values.inject(maxx) {|max, val| (max < val.instance_values['x']) ? val.instance_values['x'] : max }
      chart.add_element(line)
      index += 1
    end

    y = YAxis.new
    y.set_range(0,maxy,maxy/10)
    chart.y_axis = y

    xaxis = XAxis.new
    # grid line and tick every 10
    xaxis.set_range(0, maxx+1, (maxx+1)/10)
    xaxis.set_steps(86400)
    labels = []
    startDate.step(endDate, 86400) {|val|
      labels << XAxisLabel.new(Time.at(val).strftime("%b %d %Y"),'#000000', 11, 90)
    }
    xaxis.set_labels(labels)
    chart.set_x_axis(xaxis)

    return chart
  end

  def byday
    startDay = params[:start_date][:year] + '-' + params[:start_date][:month] + '-' + params[:start_date][:day]
    endDay = params[:end_date][:year] + '-' + params[:end_date][:month] + '-' + params[:end_date][:day]

    startDayCivil = Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
    endDayCivil = Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)
  
    startDayTime = Time.local(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
    endDayTime = Time.local(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)

    @nodes = Dayusagesummary.calculate(:count, :slice_id, :group => :day, :conditions => "slice_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")
    @slices = Dayusagesummary.calculate(:count, :node_id, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")
    @deployedslices = Dayusagesummary.calculate(:avg, :nitems, :group => :day, :conditions => "slice_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")

    @totalCPU = Dayusagesummary.calculate(:sum, :total_cpu, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")
    @avgCPU = Dayusagesummary.calculate(:avg, :avg_cpu, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")

    @avgSendBW = Dayusagesummary.calculate(:sum, :avg_send_BW, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")
    @avgRecvBW = Dayusagesummary.calculate(:sum, :avg_recv_BW, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")

    @totalSendBW = Dayusagesummary.calculate(:sum, :total_send_BW, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")
    @totalRecvBW = Dayusagesummary.calculate(:sum, :total_recv_BW, :group => :day, :conditions => "node_id = -1", :having => "day > '#{startDay}' and day < '#{endDay}'")

    @days = @nodes.keys

    resources = {}
    resources["nodes"] = []
    resources["unique slices"] = []
    resources["avg deployed slices"] = []
    totalcpu = {}
    totalcpu["Total CPU"] = []
    avgcpu = {}
    avgcpu["Total CPU"] = []
    avgbw = {}
    avgbw["Sending"] = []
    avgbw["Receiving"] = []
    totalbw = {}
    totalbw["Sending"] = []
    totalbw["Receiving"] = []

    @days.each do |day|
      resources["nodes"] << ScatterValue.new((day - startDayCivil), @nodes[day])
      resources["unique slices"] << ScatterValue.new((day - startDayCivil), @slices[day])
      resources["avg deployed slices"] << ScatterValue.new((day - startDayCivil), @deployedslices[day])
      totalcpu["Total CPU"] << ScatterValue.new((day - startDayCivil), @totalCPU[day])
      avgcpu["Total CPU"] << ScatterValue.new((day - startDayCivil), @avgCPU[day])
      avgbw["Sending"] << ScatterValue.new((day - startDayCivil), @avgSendBW[day])
      avgbw["Receiving"] << ScatterValue.new((day - startDayCivil), @avgRecvBW[day])
      totalbw["Sending"] << ScatterValue.new((day - startDayCivil), @totalSendBW[day])
      totalbw["Receiving"] << ScatterValue.new((day - startDayCivil), @totalRecvBW[day])
    end

    title = "Resources (Nodes and Slices) between %s and %s" % [startDayCivil, endDayCivil]
    @resourcechart = doLineChart(title, "day", "Resources", resources, "#y# on day #x#",startDayTime.tv_sec, endDayTime.tv_sec)

    title = "CPU Hours used between %s and %s" % [startDayCivil, endDayCivil]
    @cpuchart = doLineChart(title, "day", "CPU Usage (Hours)", totalcpu, "#y# CPU Hours on day #x#",startDayTime.tv_sec, endDayTime.tv_sec)
    
    title = "AVG CPU between %s and %s" % [startDayCivil, endDayCivil]
    @avgcpuchart = doLineChart(title, "day", "Avg % CPU", avgcpu, "#y# Avg % CPU on day #x#",startDayTime.tv_sec, endDayTime.tv_sec)

    title = "Average Network Bandwidth (KB)between %s and %s" % [startDayCivil, endDayCivil]
    @avgbwchart = doLineChart(title, "day", "Network Bandwidth (KB)", avgbw, "#y# KB on day #x#",startDayTime.tv_sec, endDayTime.tv_sec)
    
    title = "Total Network Bandwidth (KB) between %s and %s" % [startDayCivil, endDayCivil]
    @totalbwchart = doLineChart(title, "day", "Network Bandwidth (KB)", totalbw, "#y# KB on day #x#",startDayTime.tv_sec, endDayTime.tv_sec)

    @charts = [@resourcechart, @cpuchart, @avgcpuchart, @avgbwchart, @totalbwchart]
  end

end