# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # helper_method :current_user_session, :current_user

  private

  #Authlogic methods
    # def current_user_session
    #   return @current_user_session if defined?(@current_user_session)
    #   @current_user_session = UserSession.find
    # end
    # 
    # def current_user
    #   return @current_user if defined?(@current_user)
    #   @current_user = current_user_session && current_user_session.user
    # end
    
    # def store_location
    #   session[:return_to] = request.request_uri
    # end

    # def redirect_back_or_default(default)
    #   redirect_to(session[:return_to] || default)
    #   session[:return_to] = nil
    # end     
    
    def require_user
      unless user_signed_in?
        # store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_path
        return false
      end
    end

    def require_no_user
      if user_signed_in?
        # store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to user_shoutouts_path(current_user)
        return false
      end
    end
    
    
    # DRY Code
    def require_friendship
      unless @user == current_user
        unless current_user.mutual_friends.include?(@user)
          redirect_to user_shoutouts_path(current_user), 
          :notice => 'You must be mutual friends with that user to do that!'
        end
      end
    end

    def get_user
      @user = User.find(params[:user_id])
    end
end