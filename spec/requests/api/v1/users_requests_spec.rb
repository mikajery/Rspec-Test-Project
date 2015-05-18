require 'rails_helper'

describe Api::V1::UsersController, :type => :request do

  describe ".create" do
    context "when the user is already signed in" do
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      before do
        post '/api/v1/users', :email => user.email, :password => user.password
      end

      it 'responds with the already_have_account status code' do
        expect(response.status).to eq($config.http_errors[:already_have_account][:status_code])
      end

      it 'returns the already_have_account message' do
        expect(response.body).to eq($config.http_errors[:already_have_account][:description])
      end

    end #__End of context "when the user is already signed in"__
    context "when the user already in use" do
      let!(:user) { FactoryGirl.create(:user) }

      context "when the exception message is the email unique violation" do
        before do
          post '/api/v1/users', :email => user.email, :password => user.password
        end

        it 'responds with the email in use status code' do
          expect(response.status).to eq($config.http_errors[:email_in_use][:status_code])
        end

        it 'returns the email in use message' do
          expect(response.body).to eq($config.http_errors[:email_in_use][:description])
        end
      end #__End of context "when the exception message is the email unique violation"__

      context "when the exception message is not email unique violation" do
        before do
          allow_any_instance_of(ActiveRecord::RecordNotUnique).to receive(:message) { "error" }
        end

        it 'raises the unique violation' do
          expect { post '/api/v1/users', :email => user.email, :password => user.password }.to raise_error
        end
      end #__End of context "when the exception message is not email unique violation"__
    end #__End of context "when the user already in use"__

    context "when the user is created successfully" do
      it 'creates new user with the email and password' do
        beforeUserCount = User.count
        post '/api/v1/users', :email => "user@email.com", :password => "password"
        expect(User.count).to eq(beforeUserCount + 1)
        expect(User.last.email).to eq("user@email.com")
      end

      it 'signs in with the user' do
        beforeUserAuthKeyCount = UserAuthKey.count
        post '/api/v1/users', :email => "user@email.com", :password => "password"
        expect(UserAuthKey.count).to eq(beforeUserAuthKeyCount + 1)
      end

      it 'renders the "api/v1/users/show" rabl' do
        expect( post '/api/v1/users', :email => "user@email.com", :password => "password" ).to render_template('api/v1/users/show')
      end
    end #__End of context "when the user is created successfully"__

    context "when the user is not created successfully" do
      let!(:user) { FactoryGirl.create(:user) }

      before do
        allow(User).to receive(:api_create) { [user, false] }
        post '/api/v1/users', :email => "user@email.com", :password => "password"
      end

      it 'responds with the invalid_email_or_password status code' do
        expect(response.status).to eq($config.http_errors[:invalid_email_or_password][:status_code])
      end

      it 'returns the invalid_email_or_password message' do
        expect(response.body).to eq($config.http_errors[:invalid_email_or_password][:description])
      end
    end #__End of context "when the user is not created successfully"__

    context "when the other exception raises" do
      before do
        allow(UserAuthKey).to receive(:secure_hash) {
          raise Exception
        }
      end

      it 'destroys the created user' do
        expect_any_instance_of(User).to receive(:destroy)
        expect { post '/api/v1/users', :email => "user@email.com", :password => "password" }.to raise_error
      end

      it 'raises the exception' do
        expect { post '/api/v1/users', :email => "user@email.com", :password => "password" }.to raise_error
      end

    end #__End of context "when the other exception raises"__
  end #__End of describe ".create"__

  describe ".update" do
    context 'when the user is NOT signed in' do
      before do
        patch '/api/v1/users/update'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'updates the profile_picture field with the params' do
        params = { :profile_picture => "profile picture" }
        patch '/api/v1/users/update', params
        user.reload
        expect( user.profile_picture ).to eq( params[:profile_picture] )
      end

      it 'updates the name field with the params' do
        params = { :name => "user name" }
        patch '/api/v1/users/update', params
        user.reload
        expect( user.name ).to eq( params[:name] )
      end

      it 'renders the "api/v1/users/show" rabl' do
        expect( patch '/api/v1/users/update' ).to render_template('api/v1/users/show')
      end

      context "when the exception raises" do
        before do
          allow_any_instance_of(User).to receive(:update_attributes!) {
            raise Exception
          }
          patch '/api/v1/users/update'
        end

        it 'responds with the user_update_error status code' do
          expect(response.status).to eq($config.http_errors[:user_update_error][:status_code])
        end

        it 'returns the user_update_error message' do
          expect(response.body).to eq($config.http_errors[:user_update_error][:description])
        end
      end #__End of context "when the exception raises"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".update"__

  describe ".current" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/users/current'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'renders the "api/v1/users/show" rabl' do
        expect( get '/api/v1/users/current' ).to render_template('api/v1/users/show')
      end

      xit 'renders the current user' do
        get '/api/v1/users/current'
        result = JSON.parse(response.body)
        expect(result["email"]).to eq(user.email)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".current"__

  describe ".installed_apps" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/users/installed_apps'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:installed_app) { FactoryGirl.create(:installed_app, user: user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'renders the "api/v1/installed_apps/index" rabl' do
        expect( get '/api/v1/users/installed_apps' ).to render_template('api/v1/installed_apps/index')
      end

      it 'renders the installed apps' do
        get '/api/v1/users/installed_apps'

        result = JSON.parse(response.body).first
        expect( result["permissions_email_headers"] ).to eq( installed_app.permissions_email_headers )
        expect( result["permissions_email_content"] ).to eq( installed_app.permissions_email_content )
        expect( result["installed_app_subclass_type"] ).to eq( installed_app.installed_app_subclass_type )
        expect( result["app"]["uid"] ).to eq( installed_app.app.uid )
        expect( result["app"]["name"] ).to eq( installed_app.app.name )
        expect( result["app"]["description"] ).to eq( installed_app.app.description )
        expect( result["app"]["callback_url"] ).to eq( installed_app.app.callback_url )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".installed_apps"__

  describe ".declare_email_bankruptcy" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/users/declare_email_bankruptcy'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, user: user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      context "when the inbox label exists" do
        before do
          allow_any_instance_of(GmailAccount).to receive(:inbox_folder) { true }
        end

        it 'destroys all the email folder mappings' do
          expect_any_instance_of(EmailFolderMapping::ActiveRecord_Relation).to receive(:destroy_all)
          post '/api/v1/users/declare_email_bankruptcy'
        end
      end #__End of context "when the inbox label exists"__

      it 'should response with a 401 status' do
        post '/api/v1/users/declare_email_bankruptcy'
        expect(response.status).to eq(200)
      end

      it 'renders the empty hash' do
        post '/api/v1/users/declare_email_bankruptcy'
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".declare_email_bankruptcy"__

  describe ".upload_attachment_post" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/users/upload_attachment_post'
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'creates new EmailAttachmentUpload' do
        expect(EmailAttachmentUpload.count).to eq(0)
        get '/api/v1/users/upload_attachment_post'
        expect(EmailAttachmentUpload.count).to eq(1)
      end

      it 'saves the user field of the EmailAttachmentUpload to the current user' do
        get '/api/v1/users/upload_attachment_post'
        expect(EmailAttachmentUpload.first.user).to eq(user)
      end

      it 'should response with a 200 status' do
        get '/api/v1/users/upload_attachment_post'
        expect(response.status).to eq(200)
      end

      it 'renders the presigned post url' do
        email_attachment_upload = EmailAttachmentUpload.new
        email_attachment_upload.user = user
        email_attachment_upload.save!
        presigned_post = email_attachment_upload.presigned_post()

        allow_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post) { presigned_post }

        get '/api/v1/users/upload_attachment_post'

        result = JSON.parse(response.body)

        expect(result["url"]).to eq(presigned_post.url.to_s)
      end

      it 'renders the presigned post fields' do
        email_attachment_upload = EmailAttachmentUpload.new
        email_attachment_upload.user = user
        email_attachment_upload.save!
        presigned_post = email_attachment_upload.presigned_post()

        allow_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post) { presigned_post }

        get '/api/v1/users/upload_attachment_post'

        result = JSON.parse(response.body)

        expect(result["fields"]).to eq(presigned_post.fields)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".upload_attachment_post"__
end
