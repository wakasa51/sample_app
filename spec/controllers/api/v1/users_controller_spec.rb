require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:michael){ create(:michael) }
  let(:michael_attributes) { { name: michael.name, email: michael.email, password: michael.password, password_confirmation: michael.password_confirmation, follow_notice: 0 } }
  let(:lana){ create(:lana) }
  let(:archer){ create(:archer) }
  let(:ant){ create(:ant, user_id: michael.id) }
  let(:baby){ create(:baby, user_id: lana.id)}
  let(:cut){ create(:cut, user_id: archer.id)}
  let(:twtr){ create(:twtr, user_id: michael.id) }
  let(:ggle){ create(:ggle, user_id: archer.id)}
  let(:digest){ OpenSSL::HMAC.new(ggle.consumer_id, 'sha256') }
  let(:signature){ digest.update(ggle.consumer_secret).to_s }

  before do
    create(:one, :follower => michael, :followed => lana)
    create(:three, :follower => lana, :followed => michael)
    create(:four, :follower => archer, :followed => michael)
    create(:saisyo, :user => michael, :dev_app => ggle)
    create(:tsugi, :user => archer, :dev_app => twtr)
  end

  def log_in_as(user)
    session[:user_id] = user.id
  end

  specify 'If user is not logged in, user cannot use API' do
    get :show, params: { id:michael.id  }
    expect(response).to have_http_status(401)
  end

  specify 'If developer do not have valid authticative token, developer cannot use API' do
    get :show, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: "kasuggle"}
    expect(response).to have_http_status(401)
  end

  specify 'If developer has valid authticative token, developer can use API' do
    get :show, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: signature  }
    expect(response).to have_http_status(200)
  end

  specify 'If user is logged in, user can use API' do
    log_in_as(michael)
    get :show, params: { id: michael.id }
    expect(response).to have_http_status(200)
  end

  describe 'GET#show' do
    it 'has variables of users' do
        log_in_as(michael)
        get :show, params: { id: michael.id }
        expect(assigns(:user)).to eq michael
        expect(assigns(:microposts)).to match_array([ant])
      end

    it 'renders the show template' do
      log_in_as(michael)
      get :show, params: { id: michael.id }
      expect(response).to render_template :show
    end
  end

  describe 'GET#index' do
    it 'has variables of users' do
      log_in_as(michael)
      get :index
      expect(assigns(:users)).to match_array([michael, lana, archer])
    end

    it 'renders the index template' do
      log_in_as(michael)
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'POST#create' do
    context 'with valid attributes' do
      it 'saves the new users' do
        expect { post :create, params: { consumer_id: ggle.consumer_id, signature: signature, user: { name: "Sun", email: "Sun@gmama-.com", password: "foomama", password_confirmation: "foomama", follow_notice: 1 } } }.to change{ User.count }.by(1)
      end

      it 'render 202 created' do
        post :create, params: { consumer_id: ggle.consumer_id, signature: signature, user: { name: "Sun", email: "Sun@gmama-.com", password: "foomama", password_confirmation: "foomama", follow_notice: 1 } }
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new users' do
        expect { post :create, params: { consumer_id: ggle.consumer_id, signature: signature, user: { name: " ", email: "Sun@com..^-f^-", password: "foomama", password_confirmation: "fooma", follow_notice: 1 } } }.to_not change { Message.count }
      end

      it 'render 422 unprocessale entity' do
        post :create, params: { consumer_id: ggle.consumer_id, signature: signature, user: { name: "  ", email: "Sun@", password: "fo0mama", password_confirmation: "fooma", follow_notice: 1 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  #現状、deleteは管理者しか使えない機能なので、APIとしては一旦凍結 
  # describe 'POST#delete' do
  #   context 'with valid params' do
  #     it 'delete a message' do
  #       digest = OpenSSL::HMAC.new("gglekasu", 'sha256')
  #       signature = digest.update("kasuggle").to_s
  #       expect { delete :destroy, params: { consumer_id: ggle.consumer_id, signature: signature, id: michael.id }}.to change{ User.count }.by(-1)
  #     end
  #
  #     it 'render 204 no content' do
  #       digest = OpenSSL::HMAC.new("gglekasu", 'sha256')
  #       signature = digest.update("kasuggle").to_s
  #       delete :destroy, params: { consumer_id: ggle.consumer_id, signature: signature, id: michael.id }
  #       expect(response).to have_http_status(204)
  #     end
  #   end
  # end

  describe 'GET#following' do
    it 'has variables of users' do
        log_in_as(michael)
        get :following, params: { id: michael.id }
        expect(assigns(:users)).to match_array([lana])
      end

    it 'renders the show template' do
      log_in_as(michael)
      get :following, params: { id: michael.id }
      expect(response).to render_template :user_following
    end
  end

  describe 'GET#followers' do
    it 'has variables of users' do
        log_in_as(michael)
        get :followers, params: { id: michael.id }
        expect(assigns(:users)).to match_array([lana, archer])
      end

    it 'renders the show template' do
      log_in_as(michael)
      get :followers, params: { id: michael.id }
      expect(response).to render_template :user_followers
    end
  end

  describe 'GET#feed' do
    it 'has variables of feed items' do
        log_in_as(michael)
        get :feed, params: { id: michael.id }
        expect(assigns(:feed_items)).to match_array([baby])
      end

    it 'renders the show template' do
      log_in_as(michael)
      get :feed, params: { id: michael.id }
      expect(response).to render_template :user_feed
    end
  end

  describe 'PATCH#update' do
    context 'with valid attributes' do
      it "locates the requested user" do
        patch :update, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: signature, user: michael_attributes }
        expect(assigns(:user)).to eq(michael)
      end

      it 'saves the update attributes' do
        michael_attributes[:name] = "Hartl Example"
        patch :update, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: signature, user: michael_attributes }
        michael.reload
        expect(michael.name).to eq "Hartl Example"
      end

      it 'render 202 created' do
        michael_attributes[:name] = "Hartl Example"
        patch :update, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: signature, user: michael_attributes }
        expect(response).to have_http_status(200)
      end
    end

    context 'with invalid attributes' do
      it 'does not update the user' do
        michael_attributes[:name] = "Hartl Example"
        michael_attributes[:email] = "   @  @@ "
        patch :update, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: signature, user: michael_attributes }
        michael.reload
        expect(michael.name).not_to eq "Hartl Example"
        expect(michael.name).to eq "Michael Example"
      end

      it 'render 422 unprocessale entity' do
        michael_attributes[:name] = "Hartl Example"
        michael_attributes[:email] = "   @  @@ "
        patch :update, params: { id: michael.id, consumer_id: ggle.consumer_id, signature: signature, user: michael_attributes }
        expect(response).to have_http_status(422)
      end
    end
  end
end
