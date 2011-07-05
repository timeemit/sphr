class FriendshipsController < ApplicationController
  before_filter :require_user

#All friendships are accessed throught the current_user,
#so all actions are directed through current_user.

  # GET /cones
  def index
    retrieve_and_develop_all_friendships
  end

  # GET /friendships/1
  def show
    if current_user.friendships.exists?(params[:id])            #Return the non-mutual friendship if it exists
      @friendship = current_user.friendships.find(params[:id])
    else
      @friendship = current_user.mutual_friendships.find(params[:id]) #Otherwise return the mutual one.
    end
  end

  # GET /friendships/1/new
  def new
    @friendship = current_user.friendships.find(params[:friendship])
    current_user.cones.each{|cone| @friendship.cone_connections.build(:cone_id => cone.id)}
  end
  
  # GET /friendships/1/edit
  def edit
    if current_user.friendships.exists?(params[:id])            #Return the non-mutual friendship if it exists
      @friendship = current_user.friendships.find(params[:id])
    else 
      @friendship = current_user.mutual_friendships.find(params[:id]) #Otherwise return the mutual one
    end 
    current_user.cones.each{|cone| (@friendship.cones.exists?(cone)) ? nil : @friendship.cone_connections.build(:cone_id => cone.id)}
  end

  # POST /friendships
  def create
    @friendship = User.find(params[:friendship][:friend_id]).inverse_friendships.build(params[:friendship])
    if @friendship.save
      @friendship.mutual? ? (flash[:notice] = 'Added friend') : (flash[:notice] = 'Extended friendship.')
      redirect_to friendship_path(@friendship)
    else
      flash[:error] = 'Unable to create friendship.'
      retrieve_and_develop_all_friendships
      render :action => 'index'
    end
  end
  
  # PUT /friendships/1
  def update
    if current_user.friendships.exists?(params[:id])
      @friendship = current_user.friendships.find(params[:id])
    else 
      @friendship = current_user.mutual_friendships.find(params[:id])
    end

    if @friendship.update_attributes(params[:friendship])
      flash[:notice] = "Friendship updated!"
      redirect_to friendship_path(@friendship)
    else
      flash[:error] = "Friendship could not be updated."
      render :action => :edit
    end
  end
  
  # DELETE /friendships/1
  def destroy
    @friendship = Friendship.find(params[:id])
    if current_user.id == @friendship.user.id
      @friendship.delete
    elsif current_user.id == @friendship.friend_id
      @friendship.delete
    end
    
    flash[:notice] = "Removed friendship."
    redirect_to friendships_path
  end
  
  private
  
  def retrieve_and_develop_all_friendships
    #Gather all the friendships tied to the User
    @mutual_friendships = current_user.mutual_friendships.joins(:ring).order('rings.number ASC', 'rings.projected_name ASC').page(params[:page]).per(6)
    @inverse_friendships = current_user.inverse_friendships
    @friendships = current_user.friendships
    develop_reciprocated_friendships
  end
    
  def develop_reciprocated_friendships
    #reciprocated_friendships is an array of new friendships with inverse_friends.
    #user_id and friend_id are already set.  These should be written with a hidden_field method.
    @reciprocated_friendships = Array.new
    @inverse_friendship_counter = 0
    current_user.inverse_friendships.each do |friendship| 
      @reciprocated_friendships << current_user.friendships.build(:friend_id => friendship.user.id)
      current_user.cones.each{|cone| @reciprocated_friendships.last.cone_connections.build(:cone_id => cone.id)}
    end
  end
end