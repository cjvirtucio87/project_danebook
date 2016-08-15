class PostsController < ApplicationController
  skip_before_action :correct_user
  before_action :validate_update_request, only: [:update]
  before_action :correct_timeline, only: [:create]

  def create
    @user = current_user
    @posts = @user.posts
    @post = @posts.create!(post_params)
    redirect_to @user.timeline
  end

  def update
    @post = Post.find(params[:id])
    @user = @post.user
    @post.update(post_params)
    redirect_to @user.timeline
  end

  private
    def post_params
      params.require(:post).permit(:body,
                                   { comments_attributes: [:user_id,:body] },
                                   { likes_attributes: [:user_id,:_destroy] })
    end

    # Only for editing a post.
    def validate_update_request
      case
      when post_params[:body]
        correct_post
      when post_params[:comments_attributes],post_params[:likes_attributes]
        return true
      else
        flash[:danger] = "You've attempted an unauthorized action."
        redirect_to root_url
      end
    end

    def correct_post
      case current_user
      when Post.find(params[:id].to_i).user
        return true
      else
        flash[:notice] = "You cannot edit someone else's post."
        redirect_to root_url
      end
    end

end
