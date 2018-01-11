module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token
      def index
        @users = User.where(activated: true).paginate(page: params[:page])
        render 'index', formats: 'json', handlers: 'jbuilder'
      end

      def show
        @user = User.find(params[:id])
        @microposts = @user.microposts.paginate(page: params[:page])
        redirect_to root_url and return unless @user.activated?
        render 'show', formats: 'json', handlers: 'jbuilder'
      end

      def create
        @user = User.new(user_params)
        if @user.save
          @user.send_activation_email
          render json: @user, status: :created
        else
          render json: @user.errors, status: :unprocessale_entity
        end
      end

      def update
        @user = User.find(params[:id])
        if @user.update_attributes(user_params)
          render json: @user, status: :ok
        else
          render json: @user.errors, status: :unprocessale_entity
        end
      end

      def destroy
        User.find(params[:id]).destroy
        head :no_content
      end

      def following
        @user = User.find(params[:id])
        @users = @user.following.paginate(page: params[:page])
        render 'user_following', formats: 'json', handlers: 'jbuilder'
      end

      def followers
        @user = User.find(params[:id])
        @users = @user.followers.paginate(page: params[:page])
        render 'user_followers', formats: 'json', handlers: 'jbuilder'
      end

      def feed
        @user = User.find(params[:id])
        @feed_items = @user.feed(@user).paginate(page: params[:page])
        render 'user_feed', formats: 'json', handlers: 'jbuilder'
      end

      private
        def user_params
          params.require(:user).permit(:name, :email, :password, :password_confirmation, :follow_notice)
        end
    end
  end
end
