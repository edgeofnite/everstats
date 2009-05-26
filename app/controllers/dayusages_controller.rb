class DayusagesController < ApplicationController
  # GET /dayusages
  # GET /dayusages.xml
  def index
    @dayusages = Dayusage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dayusages }
    end
  end

  # GET /dayusages/1
  # GET /dayusages/1.xml
  def show
    @dayusage = Dayusage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dayusage }
    end
  end

  # GET /dayusages/new
  # GET /dayusages/new.xml
  def new
    @dayusage = Dayusage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dayusage }
    end
  end

  # GET /dayusages/1/edit
  def edit
    @dayusage = Dayusage.find(params[:id])
  end

  # POST /dayusages
  # POST /dayusages.xml
  def create
    @dayusage = Dayusage.new(params[:dayusage])

    respond_to do |format|
      if @dayusage.save
        flash[:notice] = 'Dayusage was successfully created.'
        format.html { redirect_to(@dayusage) }
        format.xml  { render :xml => @dayusage, :status => :created, :location => @dayusage }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dayusage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dayusages/1
  # PUT /dayusages/1.xml
  def update
    @dayusage = Dayusage.find(params[:id])

    respond_to do |format|
      if @dayusage.update_attributes(params[:dayusage])
        flash[:notice] = 'Dayusage was successfully updated.'
        format.html { redirect_to(@dayusage) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dayusage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dayusages/1
  # DELETE /dayusages/1.xml
  def destroy
    @dayusage = Dayusage.find(params[:id])
    @dayusage.destroy

    respond_to do |format|
      format.html { redirect_to(dayusages_url) }
      format.xml  { head :ok }
    end
  end
end
