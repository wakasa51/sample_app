module Api
  module V1
    class MicropostsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :logged_in_user, only: [:create, :destroy]
      before_action :correct_user, only: :destroy

      def create
        @micropost = current_user.microposts.build(micropost_params)
        if @micropost.save
          render json: @micropost, status: :created
        else
          render json: @micropost.errors, status: :unprocessale_entity
        end
      end

      def destroy
        @micropost.destroy
        head :no_content
      end

      private
        def micropost_params
          params.require(:micropost).permit(:content, :picture)
        end

        def correct_user
          @micropost = current_user.microposts.find_by(id: params[:id])
          render json: @micropost.errors, status: :not_found if @micropost.nil?
        end
    end
  end
end
