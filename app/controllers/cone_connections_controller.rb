class ConeConnectionsController < ApplicationController
  before_filter :require_user
  before_filter :get_cone

  # POST /cone_connections
  def create
    @cone_connection = @cone.cone_connections.new(params[:cone_connection])
    if @cone_connection.save
      flash[:notice] = 'Cone connection was successfully created.'
      redirect_to edit_cone_path(@cone)
    else
      flash[:error] = 'Cone connection could not be created.'
      render :controller => 'cone', :action => "edit"
    end
  end

  # PUT /cone_connections/1
  def update
    @cone_connection = @cone.cone_connections.find(params[:id])
    if @cone_connection.update_attributes(params[:cone_connection])
      redirect_to edit_cone_path(@cone), :notice => 'Cone connection was successfully updated.'
    else
      render :controller => 'cones', :action => "edit"
    end
  end

  # DELETE /cone_connections/1
  def destroy
    @cone_connection = @cone.cone_connections.find(params[:id])
    @cone_connection.destroy
    redirect_to edit_cone_path(@cone), :notice => 'Cone connection was successfully destroyed.'
  end
  
  def get_cone
    @cone = current_user.cones.find(params[:cone])
  end
end