require 'rails_helper'

RSpec.describe DevAppsController, type: :controller do
  let(:michael){ create(:michael) }
  let(:archer){ create(:archer) }
  let(:twtr){ create(:twtr, user_id: michael.id) }
  let(:ggle){ create(:ggle, user_id: archer.id)}

  def log_in_as(user)
    session[:user_id] = user.id
  end

  describe 'GET#show' do
    it 'has variables of dev_app' do
        log_in_as(michael)
        get :show, params: { user_id: michael.id, id: twtr.id }
        expect(assigns(:dev_app)).to eq twtr
      end

    it 'renders the show template' do
      log_in_as(michael)
      get :show, params: { user_id: michael.id, id: twtr.id }
      expect(response).to render_template :show
    end
  end

  describe 'GET#index' do
    it 'has variables of dev_apps' do
      log_in_as(michael)
      get :index, params: { user_id: michael.id }
      expect(assigns(:dev_apps)).to match_array([twtr])
    end

    it 'renders the index template' do
      log_in_as(michael)
      get :index, params: { user_id: michael.id }
      expect(response).to render_template :index
    end
  end

  describe 'GET#new' do
    it 'has variables of developer' do
      log_in_as(michael)
      get :new, params: { user_id: michael.id }
      expect(assigns(:developer)).to eq michael
    end

    it 'renders the new template' do
      log_in_as(michael)
      get :new, params: { user_id: michael.id }
      expect(response).to render_template :new
    end
  end

  describe 'GET#edit' do
    it 'has variables of dev_app' do
      log_in_as(michael)
      get :edit, params: { user_id: michael.id, id: twtr.id }
      expect(assigns(:dev_app)).to eq twtr
    end

    it 'renders the edit template' do
      log_in_as(michael)
      get :edit, params: { user_id: michael.id, id: twtr.id }
      expect(response).to render_template :edit
    end
  end

  describe 'POST#create' do
    before do
      log_in_as(michael)
    end

    context 'with valid attributes' do
      it 'saves the new dev_app' do
        expect { post :create, params: { user_id: michael.id, dev_app: { app_name: "sampleapp", contact_mail: "sample@con.com", callback_url: "sample.com" } } }.to change{ DevApp.count }.by(1)
      end

      it 'render index' do
        post :create, params: { user_id: michael.id, dev_app: { app_name: "sampleapp", contact_mail: "sample@con.com", callback_url: "sample.com" } }
        expect(response).to redirect_to user_dev_apps_url
      end

      it "flash[:success] includes a message" do
        post :create, params: { user_id: michael.id, dev_app: { app_name: "sampleapp", contact_mail: "sample@con.com", callback_url: "sample.com" } }
        expect(flash[:success]).not_to be_empty
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new dev app' do
        expect { post :create, params: { user_id: michael.id, dev_app: { app_name: "", contact_mail: "sample@con.com", callback_url: " " } } }.to_not change { DevApp.count }
      end

      it 'render new' do
        post :create, params: { user_id: michael.id, dev_app: { app_name: "", contact_mail: "sample@con.com", callback_url: " " } }
        expect(response).to render_template :new
      end
    end
  end

  describe 'POST#delete' do
    before do
      log_in_as(michael)
    end

    context 'with valid params' do
      let(:valid_attributes){ { id: twtr.id, user_id: michael.id } }

      it 'delete a dev app' do
        twtr
        expect { delete :destroy, params: valid_attributes }.to change{ DevApp.count }.by(-1)
      end

      it 'redirect to index' do
        delete :destroy, params: valid_attributes
        expect(response).to redirect_to user_dev_apps_url
      end

      it "flash[:success] includes a message" do
        delete :destroy, params: valid_attributes
        expect(flash[:success]).not_to be_empty
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes){ { id: 10000, user_id: michael.id } }

      it 'does not delete a dev app' do
        twtr
        expect { delete :destroy, params: invalid_attributes }.not_to change{ DevApp.count }
      end

      it 'redirect to index' do
        delete :destroy, params: invalid_attributes
        expect(response).to redirect_to user_dev_apps_url
      end

      it "flash[:success] includes a message" do
        delete :destroy, params: invalid_attributes
        expect(flash[:danger]).not_to be_empty
      end
    end
  end

  describe 'PATCH#update' do
    before do
      log_in_as(michael)
    end

    context 'with valid attributes' do
      let(:valid_update_attributes){ { user_id: michael.id, id: twtr.id, reissue_secret: 1, dev_app: { app_name: "twwwiiiitttteeeer", contact_mail: twtr.contact_mail, callback_url: twtr.callback_url } } }

      it "locates the requested dev_app" do
        patch :update, params: valid_update_attributes
        expect(assigns(:dev_app)).to eq(twtr)
      end

      it 'saves the update attributes' do
        patch :update, params: valid_update_attributes
        twtr.reload
        expect(twtr.app_name).to eq "twwwiiiitttteeeer"
        expect(twtr.consumer_secret).not_to eq "tanoshitwtr"
      end

      it 'redirect to index' do
        patch :update, params: valid_update_attributes
        expect(response).to redirect_to user_dev_apps_url
      end
    end

    context 'with invalid attributes' do
      let(:invalid_update_attributes){ { user_id: michael.id, id: twtr.id, reissue_secret: 1, dev_app: { app_name: "invalid", contact_mail: "", callback_url: twtr.callback_url } } }

      it 'does not update the dev app' do
        patch :update, params: invalid_update_attributes
        twtr.reload
        expect(twtr.app_name).not_to eq "twwwiiiitttteeeer"
        expect(twtr.consumer_secret).to eq "tanoshitwtr"
      end

      it 'render edit' do
        patch :update, params: invalid_update_attributes
        expect(response).to render_template :edit
      end
    end
  end
end
