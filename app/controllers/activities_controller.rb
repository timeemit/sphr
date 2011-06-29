class ActivitiesController < ApplicationController
  before_filter :require_user
  
  # GET /activities
  def index
    @activities = current_user.find_activities
  end
end
