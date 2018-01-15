require 'rails_helper'

RSpec.describe LinkedAppsController, type: :controller do
  let(:michael){ create(:michael) }
  let(:lana){ create(:lana) }
  let(:archer){ create(:archer) }
  let(:twtr){ create(:twtr, user_id: michael.id) }
  let(:ggle){ create(:ggle, user_id: archer.id)}
  let(:saisyo){ create(:saisyo, user_id: michael.id, dev_app_id: ggle.id)}
  let(:tsugi){ create(:tsugi, user_id: lana.id, dev_app_id: twtr.id) }
  let(:digest){ OpenSSL::HMAC.new(ggle.consumer_id, 'sha256') }
  let(:signature){ digest.update(ggle.consumer_secret).to_s }

  def log_in_as(user)
    session[:user_id] = user.id
  end

  describe 'GET#index' do
    it 'has variables of linked_apps and user' do
      saisyo
      log_in_as(michael)
      get :index, params: { user_id: michael.id }
      expect(assigns(:linked_apps)).to match_array([ggle])
      expect(assigns(:user)).to eq michael

    end

    it 'renders the index template' do
      log_in_as(michael)
      get :index, params: { user_id: michael.id }
      expect(response).to render_template :index
    end
  end

  describe 'GET#new' do
    let(:new_attributes){ { user_id: michael.id, consumer_id: ggle.consumer_id, signature: signature } }

    it 'has variables of user and consumer' do
      get :new, params: new_attributes
      expect(assigns(:user)).to eq michael
      expect(assigns(:consumer)).to eq ggle
    end

    it 'renders the new template' do
      get :new, params: new_attributes
      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do
    context 'with valid attributes' do
      let(:valid_create_attributes){ { dev_app_id: ggle.id, user_id: michael.id, accept_user: { email: michael.email, password: "password" } } }

      it 'saves the new linked_app when does not logged in' do
        expect { post :create, params: valid_create_attributes }.to change{ LinkedApp.count }.by(1)
      end

      it 'saves the new linked_app when logged in' do
        log_in_as(michael)
        valid_create_attributes[:accept_user][:email] = nil
        valid_create_attributes[:accept_user][:password] = nil
        expect { post :create, params: valid_create_attributes }.to change{ LinkedApp.count }.by(1)
      end

      it 'redirect to callback_url' do
        post :create, params: valid_create_attributes
        expect(response).to redirect_to ggle.callback_url
      end

      it "flash[:success] includes a message" do
        post :create, params: valid_create_attributes
        expect(flash[:success]).not_to be_empty
      end
    end

    context 'with invalid attributes' do
      let(:invalid_create_attributes){ { dev_app_id: 1000, user_id: michael.id, accept_user: { email: michael.email, password: "password" } } }

      it 'does not save linked_app when not authenticate user' do
        invalid_create_attributes[:accept_user][:password] = nil
        expect { post :create, params: invalid_create_attributes }.to_not change { DevApp.count }
      end

      it 'render new and flash[:danger] not empty when not authenticate user' do
        invalid_create_attributes[:accept_user][:password] = nil
        post :create, params: invalid_create_attributes
        expect(response).to render_template :new
        expect(flash[:danger]).not_to be_empty
      end

      it 'does not save linked_app when invalid dev_app_id' do
        expect { post :create, params: invalid_create_attributes }.to_not change { DevApp.count }
      end

      it 'render new and flash[:danger] not empty when invalid dev_app_id' do
        post :create, params: invalid_create_attributes
        expect(response).to render_template :new
        expect(flash[:danger]).not_to be_empty
      end
    end
  end

  describe 'POST#delete' do
    before do
      log_in_as(michael)
    end

    context 'with valid params' do
      let(:valid_attributes){ { id: ggle.id, user_id: michael.id } }

      it 'delete a linked_app' do
        saisyo
        expect { delete :destroy, params: valid_attributes }.to change{ LinkedApp.count }.by(-1)
      end

      it 'redirect to index' do
        saisyo
        delete :destroy, params: valid_attributes
        expect(response).to redirect_to user_linked_apps_url
      end

      it "flash[:success] includes a message" do
        saisyo
        delete :destroy, params: valid_attributes
        expect(flash[:success]).not_to be_empty
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes){ { id: 10000, user_id: michael.id } }

      it 'does not delete a linked_app' do
        saisyo
        expect { delete :destroy, params: invalid_attributes }.not_to change{ DevApp.count }
      end

      it 'redirect to index' do
        saisyo
        delete :destroy, params: invalid_attributes
        expect(response).to redirect_to user_linked_apps_url
      end

      it "flash[:success] includes a message" do
        saisyo
        delete :destroy, params: invalid_attributes
        expect(flash[:danger]).not_to be_empty
      end
    end
  end
end
