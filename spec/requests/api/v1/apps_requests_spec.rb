require 'rails_helper'

describe Api::V1::AppsController, :type => :request do
  describe ".test" do
    context 'when the user is NOT signed in' do
      before do
        post "/api/v1/apps/test"
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:sample_app) { FactoryGirl.create(:app) }
      let!(:email) { FactoryGirl.create(:email) }

      before { post '/api/v1/sessions', :email => sample_app.user.email, :password => sample_app.user.password }

      context "with the email_thread params" do
        let!(:params) {
          {
            :email_thread => {
              :emails => {
                "0" => {
                  "snippet" => "snippet 0"
                },
                "1" => {
                  "snippet" => "snippet 1"
                },
                "2" => {
                  "snippet" => "snippet 2"
                }
              }
            }
          }
        }

        before do
          post "/api/v1/apps/test", params
        end

        it 'renders the last email snippet' do
          email_thread = params[:email_thread]
          emails = email_thread[:emails]
          html = "<html><body>HIHIHI!!!!<br />#{emails[(emails.length - 1).to_s]["snippet"]}</body></html>"

          expect( response.body ).to eq(html)
        end

        it "responds with 200 status code" do
          expect(response.status).to eq(200)
        end
      end #__End of context "with the email_thread params"__

      context "with the email params" do
        let!(:params) {
          {
            :email => {
              "snippet" => "snippet 0"
            }
          }
        }

        before do
          post "/api/v1/apps/test", params
        end

        it 'renders the email snippet' do
          email = params[:email]      
          html = "<html><body>HIHIHI!!!!<br />#{email["snippet"]}</body></html>"
          
          expect( response.body ).to eq(html)
        end

        it "responds with 200 status code" do
          expect(response.status).to eq(200)
        end
      end #__End of context "with the email params"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".test"__

  describe ".create" do
    context 'when the user is NOT signed in' do
      before do
        post "/api/v1/apps"
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
      let!(:params) {
        {
          :name => "app name",
          :description => "app description",
          :app_type => "panel",
          :callback_url => "app callback_url"
        }
      }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      context "with the valid params" do
        before do
          post "/api/v1/apps", params
        end

        it 'responses with a 200 status' do
          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          expect( response.body ).to eq( "{}" )
        end

        it 'creates new app' do
          expect( App.count ).to eq(1)
        end
      end #__End of context "with the valid params"__

      context "with the invalid params" do
        context "when the app was already created" do
          let!(:sample_app) { FactoryGirl.create(:app) }
          before do
            allow(App).to receive(:find_or_create_by!) {
              raise ActiveRecord::RecordNotUnique.new(app)
            }

            post "/api/v1/apps", params
          end

          it 'responses with a 200 status' do
            expect(response.status).to eq(200)
          end

          it 'returns the empty hash' do
            expect( response.body ).to eq( "{}" )
          end
        end #__End of context "when the app was already created"__

        context "with the invalid name params" do
          before do
            params[:name] = nil
          end
          
          it 'raises invalid record error' do
            expect { post "/api/v1/apps", params }.to raise_error( ActiveRecord::RecordInvalid )
          end
        end #__End of context "with the invalid name params"__

        context "with the invalid description params" do
          before do
            params[:description] = nil
          end
          
          it 'raises invalid record error' do
            expect { post "/api/v1/apps", params }.to raise_error( ActiveRecord::RecordInvalid )
          end
        end #__End of context "with the invalid name params"__

        context "with the invalid app_type params" do
          before do
            params[:app_type] = nil
          end
          
          it 'raises invalid record error' do
            expect { post "/api/v1/apps", params }.to raise_error( ActiveRecord::RecordInvalid )
          end
        end #__End of context "with the invalid name params"__

        context "with the invalid callback_url params" do
          before do
            params[:callback_url] = nil
          end
          
          it 'raises invalid record error' do
            expect { post "/api/v1/apps", params }.to raise_error( ActiveRecord::RecordInvalid )
          end
        end #__End of context "with the invalid name params"__
      end #__End of context "with the invalid params"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create"__

  describe ".index" do
    context 'when the user is NOT signed in' do
      before do
        get "/api/v1/apps"
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
      let!(:sample_app) { FactoryGirl.create(:app) }
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      it 'renders all the apps' do
        get "/api/v1/apps"
        apps = JSON.parse(response.body)
        result_app = apps.first

        expect(result_app["uid"]).to eq(sample_app.uid)
        expect(result_app["name"]).to eq(sample_app.name)
        expect(result_app["description"]).to eq(sample_app.description)
        expect(result_app["callback_url"]).to eq(sample_app.callback_url)
      end

      it 'renders the api/v1/apps/index rabl' do            
        expect( get "/api/v1/apps" ).to render_template('api/v1/apps/index')
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe ".install" do
    let!(:sample_app) { FactoryGirl.create(:app) }

    context 'when the user is NOT signed in' do
      before do
        post "/api/v1/apps/install/#{sample_app.uid}"
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

      context "with the valid app" do
        it 'creates new InstalledApp' do
          expect( InstalledApp.count ).to eq(0)
          post "/api/v1/apps/install/#{sample_app.uid}"
          expect( InstalledApp.count ).to eq(1)
        end

        it 'creates new InstalledPanelApp' do
          expect( InstalledPanelApp.count ).to eq(0)
          post "/api/v1/apps/install/#{sample_app.uid}"
          expect( InstalledPanelApp.count ).to eq(1)
        end

        it 'saves the installed_app field of the installed_panel_app to the installed_app' do
          post "/api/v1/apps/install/#{sample_app.uid}"
          
          expect(InstalledPanelApp.first.installed_app).to eq(InstalledApp.first)
        end

        it 'saves the installed_app_subclass field of the installed_app to the installed_panel_app' do
          post "/api/v1/apps/install/#{sample_app.uid}"
          
          expect(InstalledApp.first.installed_app_subclass).to eq(InstalledPanelApp.first)
        end

        it 'should response with a 200 status' do
          post "/api/v1/apps/install/#{sample_app.uid}"
          expect(response.status).to eq(200)
        end

        it 'renders the empty hash' do
          post "/api/v1/apps/install/#{sample_app.uid}"
          expect( response.body ).to eq( "{}" )
        end
      end #__End of context "with the valid app"__

      context "with the invalid app" do
        before do
          post "/api/v1/apps/install/invalid-uid"
        end

        it 'responds with the app not found status code' do
          expect(response.status).to eq($config.http_errors[:app_not_found][:status_code])
        end

        it 'returns the app not found message' do
          expect(response.body).to eq($config.http_errors[:app_not_found][:description])
        end
      end #__End of context "with the invalid app"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".install"__

  describe ".uninstall" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:installed_app) { FactoryGirl.create(:installed_app, user: user) }
    let!(:uid) { installed_app.app.uid }

    context 'when the user is NOT signed in' do
      before do
        delete "/api/v1/apps/uninstall/#{uid}"
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      before { post '/api/v1/sessions', :email => user.email, :password => user.password }

      context "with the valid app" do
        it 'deletes the installed app' do
          expect( InstalledApp.count ).to eq(1)
          delete "/api/v1/apps/uninstall/#{uid}"
          expect( InstalledApp.count ).to eq(0)
        end

        it 'should response with a 200 status' do
          delete "/api/v1/apps/uninstall/#{uid}"
          expect(response.status).to eq(200)
        end

        it 'renders the empty hash' do
          delete "/api/v1/apps/uninstall/#{uid}"
          expect( response.body ).to eq( "{}" )
        end
      end #__End of context "with the valid app"__

      context "with the invalid app" do
        before do
          delete "/api/v1/apps/uninstall/invalid-uid"
        end

        it 'responds with the app not found status code' do
          expect(response.status).to eq($config.http_errors[:app_not_found][:status_code])
        end

        it 'returns the app not found message' do
          expect(response.body).to eq($config.http_errors[:app_not_found][:description])
        end
      end #__End of context "with the invalid app"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".uninstall"__

  describe ".destroy" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:sample_app) { FactoryGirl.create(:app, user: user) }

    context 'when the user is NOT signed in' do
      before do
        delete "/api/v1/apps/#{sample_app.uid}"
      end

      it 'should response with a 401 status' do
        expect(response.status).to eq(401)
      end

      it 'should respond with a login message' do
        expect( response.body ).to eq( "Not signed in." )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      context "with the correct user" do        
        before { post '/api/v1/sessions', :email => user.email, :password => user.password }

        context "with the valid app" do
          it 'deletes the app' do
            expect( App.count ).to eq(1)
            delete "/api/v1/apps/#{sample_app.uid}"
            expect( App.count ).to eq(0)
          end

          it 'should response with a 200 status' do
            delete "/api/v1/apps/#{sample_app.uid}"
            expect(response.status).to eq(200)
          end

          it 'renders the empty hash' do
            delete "/api/v1/apps/#{sample_app.uid}"
            expect( response.body ).to eq( "{}" )
          end
        end #__End of context "with the valid app"__

        context "with the invalid app" do
          before do
            delete "/api/v1/apps/invalid-uid"
          end

          it 'responds with the app not found status code' do
            expect(response.status).to eq($config.http_errors[:app_not_found][:status_code])
          end

          it 'returns the app not found message' do
            expect(response.body).to eq($config.http_errors[:app_not_found][:description])
          end
        end #__End of context "with the invalid app"__
      end #__End of context "with the correct user"__

      context "with the incorrect user" do
        let!(:another_user) { FactoryGirl.create(:user) }
        before { post '/api/v1/sessions', :email => another_user.email, :password => another_user.password }
        before do
          delete "/api/v1/apps/#{sample_app.uid}"
        end

        it 'responds with the app not found status code' do
          expect(response.status).to eq($config.http_errors[:app_not_found][:status_code])
        end

        it 'returns the app not found message' do
          expect(response.body).to eq($config.http_errors[:app_not_found][:description])
        end
      end #__End of context "with the incorrect user"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".destroy"__
end
