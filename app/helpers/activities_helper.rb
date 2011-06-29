module ActivitiesHelper
  def interpret(current_user, activity)
    description = String.new
    description << '<p>'
    case activity.action 
  	  when 'created_post_for_user' then 
   	    description << "#{link_to activity.user.name(current_user), user_posts_path(activity.user)}"
  	  	if activity.user == activity.entity.user
  	      description << ' writes '
  	  	else 
  	  		description << " wrote something for 
  	  		#{link_to activity.entity.user.name(current_user),  user_posts_path(activity.entity.user)}"
  	  	end
   	  	description << activity.entity.content
   	  	description << ' (' + time_since_creation(activity.created_at) + ')<br>'
  	  	unless activity.entity.comments.empty? 
      		description << "<em>Commments</em>"
      	end 
      	for comment in activity.entity.comments 
          description << "<div style='text-indent:5 px'>#{link_to comment.user.name(current_user), user_posts_path(comment.user)}"
          description << ' (' + time_since_creation(comment.created_at) + ')'
          description << "<br />#{comment.content}</div>"
      	end 
        
      when 'created_mutual_friendship' then
        description << "#{link_to activity.user.name(current_user), user_posts_path(activity.user)} and "
  		  if current_user == activity.entity.friend
  	      description << 'you '
  		  else
     		  description << "#{link_to activity.entity.friend.name(current_user), 
     		                  user_posts_path(activity.entity.friend)} "
  		  end 
        description << 'are now friends'
        
      when 'created_cluster' then
  		  description << "#{link_to activity.user.name(current_user), user_posts_path(activity.user)} 
  		  created the cluster 
  		  #{link_to activity.entity.cluster.name, cluster_path(activity.entity.cluster)}" 
        
      when 'updated_profiles' then
  	 	  description << "#{link_to activity.user.name(current_user), user_posts_path(activity.user)} 
  	 	  has updated a 
  	 	  #{link_to 'Profile', user_profile_path(activity.user, activity.user.which_profile(current_user))}"
        
    end 
    unless(activity.entity_type == 'Post' or activity.entity_type == 'Comment')
      description << ' (' + time_since_creation(activity.created_at) + ')'
    end
    description << '</p><br /'
    return description
  end
end
