class SlicegroupsController < ApplicationController
  before_filter :login_required
  # GET /slicegroups
  # GET /slicegroups.xml
  def index
    @slicegroups = Slicegroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @slicegroups }
    end
  end

  # GET /slicegroups/1
  # GET /slicegroups/1.xml
  def show
    @slicegroup = Slicegroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @slicegroup }
    end
  end

  # GET /slicegroups/new
  # GET /slicegroups/new.xml
  def new
    @slicegroup = Slicegroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @slicegroup }
    end
  end

  # GET /slicegroups/1/edit
  def edit
    @slicegroup = Slicegroup.find(params[:id])
  end

  # POST /slicegroups
  # POST /slicegroups.xml
  def create
    @slicegroup = Slicegroup.new(params[:slicegroup])

    respond_to do |format|
      if @slicegroup.save
        flash[:notice] = 'Slicegroup was successfully created.'
        format.html { redirect_to(@slicegroup) }
        format.xml  { render :xml => @slicegroup, :status => :created, :location => @slicegroup }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @slicegroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /slicegroups/1
  # PUT /slicegroups/1.xml
  def update
    @slicegroup = Slicegroup.find(params[:id])

    respond_to do |format|
      if @slicegroup.update_attributes(params[:slicegroup])
        flash[:notice] = 'Slicegroup was successfully updated.'
        format.html { redirect_to(@slicegroup) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @slicegroup.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /slicegroups/1
  # DELETE /slicegroups/1.xml
  def destroy
    @slicegroup = Slicegroup.find(params[:id])
    @slicegroup.destroy

    respond_to do |format|
      format.html { redirect_to(slicegroups_url) }
      format.xml  { head :ok }
    end
  end
end
