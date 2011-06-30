class UsersController < ApplicationController
  layout 'application', :unless => [:new, :create, :authenticate]
  before_filter :require_no_user, :only => [:new, :create, :authenticate]
  before_filter :require_user, :only => [:show, :edit, :update, :index, :destroy]

  #GET /users/1/authenticate
  # authenticate_user_path
  def authenticate
    @user = User.find(params[:id])
    if @user.perishable_token == params[:perishable_token]
      render :layout => 'users'
    end
  end
  
  #GET /users
  def index
    @search = User.search(params[:search])
    @users = @search.relation.order(:username).page(params[:page])
  end

  #GET /users/1/new  
  def new
    @user = User.new
  end
  
  #GET /users/1
  def show
    @user = @current_user
  end

  #GET /users/1/edit
  def edit
    @user = @current_user
  end
  
  #POST /users
  def create
    @user = User.new(params[:user])
    if @user.save
      if @user.authenticated
        flash[:notice] = 'Welcome to Sphr!'
        redirect_to user_shoutouts_path(@user)        
      else
        flash[:notice] = 'Thanks for signing up!'
        render :action => :new, :layout => 'users'
      end
    else
      render :action => :new, :layout => 'users'
    end
  end
  
  #POST /users/1
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to user_posts_path(current_user)
    else
      render :action => :edit
    end
  end
  
  #DELETE /users/1
  def destroy
    @user = current_user
    @user.destroy
    flash[:notice] = "Successfully terminated account."
    redirect_to root_url
  end

  private
  def develop_new_friendships_for_friends_of_friends
    #new_friendships is an array of new friendships with friends_of_friends.
    #user_id and friend_id are already set.  These should be written with a hidden_field method to be passed into create/update.
    @new_friendships = Array.new
    @friendship_counter = 0
    current_user.friends_of_friends.each do |friend_array| 
      @new_friendships <<  current_user.friendships.build(:user_id => current_user.id, :friend_id => friend_array.first.id)
      current_user.cones.size.times{@new_friendships.last.cone_connections.build}
    end
  end

end