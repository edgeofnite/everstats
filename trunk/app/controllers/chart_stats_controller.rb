class ChartStatsController < ApplicationController
  layout 'default'
  @page_title = "Graphs"

  protect_from_forgery :only => [:create, :update, :destroy]
  
  # Declare exception to handler methods
  rescue_from ActiveRecord::RecordNotFound, :with => :bad_record
  
  def bad_record
    flash[:notice] = 'No Records found, please select again.'
    redirect_to :controller=>"/chart_stats", :action =>"index"
  end

  def doPieChart(title, pieValues, tooltip)
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = tooltip
    pie.set_values(pieValues)
    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.add_element(pie)
    return chart
  end

  def doLineChart(title, xlegend, ylegend, hashOfValues)
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
      line.text = label.hostname
      line.width = 2
      line.set_values(values)
      maxy = values.inject(maxy) {|max, val| (max < val.instance_values['y']) ? val.instance_values['y'] : max }
      maxx = values.inject(maxx) {|max, val| (max < val.instance_values['x']) ? val.instance_values['x'] : max }
      chart.add_element(line)
      index += 1
    end

    y = YAxis.new
    y.set_range(0,maxy,maxy/10)
    chart.y_axis = y

    x_axis = XAxis.new
    x_axis.set_range(0,maxx+1, (maxx+1)/10)
    chart.x_axis = x_axis
    return chart
  end

  def index
    @page_title = "Graphs"
    @Nodes = Node.find(:all)
  end
  
  def charts
    nodes = []
    params.each do |par|
      if par[0].include? "node_"
        nodes.push(par[1].to_i())
      end
    end
    
    @dayusages = Dayusage.find(:all, :conditions => [ "node_id in (:nodes) and day >= :start and day <= :end", {:nodes => nodes, :start => params[:start_date][:year] + '-' + params[:start_date][:month] + '-' + params[:start_date][:day], :end => params[:end_date][:year] + '-' + params[:end_date][:month] + '-' + params[:end_date][:day]}], :order => 'day')
    
    if params[:chart] == 'pie' || params[:chart] == 'bar'
      # we need to aggregate the data for the charts
      cpu = {}
      maxcpu = 0
      sendBW = {}
      maxsendBW = 0
      recvBW = {}
      maxrecvBW = 0
      @dayusages.each do |item|
        if not cpu.has_key?(item.node.hostname)
          cpu[item.node.hostname] = 0
          sendBW[item.node.hostname] = 0
          recvBW[item.node.hostname] = 0
        end
        cpu[item.node.hostname] += item.total_activity_minutes*item.total_cpu/item.number_of_samples/100/60
        if maxcpu < cpu[item.node.hostname]
          maxcpu = cpu[item.node.hostname]
        end
        sendBW[item.node.hostname] += 60*item.total_activity_minutes*item.total_send_BW/item.number_of_samples/8
        if maxsendBW < sendBW[item.node.hostname]
          maxsendBW = sendBW[item.node.hostname]
        end
        recvBW[item.node.hostname] += 60*item.total_activity_minutes*item.total_recv_BW/item.number_of_samples/8
        if maxrecvBW < recvBW[item.node.hostname]
          maxrecvBW = recvBW[item.node.hostname]
        end
      end
    end

    if params[:chart] == 'pie'
      title = Title.new("CPU time between %s and %s" % [Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i), Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)])
      vals = []
      cpu.keys.each do |item|
        vals << PieValue.new(cpu[item],item)
      end
      @cpuchart = doPieChart(title, vals, '#label# - #val# CPU Hours')

      title = Title.new("Sending Bandwidth (KB) between %s and %s" % [Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i), Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)])
      vals = []
      sendBW.keys.each do |item|
        vals << PieValue.new(sendBW[item],item)
      end
      @sendbwchart = doPieChart(title, vals, '#label# - #val# KB')

      title = Title.new("Receiving Bandwidth (KB) between %s and %s" % [Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i), Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)])
      vals = []
      recvBW.keys.each do |item|
        vals << PieValue.new(recvBW[item],item)
      end
      @recvbwchart = doPieChart(title, vals, '#label# - #val# KB')
      @charts = [@cpuchart, @sendbwchart, @recvbwchart]
    end

    if params[:chart] == 'bar'
      bars = []

      # random colors to chose from
      colours = ["#459a89", "#9a89f9", "#666666"]

      bar = Bar3d.new
      bar.set_key("CPU (Hours)", 3)
      bar.colour = colours[0]
      bar.tooltip = '#val# CPU Hours'
      bar.values = cpu.values
      bars << bar

      bar = Bar3d.new
      bar.set_key("Send Bandwidth (KB)", 3)
      bar.colour = colours[1]
      bar.tooltip = '#val# Kbps Sending'
      bar.values = sendBW.values
      bars << bar

      bar = Bar3d.new
      bar.set_key("Recv Bandwidth (KB)", 3)
      bar.colour = colours[2]
      bar.tooltip = '#val# Kbps Receiving'
      bar.values = recvBW.values
      bars << bar

      # some title
      title = Title.new("CPU (Hours), Sending Bandwidth (KB), Receiving Bandwidth (KB) for selected nodes")

      # labels along the x axis, just hard code for now, but you would want to dynamically do this
      x_axis = XAxis.new
      x_axis.labels = cpu.keys

      # go to 100% since we are dealing with test results
      maxy = [maxcpu, maxsendBW, maxrecvBW].max
      y_axis = YAxis.new
      y_axis.set_range(0, maxy, maxy/10)

      # setup the graph
      graph = OpenFlashChart.new
      graph.bg_colour = '#ffffcc'
      graph.title = title
      graph.x_axis = x_axis
      graph.y_axis = y_axis
      graph.elements = bars

      @chart = graph
    end

    if params[:chart] == 'line'
      cpu = {}
      sendbw = {}
      recvbw = {}
      startDate = Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
      @dayusages.group_by(&:node).each do |node, results|
        if not cpu.has_key?(node); cpu[node] = []; end
        if not sendbw.has_key?(node); sendbw[node] = []; end
        if not recvbw.has_key?(node); recvbw[node] = []; end
        results.group_by(&:day).each do |day, values|
          cpu[node] << ScatterValue.new((day - startDate), values.inject(0) {|sum, item| sum + item.total_activity_minutes*item.total_cpu/item.number_of_samples/100/60 })
          sendbw[node] << ScatterValue.new((day - startDate), values.inject(0) {|sum, item| sum + 60*item.total_activity_minutes*item.total_send_BW/item.number_of_samples/8})
          recvbw[node] << ScatterValue.new((day - startDate), values.inject(0) {|sum, item| sum + 60*item.total_activity_minutes*item.total_recv_BW/item.number_of_samples/8})
        end
      end

      title = "CPU Hours used between %s and %s" % [Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i), Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)]
      @cpuchart = doLineChart(title, "day", "CPU Usage (Hours)", cpu)

      title = "Sending Bandwidth (KB)between %s and %s" % [Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i), Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)]
      @sendbwchart = doLineChart(title, "day", "Sending Bandwidth (KB)", sendbw)

      title = "Receiving Bandwidth (KB) between %s and %s" % [Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i), Date.civil(params[:end_date][:year].to_i, params[:end_date][:month].to_i, params[:end_date][:day].to_i)]
      @recvbwchart = doLineChart(title, "day", "Receiving Bandwidth (KB)", recvbw)

      @charts = [@cpuchart, @sendbwchart, @recvbwchart]
    end


    respond_to do |format|
      format.html
    end
  end
end
 
