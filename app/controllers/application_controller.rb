# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  private

    # A helpful before_filter method to handle requests without a session
    def require_user
      unless user_signed_in?
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_path
        return false
      end
    end

    # A helpful before_filter method to handle requests with a session
    def require_no_user
      if user_signed_in?
        flash[:notice] = "You must be logged out to access this page"
        redirect_to user_shoutouts_path(current_user)
        return false
      end
    end
    
    # The default url to be used by Devise after signing in.
    def after_sign_in_path_for(resource)
      if resource.is_a?(User)
        user_shoutouts_path(resource)
      else
        super
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