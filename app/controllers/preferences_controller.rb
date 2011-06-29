class PreferencesController < ApplicationController
  def update
    @preference = @preference.find(params[:id])
    if @preference.update_attributes(params[:profile])
      flash[:notice] = 'Updated Preference!'
      redirect_to 
    else
      
    end
  end
end
