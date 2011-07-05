class ShoutoutsController < ApplicationController
  before_filter :require_user
  before_filter :get_user
  before_filter :require_friendship
  before_filter :require_right_to_alter, :only => [:edit, :destroy]
  
  # GET /user/:user_id/shoutouts
  def index
    @shoutouts = @user.shoutouts.all
  end

  # GET /user/:user_id/shoutouts/1
  def show
    @shoutout = @user.shoutouts.find(params[:id])
  end

  # GET /user/:user_id/shoutouts/new
  def new
    @shoutout = @user.shoutouts.new
    @shoutout.author_id = current_user.id
    unless @user == current_user
      @shoutout.ring_id = @user.which_ring(current_user).id
    end
  end

  # GET /user/:user_id/shoutouts/1/edit
  def edit
    @shoutout = @user.shoutouts.find(params[:id])
  end

  # POST /user/:user_id/shoutouts
  def create
    @shoutout = current_user.authored_shoutouts.build(params[:shoutout])
    if @shoutout.save
      redirect_to(user_shoutout_path(@shoutout.user, @shoutout), :notice => 'Shoutout was successfully created!')
    else
      render :action => "new", :error => 'Shoutout could not be created.'
    end
  end

  # PUT /user/:user_id/shoutouts/1
  def update
    @shoutout = current_user.authored_shoutouts.find(params[:id])
    if @shoutout.update_attributes(params[:shoutout])
      redirect_to(user_shoutout_path(@shoutout.user, @shoutout), :notice => 'Shoutout was successfully updated!')
    else
      render :action => "edit", :error => 'Shoutout could not be updated'
    end
  end

  # DELETE /user/:user_id/shoutouts/1
  def destroy
    # @shoutout is defined in require_right_before_filter
    @shoutout.destroy
    redirect_to(user_shoutouts_path(@user), :notice => 'Shoutout successfully destroyed!')
  end

  # before_filters
  def require_right_to_alter
    @shoutout = @user.shoutouts.find(params[:id])
    unless @shoutout.author == current_user or @shoutout.user == current_user
      redirect_to user_shoutout_path(@user, @shoutout), :notice => 'You do not have permission to do that!'
    end
  end
end