module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authentificate_consumer_or_logged_in, only: [:show, :update, :following, :followers, :feed]
      before_action :authentificate_consumer, only: :create

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
          head 422
        end
      end

      def update
        @user = User.find(params[:id])
        if @user.update_attributes(user_params)
          render json: @user, status: :ok
        else
          head 422
        end
      end

      #現状、deleteは管理者しか使えない機能なので、APIとしては一旦凍結
      # def destroy
      #   User.find(params[:id]).destroy
      #   head :no_content
      # end

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

        def authentificate_consumer_or_logged_in
          user = User.find(params[:id])
          if current_user == user
            return
          end
          signature = params[:signature]
          consumer = DevApp.find_by(consumer_id: params[:consumer_id])
          relationship = LinkedApp.find_by(user_id: user.id, dev_app_id:consumer.id) if consumer
          if relationship
            key = consumer.consumer_secret
            value = consumer.consumer_id
            digest = OpenSSL::HMAC.new(value, 'sha256')
            if signature == digest.update(key).to_s
              return
            end
          end
          head 401
        end

        def authentificate_consumer
          signature = params[:signature]
          consumer = DevApp.find_by(consumer_id: params[:consumer_id])
          key = consumer.consumer_secret
          value = consumer.consumer_id
          digest = OpenSSL::HMAC.new(value, 'sha256')
          if signature == digest.update(key).to_s
            return
          end
          head 401
        end
    end
  end
end
