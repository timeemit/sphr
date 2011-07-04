class Users::ConfirmationsController < Devise::ConfirmationsController
  def new
    
  end  
  
  #GET /users/:id/confirm/:confirmation_token
  def confirmation
    @user = User.find(params[:id])
    if @user.confirmation_token = params[:confirmation_token]
      flash[:notice] = "Welcome! \n Fill out the form to complete the confirmation of your account."
      render :layout => 'users'
    else
      flash[:notie] = 'You must confirm and sign in to edit your account.'
      redirect_to :action => :home, :layout => 'users'
    end
  end
  
  #POST /users/:id/confirm
  def create
    @user = User.find_by_email(params[:user][:email])
    unless @user.confirmation_token = params[:confirmation_token]
      # Confirmation may have expired/changed.  User needs to be redirected to request new confirmation instructions path.
      flash[:notice] = 'You must signup to confirm your account.'
      redirect_to root_path, :layout => 'users'
    end
    @user.confirm! unless @user.confirmed?
    if @user.confirmed? and @user.update_attributes(params[:user])
      flash[:notice] = 'Account successfully confirmed and updated!'
      redirect_to root_path, :layout => 'users'
    else
      flash[:notice] = 'An error has prevented the confirmation of your account'
      render :action => :confirmation, :layout => 'users'
    end
  end  
end
