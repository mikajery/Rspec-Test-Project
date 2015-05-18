require 'rails_helper'

describe UsersController, :type => :request do

  describe ".new" do
    context 'when the user is NOT signed in' do
      let!(:url) {
        gmail_o_auth2_url(true)
      } 

      it 'redirects to the gmail oauth2 url' do
        url.gsub!(/localhost:4000/, 'www.example.com')

        get signup_path

        expect(response).to redirect_to url
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do 
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'produces the flash message' do
        get signup_path

        expect(flash[:info]).to eq('You already have an account!')
      end

      it 'redirects to the root url' do
        get signup_path

        expect(response).to redirect_to root_url
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".new"__ 

  describe ".create" do
    let!(:user) { FactoryGirl.create(:user) }

    context 'when the user is NOT signed in' do
      it 'creates new user from the params' do
        expect(User).to receive(:create_from_post)
        post users_path
      end

      context "when creates new user successfully" do
        before do
          allow(User).to receive(:create_from_post).and_return([user, true])
        end

        it 'signs in' do
          expect(UserAuthKey).to receive(:new).and_return(UserAuthKey.new())
          post users_path
        end

        it 'produces the flash message' do
          post users_path

          expect(flash[:success]).to eq("Welcome to #{$config.service_name}!")
        end
        
        it 'redirects to the root' do
          post users_path
          expect(response).to redirect_to root_url
        end
      end #__End of context "when creates new user successfully"__

      context "when fails to create new user" do
        before do
          allow(User).to receive(:create_from_post).and_return([user, false])
        end

        it 'renders the new page' do
          expect( post users_path ).to render_template('users/new')
        end
      end #__End of context "when fails to create new user"__

      context "for the unique violation exception" do
        before do
          allow(User).to receive(:create_from_post) { 
            raise  ActiveRecord::RecordNotUnique.new(1,2)
          }
          allow(User).to receive(:get_unique_violation_error).and_return("unique violation")
        end

        it 'produces the unique violation error as flash message' do
          post users_path
          expect(flash.now[:danger]).to eq("unique violation")
        end

        it 'renders the new page' do
          expect( post users_path ).to render_template('users/new')
        end
      end #__End of context "for the unique violation exception"__

      context "for the exception" do
        before do
          allow(User).to receive(:create_from_post).and_return([user, true])
          allow(UserAuthKey).to receive(:new_key) { 
            raise Exception
          }
        end

        it 'produces the danger flash message' do
          post users_path
          expect(flash.now[:danger]).to eq(I18n.t(:error_message_default).html_safe)
        end

        it 'renders the new page' do
          expect( post users_path ).to render_template('users/new')
        end

        context "when the user exists" do
          it 'destroys the user' do
            expect_any_instance_of(User).to receive(:destroy)
            post users_path
          end
        end
      end #__End of context "for the unique violation exception"__
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do 
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'produces the flash message' do
        post users_path

        expect(flash[:info]).to eq('You already have an account!')
      end

      it 'redirects to the root url' do
        post users_path

        expect(response).to redirect_to root_url
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create"__ 

  describe ".reset_password" do
    it 'renders the new page' do
      expect( get reset_password_path ).to render_template('users/reset_password')
    end
  end #__End of describe ".reset_password"__ 
end
