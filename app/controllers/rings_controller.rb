class RingsController < ApplicationController
  #GET /cones
  def index
    @rings = current_user.rings
  end

  #GET /cones/1
  def show
    @ring = current_user.rings.find(params[:ring])
  end

  #GET /cones/1/new
  def new
    @ring = current_user.rings.find(params[:ring])
  end

  #GET /cones/1/edit
  def edit
    @ring = current_user.rings.find(params[:ring])    
  end

  #POST /cones
  def create
    @ring = current_user.rings.find(params[:ring])
    if @ring.save
      redirect_to ring_path(@ring), :notice => 'Ring successfully created!'
    else
      redirect_to rings_path, :error => 'Unable to create ring.'
    end
  end

  #PUT /cones/1
  def update
    @ring = current_user.rings.find(params[:id])
    if @ring.update_attributes(params[:ring])
      redirect_to ring_path(@ring), :notice => 'Ring successfully update!'
    else
      redirect_to ring_path(@ring), :error => 'Unable to update ring.'
    end
  end

  #DELETE /cones/1
  def destroy
    @ring = current_user.rings.find(params[:id])
    @ring.destroy
    flash[:notice] = 'Successfully destroyed ring.'
    redirect_to rings_path
  end
end
