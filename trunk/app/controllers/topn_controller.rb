class TopnController < ApplicationController
  layout 'default'
  @page_title = "Activity"

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

  # GET /topn
  def index
    @item = { "count" => 5, "days" => 7 }
  end

  # GET /topn/nodes
  def nodes
    @page_title = "Activity: Top Nodes"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusagesummary.find_by_sql("select 0 as id, node_id as node_id, max(nitems) as nitems, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW,  sum(total_send_BW) as total_send_BW, sum(total_cpu) as total_cpu, sum(total_send_BW) as total_send_BW, sum(total_recv_BW) as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW from dayusagesummaries where day > date_sub(now(), interval " + @days +" day) and slice_id = -1 and node_id != -1 group by node_id order by sum(total_CPU) desc limit " + @count)

    cpu = []
    sendBW = []
    recvBW = []
    @dayusages.each do |item|
      cpu << PieValue.new(item.total_cpu,item.node.hostname)
      sendBW << PieValue.new(item.total_send_BW,item.node.hostname)
      recvBW << PieValue.new(item.total_recv_BW,item.node.hostname)
    end
    title = Title.new("Top %s nodes by CPU for the past %s days" % [@count, @days])
    @cpuchart = doPieChart(title, cpu, '#label# - #val# CPU Hours')
    title = Title.new("Top %s nodes by Total Sending Bandwidth for the past %s days" % [@count, @days])
    @sendBWchart = doPieChart(title, sendBW, '#label# - #val# Kb')
    title = Title.new("Top %s nodes by Total Incoming Bandwidth for the past %s days" % [@count, @days])
    @recvBWchart = doPieChart(title, recvBW, '#label# - #val# Kb')

    @charts = [@cpuchart, @sendBWchart, @recvBWchart]
    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end

  # GET /topn/slices
  def slices
    @page_title = "Activity: Top Slices"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusagesummary.find_by_sql("select 0 as id, slice_id as slice_id, max(nitems) as nitems, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_cpu) as total_cpu, sum(total_send_BW) as total_send_BW, sum(total_recv_BW) as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW from dayusagesummaries where day > date_sub(now(), interval " + @days +" day) and slice_id != -1 and node_id = -1 group by slice_id order by sum(total_cpu) desc limit " + @count)
    @dayusagesSBW = Dayusagesummary.find_by_sql("select 0 as id, slice_id as slice_id, 0 as nitems, 0 as total_activity_minutes, 0 as avg_cpu, 0 as avg_send_BW, 0 as avg_recv_BW,  sum(total_send_BW) as total_send_BW, 0 as total_cpu, 0 as total_recv_BW, 0 as max_cpu, 0 as max_send_BW, 0 as max_recv_BW from dayusagesummaries where day > date_sub(now(), interval " + @days +" day) and slice_id != -1 and node_id = -1 group by slice_id order by sum(total_send_BW) desc limit " + @count)
    @dayusagesRBW = Dayusagesummary.find_by_sql("select 0 as id, slice_id as slice_id, 0 as nitems, 0 as total_activity_minutes, 0 as avg_cpu, 0 as avg_send_BW, 0 as avg_recv_BW, 0 as total_send_BW, 0 as total_cpu, sum(total_recv_BW) as total_recv_BW, 0 as max_cpu, 0 as max_send_BW, 0 as max_recv_BW from dayusagesummaries where day > date_sub(now(), interval " + @days +" day) and slice_id != -1 and node_id = -1 group by slice_id order by sum(total_recv_BW) desc limit " + @count)

    cpu = []
    sendBW = []
    recvBW = []
    @dayusages.each do |item|
      cpu << PieValue.new(item.total_cpu,item.slice.name)
    end
    @dayusagesSBW.each do |item|
      sendBW << PieValue.new(item.total_send_BW,item.slice.name)
    end
    @dayusagesRBW.each do |item|
      recvBW << PieValue.new(item.total_recv_BW,item.slice.name)
    end
    title = Title.new("Top %s slices by CPU for the past %s days" % [@count, @days])
    @cpuchart = doPieChart(title, cpu, '#label# - #val# CPU Hours')
    title = Title.new("Top %s slices by Total Sending Bandwidth for the past %s days" % [@count, @days])
    @sendBWchart = doPieChart(title, sendBW, '#label# - #val# Kb')
    title = Title.new("Top %s slices by Total Incoming Bandwidth for the past %s days" % [@count, @days])
    @recvBWchart = doPieChart(title, recvBW, '#label# - #val# Kb')

    @charts = [@cpuchart, @sendBWchart, @recvBWchart]
    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end

end
