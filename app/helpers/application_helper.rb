# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #Returns a list of the attributes/fields that need have generated errors in a given form for object.
  def parse_errors_for(object)
    unique_keys = []
    object.errors.each do |attribute, error|
      unless unique_keys.include?(attribute)
        unique_keys << attribute
      end
    end
    return unique_keys
  end
  
  #Returns a hex color code that represents how close the given ring is with respect to the public ring.
  def color_for_ring(ring, public_ring)
    #Red is close, blue is cold?
    #This was moved into the model.
  end
  
  #Returns a link to the user displaying a name appropriate for the current_user
  def link_through_name(user, current_user)
    return link_to user.name(current_user), user_shoutouts_path(user), :class => :name
  end
  
  #Given a ring, returns a span with the number in the appropriate background color
  def ring_number(ring)
    output = tag('span', :class => :ring, :style => "background-color:#{ring.rgb}")
  	output += 'Ring ' + ring.number.to_s
  	output += raw ' </span>'
  	return output
  end
  
  #Returns a string stating the amount of time that has elapsed since the creation of the 
  def time_since_creation(created_at)
    hrs = ((Time.now - created_at)/(60*60)).floor
    mins = (((Time.now - created_at)/(60*60) - hrs) * 60).floor
    secs = (((Time.now - created_at)/(60) - mins) * 60).floor
    time = "#{hrs<1 ? (mins<1 ? (secs<1 ? 
      ' not too long' : pluralize(secs.to_s,'second')) : pluralize(mins.to_s, 'minute')) : 
      (hrs < 24 ? (pluralize(hrs.to_s, 'hour') ) : (pluralize(hrs.divmod(24).first, 'day')))} ago"
    return time
  end

  #Returns a summary of errors found in the form, if any exist.
  def error_summary(object)
    string = '<% if object.errors.any? %>'
  	string <<	"<%= render :partial => 'partials/errors', :locals => {:objects => [object]}%>"
  	string << '<% end %>'
  	return string
  end
	
end
