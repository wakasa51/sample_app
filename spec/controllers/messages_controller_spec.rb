require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:michael){ create(:michael) }
  let(:archer){ create(:archer) }
  let(:air){ create(:air, from_user_id: michael.id, to_user_id: archer.id) }
  let(:bus){ create(:bus, from_user_id: archer.id, to_user_id: michael.id) }
  let(:car){ create(:car, from_user_id: michael.id, to_user_id: archer.id) }

  def log_in_as(user)
    session[:user_id] = user.id
  end

  describe 'GET#show' do
    it 'has variables of user, opponent, messages' do
      air
      log_in_as(michael)
      get :show, params: { user_id: michael.id, id:archer.id  }
      expect(assigns(:user)).to eq michael
      expect(assigns(:opponent_user)).to eq archer
      expect(assigns(:messages)).to match_array([air])
    end

    it 'renders the show template' do
      log_in_as(michael)
      get :show, params: { user_id: michael.id, id:archer.id  }
      expect(response).to render_template :show
    end
  end

  describe 'GET#index' do
    it 'has variables of users' do
      archer
      air
      log_in_as(michael)
      get :index, params: { user_id: michael.id }
      expect(assigns(:message_users)).to match_array([archer])
    end

    it 'renders the index template' do
      log_in_as(michael)
      get :index, params: { user_id: michael.id }
      expect(response).to render_template :index
    end
  end

  describe 'POST#create' do
    context 'with invalid attributes' do
      it 'should redirect login path when not logged in' do
        post :create, params: { user_id: michael.id, message: { content: "Valid message", to_user_id: archer.id } }
        expect(response).to redirect_to login_url
      end

      it 'does not save the new message in the database when not logged in' do
          expect { post :create, params: { user_id: michael.id, message: { content: "Valid message", to_user_id: archer.id } } }.to_not change { Message.count }
      end
    end

    context 'with valid attributes' do
      it 'saves the new message when logged in' do
        log_in_as(michael)
        expect { post :create, params: { user_id: michael.id, message: { content: "Valid message", to_user_id: archer.id } } }.to change{ Message.count }.by(1)
      end

      it 'redirects to the show template' do
        log_in_as(michael)
        post :create, params: { user_id: michael.id, message: { content: "Valid message", to_user_id: archer.id } }
        expect(response).to redirect_to user_message_url(id: archer.id)
      end
    end
  end

  describe 'POST#delete' do
    context 'with valid params' do
      it 'delete a message' do
        log_in_as(michael)
        air
        expect { delete :destroy, params: { user_id: michael.id, id: archer.id, message_num: air.id } }.to change{ Message.count }.by(-1)
      end

      it 'redirects to the show template with success flash' do
        log_in_as(michael)
        air
        delete :destroy, params: { user_id: michael.id, id: archer.id, message_num: air.id }
        expect(response).to redirect_to user_message_url
        expect(flash[:success]).not_to be_empty
      end
    end

    context 'with invalid params' do
      it 'redirects to the show template with danger flash' do
        log_in_as(michael)
        air
        delete :destroy, params: { user_id: michael.id, id: archer.id }
        expect(response).to redirect_to user_message_url
        expect(flash[:danger]).not_to be_empty
      end
    end
  end
end
