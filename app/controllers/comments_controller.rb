class CommentsController < ApplicationController
  before_filter :require_user
  before_filter :get_post
  before_filter :post_recipient
  
  def new
    @comment = @post.comments.new
  end
  
  def edit
    @comment = @post.comments.find(params[:comment])
  end
  
  def create
    @comment = @post.comments.build(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      flash[:notice] = 'Comment Successfully Created'
      redirect_to user_posts_path(@recipient)
    else
      flash[:notice] = 'Could not create comment'
      render :action => 'new'
    end
  end

  def update
    @comment = @post.comments.find(params[:id])
    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'Comment Successfully Updated'
      redirect_to user_posts_path(@recipient)
    else
      flash[:notice] = 'Could not update comment'
      redirect_to new_user_post_comment_path(@recipient, @post)
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    if @post.user == current_user or @post.user == @post.recipient
      @comment.destroy
      flash[:notice] = 'Comment Successfully Destroyed'
      redirect_to user_posts_path(@recipient)
    else
      flash[:notice] = 'You cannot destroy this comment'
      redirect_to user_posts_path(@recipient)
    end
  end
  
  private
  
  def get_post
    @post = Post.find(params[:post_id])
  end
  
  def post_recipient
    @recipient = @post.recipient
  end
  
end
