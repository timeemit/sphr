class Users::ConfirmationsController < Devise::ConfirmationsController
  #GET /users/:id/confirm/:confirmation_token
  def confirmation
    @user = User.find(params[:id])
    if @user.confirmation_token = params[:confirmation_token]
      flash[:notice] = "Welcome! \n Fill out the form to complete the confirmation of your account."
      render :layout => 'users'
    else
      flash[:error] = 'Please follow the link sent to your email account.'
      redirect_to :action => :home, :layout => 'users'
    end
  end
  
  #GET /users/confirmation/new
  def new
    
  end
  
  #POST /users/:id/confirm/resend
  def resend
    @user = User.find(params[:id])
    @user.send_confirmation_instructions
    flash[:notice] = 'Email instructions have been sent to your account.'
    redirect_to parallax_path(@user)
  end
  
  #POST /users/:id/confirm
  def create
    @user = User.find_by_email(params[:user][:email])
    unless @user.confirmation_token = params[:confirmation_token]
      # Confirmation may have expired/changed.  User needs to be redirected to request new confirmation instructions path.
      flash[:error] = 'You must signup to confirm your account.'
      redirect_to root_path, :layout => 'users'
    end
    @user.confirm! unless @user.confirmed?
    if @user.confirmed? and @user.update_attributes(params[:user])
      flash[:notice] = 'Account successfully confirmed and updated!'
      redirect_to root_path, :layout => 'users'
    else
      flash[:error] = 'An error has prevented the confirmation of your account'
      render :action => :confirmation, :layout => 'users'
    end
  end  
end
