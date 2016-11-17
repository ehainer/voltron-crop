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

    puts "---------------------------------------"
    puts "---------------------------------------"
    puts "---------------------------------------"
    puts Voltron.config.crop.raise_on_error
    puts "---------------------------------------"
    puts "---------------------------------------"
    puts "---------------------------------------"

    if @user.update(user_params)
      head :ok
    else
      render json: @user.errors.full_messages, status: 500
    end
  end

  private

    def user_params
      params.require(:user).permit(:avatar, :remove_avatar)
    end

end