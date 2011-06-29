class ProfilesController < ApplicationController
  before_filter :require_user
  before_filter :get_current_user, :except => :show     
  # --> Not necessary.  Could compare current user to @profile.user to determine if/how information should be displayed
  # Would make routing much simpler to change...
  
  def index
    @rings = current_user.rings.includes(:profile).order(:number)
    @friendships = current_user.mutual_friendships.joins(:ring).includes(:friend).order(:ring => :number).group(:ring_id)
  end
  
  def new
    @profile = Profile.new
  end
    
  def show
    @user = User.find(params[:user_id])
    if @user == current_user #Ensures that users can navigate to any ring in their profiles
      @profile = @user.profiles.find(params[:id])
    else
      @profile = @user.which_profile(current_user)
    end
  end
  
  def edit
    @profile = @user.profiles.find(params[:id])
  end
  
  def create
    @profile = current_user.rings.find(params[:profile][:ring_id]).build_profile(params[:profile])
    if @profile.save
      flash[:notice] = 'Successfully created profile.'
      redirect_to user_profiles_path(@user)
    else
      render :action => 'new'
    end
  end
  
  def update
    @profile = current_user.rings.find(params[:profile][:ring_id]).profile
    if @profile.update_attributes(params[:profile])
      flash[:notice] = 'Successfully updated profile.'
      redirect_to user_profiles_path(@user)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @profile = @user.profiles.find(params[:id])
    @profile.destroy
    flash[:notice] = "Successfully destroyed profile."
    redirect_to user_profiles_path()
  end

  private

  def get_current_user
    @user = User.find(params[:user_id])
  end
end