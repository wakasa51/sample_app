class LinkedAppsController < ApplicationController
  before_action :logged_in_user, only: [:index, :destroy]
  before_action :correct_link, only: :destroy

  def index
    @user = User.find(params[:user_id])
    @linked_apps = @user.linked_apps.paginate(page:params[:page])
  end

  def new
    @accept_user = User.new
    @user = User.find(params[:user_id])
    @consumer = DevApp.find_by(consumer_id: params[:consumer_id])
    @signature = params[:signature]
    redirect_to request.referrer || root_url unless check_consumer_id_and_signature?(@consumer, @signature)
  end

  def create
    @user = current_user || authenticate_user
    if @user == nil
      flash[:danger] = "Sorry... Cannot logged in. Please logged in again!"
      @accept_user = User.new
      render 'new'
    else
      dev_app_id = params[:dev_app_id].to_i
      @linked_app = @user.linking_apps.build(dev_app_id: dev_app_id)
      if @linked_app.save
        flash[:success] = "Accept Application!"
        @consumer = DevApp.find(dev_app_id)
        redirect_to @consumer.callback_url
      else
        flash[:danger] = "Sorry... Cannot accept application."
        @accept_user = User.new
        render 'new'
      end
    end
  end

  def destroy
    @linking_app.destroy
    flash[:success] = "Deleted the registration"
    redirect_to user_linked_apps_url
  end

  private
    def check_consumer_id_and_signature?(consumer, signature)
      if consumer
        key = consumer.consumer_secret
        value = consumer.consumer_id
        digest = OpenSSL::HMAC.new(value, 'sha256')
        if signature == digest.update(key).to_s
          return true
        end
      end
      return false
    end

    def correct_link
      @linking_app = current_user.linking_apps.find_by(user_id: params[:user_id], dev_app_id: params[:id])
      if @linking_app.nil?
        flash[:danger] = "Cannot delete the link"
        redirect_to user_linked_apps_url
      end
    end

    def authenticate_user
      if params[:accept_user] == nil
        return nil
      end
      user_params = params.require(:accept_user).permit(:email, :password)
      user = User.find_by(email: user_params[:email])
      return user if user.authenticate(user_params[:password])
      return nil
    end
end
