class MessagesController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :create, :destroy]
  before_action :correct_user,   only: :destroy

  def index
    @message_users = User.where("id IN (SELECT to_user_id FROM messages WHERE from_user_id = ?) OR id IN (SELECT from_user_id FROM messages WHERE to_user_id = ?)", params[:user_id], params[:user_id]).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:user_id])
    @opponent_user = User.find(params[:id])
    @messages = Message.where("(to_user_id = ? AND from_user_id = ?) OR (from_user_id = ? AND to_user_id = ?)", @user.id, @opponent_user.id, @user.id, @opponent_user.id).paginate(page: params[:page])
    @message = current_user.send_messages.build
  end

  def create
    @message = current_user.send_messages.build(message_params)
    if @message.save
      flash[:success] = "Message sent!"
      redirect_to user_message_url(id: @message.to_user_id)
    else
      @messages = []
      render user_message_path
    end
  end

  def destroy
    @message.destroy
    flash[:success] = "Message deleted"
    redirect_to user_message_url
  end

  private
    def message_params
      params.require(:message).permit(:content, :to_user_id)
    end

    def correct_user
      @message = current_user.send_messages.find_by(id: params[:message_num])
      if @message.nil?
        flash[:danger] = "Cannot delete the message"
        redirect_to user_message_url
      end
    end
end
