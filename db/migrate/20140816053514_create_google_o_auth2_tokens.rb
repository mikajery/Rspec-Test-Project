class CreateGoogleOAuth2Tokens < ActiveRecord::Migration
  def change
    create_table :google_o_auth2_tokens do |t|
      t.belongs_to :google_api, polymorphic: true

      t.text :access_token
      t.integer :expires_in
      t.integer :issued_at
      t.text :refresh_token

      t.datetime :expires_at

      t.timestamps
    end

    add_index :google_o_auth2_tokens, [:google_api_id, :google_api_type],
                                      name: 'index_google_o_auth2_tokens_on_google_api'
  end
end
