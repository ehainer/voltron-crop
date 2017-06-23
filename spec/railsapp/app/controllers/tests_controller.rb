class TestsController < ApplicationController

  def index
    head :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      head :ok
    else
      render plain: @user.errors.full_messages, status: 500
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      head :ok
    else
      render json: @user.errors.full_messages, status: 500
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :avatar, :remove_avatar, :avatar_x, :avatar_y, :avatar_w, :avatar_h, :avatar_zoom, :avatar_cache)
    end

end