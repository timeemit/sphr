class UsersController < ApplicationController
  layout 'application', :unless => [:new, :create, :authenticate, :home]
  before_filter :require_no_user, :only => [:new, :create, :authenticate]
  before_filter :require_user, :only => [:show, :edit, :update, :index, :destroy]

  #GET /
  # link_to root
  def home
    @user = User.new
    render :layout => 'users'
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
  
  #GET /users/:id/confirm/:confirmation_token
  def confirmation
    @user = User.find(params[:id])
    if @user.confirmation_token = params[:confirmation_token]
      flash[:notice] = 'Welcome! \n Fill out the form to complete the confirmation of your account.'
      render :layout => 'users'
    else
      flash[:notie] = 'You must confirm and sign in to edit your account.'
      redirect_to :action => :home, :layout => 'users'
    end
  end
  
  #POST /users/:id/confirm
  def confirm
    @user = User.find(params[:id])
    if @user.confirmation_token = params[:confirmation_token]
      @user.confirm! unless @user.confirmed?
      if @user.confirmed? and @user.update_attributes(params[:user])
        flash[:notice] = 'Account successfully confirmed and updated!'
        # Login the user.
      else
        flash[:notice] = 'An error has prevented us from confirming and updating your account'
        redirect_to :action => :confirmation, :layout => 'users'
      end
    else
      flash[:notice] = 'You must confirm and sign in to edit your account.'
      redirect_to :action => :home, :layout => 'users'
    end
  end
  
  #POST /users
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Thanks for signing up!'
      @user.send_confirmation_instructions
      render :layout => 'users'
    else
      redirect_to new_user_confirmation_path#, :layout => 'users'
    end
  end
  
  #POST /users/1
  def update
    @user = User.find(params[:user]) # makes our views "cleaner" and more consistent
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