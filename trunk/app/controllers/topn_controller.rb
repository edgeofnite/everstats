class TopnController < ApplicationController
  layout 'default'
  @page_title = "Activity"

  # GET /topn
  def index
    @item = { "count" => 5, "days" => 7 }
  end

  # GET /topn/slices_by_cpu
  # GET /topn/slices_by_cpu.xml
  def slices_by_cpu
    @page_title = "Activity: Top Slices by CPU Hours"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusage.find_by_sql("select 0 as id, slice_id as slice_id, count(distinct node_id) as node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu, 60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by slice_id order by sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples) desc limit " + @count)

    title = Title.new("Top %s slices by CPU for the past %s days" % [@count, @days])
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#label# - #val# CPU Hours'
    vals = []
    @dayusages.each do |item|
      vals << PieValue.new((item.total_cpu.to_f/60),item.slice.name)
    end
    pie.set_values(vals)
    @chart = OpenFlashChart.new
    @chart.set_title(title)
    @chart.add_element(pie)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end

  # GET /topn/slices_by_send_bw
  # GET /topn/slices_by_send_bw.xml
  def slices_by_send_bw
    @page_title = "Activity: Top Slices by Sending Bandwidth"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusage.find_by_sql("select 0 as id, slice_id, count(distinct node_id) as node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by slice_id order by  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 desc limit " + @count)

    title = Title.new("Top %s slices by Total Sending Bandwidth for the past %s days" % [@count, @days])
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

    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end

  # GET /topn/slices_by_recv_bw
  # GET /topn/slices_by_recv_bw.xml
  def slices_by_recv_bw
    @page_title = "Activity: Top Slices by Receiving Bandwidth"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusage.find_by_sql("select 0 as id, slice_id, count(distinct node_id) as node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by slice_id order by 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 desc limit " + @count)

    title = Title.new("Top %s slices by Total Receiving Bandwidth for the past %s days" % [@count, @days])
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#label# - #val# Kb'
    vals = []
    @dayusages.each do |item|
      vals << PieValue.new(item.total_recv_BW,item.slice.name)
    end
    pie.set_values(vals)
    @chart = OpenFlashChart.new
    @chart.set_title(title)
    @chart.add_element(pie)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end

  # GET /topn/nodes_by_cpu
  # GET /topn/nodes_by_cpu.xml
  def nodes_by_cpu
    @page_title = "Activity: Top Nodes by CPU Hours"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusage.find_by_sql("select 0 as id, count(distinct slice_id)as slice_id, node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by node_id order by sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples) desc limit " + @count)

    title = Title.new("Top %s nodes by CPU for the past %s days" % [@count, @days])
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#label# - #val# CPU Hours'
    vals = []
    @dayusages.each do |item|
      vals << PieValue.new((item.total_cpu.to_f/60),item.node.hostname)
    end
    pie.set_values(vals)
    @chart = OpenFlashChart.new
    @chart.set_title(title)
    @chart.add_element(pie)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end


  # GET /topn/nodes_by_send_bw
  # GET /topn/nodes_by_send_bw.xml
  def nodes_by_send_bw
    @page_title = "Activity: Top Nodes by Sending Bandwidth"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusage.find_by_sql("select 0 as id, count(distinct slice_id)as slice_id, node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by node_id order by  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 desc limit " + @count)

    title = Title.new("Top %s nodes by Total Sending Bandwidth for the past %s days" % [@count, @days])
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#label# - #val# Kb'
    vals = []
    @dayusages.each do |item|
      vals << PieValue.new(item.total_send_BW,item.node.hostname)
    end
    pie.set_values(vals)
    @chart = OpenFlashChart.new
    @chart.set_title(title)
    @chart.add_element(pie)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end

  # GET /topn/nodes_by_recv_bw
  # GET /topn/nodes_by_recv_bw.xml
  def nodes_by_recv_bw
    @page_title = "Activity: Top Nodes by Receiving Bandwidth"
    @count = params[:count]
    @days = params[:days]
    if ! @count
      @count = "5"
    end
    if ! @days
      @days = "7"
    end

    @dayusages = Dayusage.find_by_sql("select 0 as id, count(distinct slice_id)as slice_id, node_id, now() as day, sum(total_activity_minutes) as total_activity_minutes, avg(avg_cpu) as avg_cpu, avg(avg_send_BW) as avg_send_BW, avg(avg_recv_BW) as avg_recv_BW, sum(total_activity_minutes)*sum(total_cpu)/sum(number_of_samples)/100 as total_cpu,  60*sum(total_activity_minutes)*sum(total_send_BW)/sum(number_of_samples)/8 as total_send_BW, 60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 as total_recv_BW, max(max_cpu) as max_cpu, max(max_send_BW) as max_send_BW, max(max_recv_BW) as max_recv_BW, sum(number_of_samples) as number_of_samples, max(last_update) as last_update from dayusages where day > date_sub(now(), interval " + @days +" day) group by node_id order by  60*sum(total_activity_minutes)*sum(total_recv_BW)/sum(number_of_samples)/8 desc limit " + @count)

    title = Title.new("Top %s nodes by Total Receiving Bandwidth for the past %s days" % [@count, @days])
    pie = Pie.new
    pie.start_angle = 35
    pie.animate = true
    pie.tooltip = '#label# - #val# Kb'
    vals = []
    @dayusages.each do |item|
      vals << PieValue.new(item.total_recv_BW,item.node.hostname)
    end
    pie.set_values(vals)
    @chart = OpenFlashChart.new
    @chart.set_title(title)
    @chart.add_element(pie)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @dayusages }
    end
  end
end
