class EchoesController < ApplicationController
  # GET /echoes
  # GET /echoes.xml
  def index
    @echoes = Echo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @echoes }
    end
  end

  # GET /echoes/1
  # GET /echoes/1.xml
  def show
    @echo = Echo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @echo }
    end
  end

  # GET /echoes/new
  # GET /echoes/new.xml
  def new
    @echo = Echo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @echo }
    end
  end

  # GET /echoes/1/edit
  def edit
    @echo = Echo.find(params[:id])
  end

  # POST /echoes
  # POST /echoes.xml
  def create
    @echo = Echo.new(params[:echo])

    respond_to do |format|
      if @echo.save
        format.html { redirect_to(@echo, :notice => 'Echo was successfully created.') }
        format.xml  { render :xml => @echo, :status => :created, :location => @echo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @echo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /echoes/1
  # PUT /echoes/1.xml
  def update
    @echo = Echo.find(params[:id])

    respond_to do |format|
      if @echo.update_attributes(params[:echo])
        format.html { redirect_to(@echo, :notice => 'Echo was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @echo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /echoes/1
  # DELETE /echoes/1.xml
  def destroy
    @echo = Echo.find(params[:id])
    @echo.destroy

    respond_to do |format|
      format.html { redirect_to(echoes_url) }
      format.xml  { head :ok }
    end
  end
end
