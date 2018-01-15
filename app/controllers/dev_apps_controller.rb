class DevAppsController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user,   only: :destroy

  def index
    @developer = User.find(params[:user_id])
    @dev_apps = @developer.dev_apps.paginate(page:params[:page])
  end

  def show
    @dev_app = DevApp.find(params[:id])
  end

  def new
    @developer = User.find(params[:user_id])
    @dev_app = @developer.dev_apps.build(contact_mail: @developer.email)
  end

  def create
    @dev_app = current_user.dev_apps.build(dev_app_params)
    @dev_app.consumer_id = new_token
    @dev_app.consumer_secret = new_token + new_token
    if @dev_app.save
      flash[:success] = "Application Registered! Consumer ID is #{@dev_app.consumer_id} Consumer Secret is #{@dev_app.consumer_secret}"
      redirect_to user_dev_apps_url
    else
      render 'new'
    end
  end

  def edit
    @dev_app = DevApp.find(params[:id])
  end

  def update
    @dev_app = DevApp.find(params[:id])
    @dev_app.consumer_secret = new_token + new_token if params[:reissue_secret]
    if @dev_app.update_attributes(edit_dev_app_params)
      flash[:success] = "Update information! Consumer ID is #{@dev_app.consumer_id} Consumer Secret is #{@dev_app.consumer_secret}"
      redirect_to user_dev_apps_url
    else
      render 'edit'
    end
  end

  def destroy
    @dev_app.destroy
    flash[:success] = "Deleted the registration"
    redirect_to user_dev_apps_url
  end

  private
    def dev_app_params
      params.require(:dev_app).permit(:app_name, :contact_mail, :callback_url)
    end

    def edit_dev_app_params
      params.require(:dev_app).permit(:app_name, :contact_mail, :callback_url)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end

    def correct_user
      @dev_app = current_user.dev_apps.find_by(id: params[:id])
      if @dev_app.nil?
        flash[:danger] = "Cannot delete the app"
        redirect_to user_dev_apps_url
      end
    end
end
