class ConesController < ApplicationController
  before_filter :require_user

  # GET /cones
  def index
    @cones = current_user.cones
  end

  # GET /cones/1
  def show
    @cone = current_user.cones.find(params[:id])
  end

  # GET /cones/new
  def new
    @cone = current_user.cones.new
    current_user.mutual_friendships.each{|friendship| @cone.cone_connections.build(:friendship_id => friendship.id)} 
  end

  # GET /cones/1/edit
  def edit
    @cone = current_user.cones.find(params[:id])
    current_user.mutual_friendships.each{|friendship| @cone.friendships.exists?(friendship) ? nil : @cone.cone_connections.build(:friendship_id => friendship.id)} 
  end

  # POST /cones
  def create
    @cone = current_user.cones.build(params[:cone])
    if @cone.save
      flash[:notice] = 'Cone successfully created!'
      redirect_to cone_path(@cone)
    else
      flash[:notice] = 'Cone could not be created'
      render :action => 'new'
    end
  end

  # PUT /cones/1
  def update
    @cone = current_user.cones.find(params[:id])
    if @cone.update_attributes(params[:cone])
      flash[:notice] = 'Update successful!'
      redirect_to cone_path(@cone)
    else
      flash[:notice] = 'Could not update cone.'
      render :action => 'edit'
    end
  end

  # DELETE /cones/1
  def destroy
    @cone = current_user.cones.find(params[:id])
    @cone.destroy
    flash[:notice] = 'Cone destroyed.'
    redirect_to cones_path
  end
end
