# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150417134649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apps", force: true do |t|
    t.integer  "user_id"
    t.text     "uid"
    t.text     "name"
    t.text     "description"
    t.text     "app_type"
    t.text     "callback_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apps", ["name"], name: "index_apps_on_name", unique: true, using: :btree
  add_index "apps", ["uid"], name: "index_apps_on_uid", unique: true, using: :btree
  add_index "apps", ["user_id"], name: "index_apps_on_user_id", using: :btree

  create_table "delayed_emails", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.integer  "delayed_job_id"
    t.text     "uid"
    t.text     "tos"
    t.text     "ccs"
    t.text     "bccs"
    t.text     "subject"
    t.text     "html_part"
    t.text     "text_part"
    t.text     "email_in_reply_to_uid"
    t.boolean  "tracking_enabled"
    t.boolean  "bounce_back",           default: false
    t.datetime "bounce_back_time"
    t.text     "bounce_back_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "attachment_s3_keys"
  end

  add_index "delayed_emails", ["delayed_job_id"], name: "index_delayed_emails_on_delayed_job_id", using: :btree
  add_index "delayed_emails", ["email_account_id", "email_account_type"], name: "index_delayed_emails_on_email_account_id_and_email_account_type", using: :btree
  add_index "delayed_emails", ["uid"], name: "index_delayed_emails_on_uid", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "email_attachment_uploads", force: true do |t|
    t.integer  "user_id"
    t.integer  "email_id"
    t.text     "uid"
    t.text     "s3_key"
    t.text     "s3_key_full"
    t.text     "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_attachment_uploads", ["email_id"], name: "index_email_attachment_uploads_on_email_id", using: :btree
  add_index "email_attachment_uploads", ["s3_key"], name: "index_email_attachment_uploads_on_s3_key", unique: true, using: :btree
  add_index "email_attachment_uploads", ["s3_key_full"], name: "index_email_attachment_uploads_on_s3_key_full", unique: true, using: :btree
  add_index "email_attachment_uploads", ["uid"], name: "index_email_attachment_uploads_on_uid", unique: true, using: :btree
  add_index "email_attachment_uploads", ["user_id"], name: "index_email_attachment_uploads_on_user_id", using: :btree

  create_table "email_attachments", force: true do |t|
    t.integer  "email_id"
    t.text     "filename"
    t.text     "content_type"
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "uid"
    t.text     "mime_type"
    t.text     "content_disposition"
    t.text     "sha256_hex_digest"
    t.text     "gmail_attachment_id"
    t.text     "s3_key"
  end

  add_index "email_attachments", ["content_type"], name: "index_email_attachments_on_content_type", using: :btree
  add_index "email_attachments", ["email_id"], name: "index_email_attachments_on_email_id", using: :btree
  add_index "email_attachments", ["uid"], name: "index_email_attachments_on_uid", unique: true, using: :btree

  create_table "email_folder_mappings", force: true do |t|
    t.integer  "email_id"
    t.integer  "email_folder_id"
    t.string   "email_folder_type"
    t.integer  "email_thread_id"
    t.datetime "folder_email_date"
    t.text     "folder_email_draft_id"
    t.datetime "folder_email_thread_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_folder_mappings", ["email_folder_id", "email_folder_type", "email_id"], name: "index_email_folder_mappings_on_email_folder_type_and_email", using: :btree
  add_index "email_folder_mappings", ["email_folder_id", "email_folder_type", "folder_email_thread_date", "email_thread_id", "email_id"], name: "index_email_folder_mappings_sort", using: :btree
  add_index "email_folder_mappings", ["email_folder_id", "email_folder_type"], name: "index_email_folder_mappings_on_email_folder", using: :btree
  add_index "email_folder_mappings", ["email_id", "email_folder_id", "email_folder_type"], name: "index_email_folder_mappings_on_email_and_email_folder", unique: true, using: :btree
  add_index "email_folder_mappings", ["email_thread_id"], name: "index_email_folder_mappings_on_email_thread_id", using: :btree
  add_index "email_folder_mappings", ["folder_email_date", "email_id"], name: "index_email_folder_mappings_on_folder_email_date_and_email_id", using: :btree
  add_index "email_folder_mappings", ["folder_email_date"], name: "index_email_folder_mappings_on_folder_email_date", using: :btree
  add_index "email_folder_mappings", ["folder_email_draft_id"], name: "index_email_folder_mappings_on_folder_email_draft_id", using: :btree
  add_index "email_folder_mappings", ["folder_email_thread_date", "email_id"], name: "index_email_folder_mappings_on_thread_date_and_email_id", using: :btree

  create_table "email_in_reply_tos", force: true do |t|
    t.integer  "email_id"
    t.text     "in_reply_to_message_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_in_reply_tos", ["email_id", "in_reply_to_message_id", "position"], name: "index_email_in_reply_to_on_email_and_in_reply_to_msg_id_and_pos", unique: true, using: :btree
  add_index "email_in_reply_tos", ["email_id"], name: "index_email_in_reply_tos_on_email_id", using: :btree

  create_table "email_recipients", force: true do |t|
    t.integer  "email_id"
    t.integer  "person_id"
    t.integer  "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_recipients", ["email_id", "person_id", "recipient_type"], name: "index_email_recipients_on_email_and_person_and_recipient_type", unique: true, using: :btree
  add_index "email_recipients", ["email_id"], name: "index_email_recipients_on_email_id", using: :btree

  create_table "email_references", force: true do |t|
    t.integer  "email_id"
    t.text     "references_message_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_references", ["email_id", "references_message_id", "position"], name: "index_email_references_on_email_and_references_msg_id_and_pos", unique: true, using: :btree
  add_index "email_references", ["email_id"], name: "index_email_references_on_email_id", using: :btree

  create_table "email_rules", force: true do |t|
    t.integer  "user_id"
    t.text     "uid"
    t.text     "from_address"
    t.text     "to_address"
    t.text     "subject"
    t.text     "list_id"
    t.text     "destination_folder_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_rules", ["from_address", "to_address", "subject", "list_id", "destination_folder_name"], name: "index_email_rules_on_everything", unique: true, using: :btree
  add_index "email_rules", ["uid"], name: "index_email_rules_on_uid", unique: true, using: :btree
  add_index "email_rules", ["user_id"], name: "index_email_rules_on_user_id", using: :btree

  create_table "email_signatures", force: true do |t|
    t.integer  "user_id"
    t.text     "uid"
    t.text     "name"
    t.text     "text"
    t.text     "html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_signatures", ["uid"], name: "index_email_signatures_on_uid", unique: true, using: :btree
  add_index "email_signatures", ["user_id", "name"], name: "index_email_signatures_on_user_id_and_name", unique: true, using: :btree

  create_table "email_template_categories", force: true do |t|
    t.integer  "user_id"
    t.text     "uid"
    t.text     "name"
    t.integer  "email_templates_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_template_categories", ["uid"], name: "index_email_template_categories_on_uid", unique: true, using: :btree
  add_index "email_template_categories", ["user_id", "name"], name: "index_email_template_categories_on_user_id_and_name", unique: true, using: :btree

  create_table "email_templates", force: true do |t|
    t.integer  "user_id"
    t.text     "uid"
    t.text     "name"
    t.text     "text"
    t.text     "html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_template_category_id"
  end

  add_index "email_templates", ["uid"], name: "index_email_templates_on_uid", unique: true, using: :btree
  add_index "email_templates", ["user_id", "name"], name: "index_email_templates_on_user_id_and_name", unique: true, using: :btree

  create_table "email_threads", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "emails_count"
  end

  add_index "email_threads", ["email_account_id", "email_account_type", "uid"], name: "index_email_threads_on_email_account_and_uid", unique: true, using: :btree
  add_index "email_threads", ["email_account_id", "email_account_type"], name: "index_email_threads_on_email_account_id_and_email_account_type", using: :btree
  add_index "email_threads", ["uid"], name: "index_email_threads_on_uid", unique: true, using: :btree

  create_table "email_tracker_recipients", force: true do |t|
    t.integer  "email_tracker_id"
    t.integer  "email_id"
    t.text     "uid"
    t.text     "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_tracker_recipients", ["email_id"], name: "index_email_tracker_recipients_on_email_id", using: :btree
  add_index "email_tracker_recipients", ["email_tracker_id"], name: "index_email_tracker_recipients_on_email_tracker_id", using: :btree
  add_index "email_tracker_recipients", ["uid"], name: "index_email_tracker_recipients_on_uid", unique: true, using: :btree

  create_table "email_tracker_views", force: true do |t|
    t.integer  "email_tracker_recipient_id"
    t.text     "uid"
    t.text     "ip_address"
    t.text     "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_tracker_views", ["email_tracker_recipient_id"], name: "index_email_tracker_views_on_email_tracker_recipient_id", using: :btree
  add_index "email_tracker_views", ["uid"], name: "index_email_tracker_views_on_uid", unique: true, using: :btree

  create_table "email_trackers", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "uid"
    t.text     "email_uids"
    t.text     "email_subject"
    t.datetime "email_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_trackers", ["email_account_id", "email_account_type"], name: "index_email_trackers_on_email_account_id_and_email_account_type", using: :btree
  add_index "email_trackers", ["email_account_id"], name: "index_email_trackers_on_email_account_id", using: :btree
  add_index "email_trackers", ["uid"], name: "index_email_trackers_on_uid", unique: true, using: :btree

  create_table "emails", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.integer  "email_thread_id"
    t.integer  "ip_info_id"
    t.boolean  "auto_filed",                        default: false
    t.boolean  "auto_filed_reported",               default: false
    t.integer  "auto_filed_folder_id"
    t.string   "auto_filed_folder_type"
    t.text     "uid"
    t.text     "draft_id"
    t.text     "message_id"
    t.text     "list_name"
    t.text     "list_id"
    t.boolean  "seen",                              default: false
    t.text     "snippet"
    t.datetime "date"
    t.text     "from_name"
    t.text     "from_address"
    t.text     "sender_name"
    t.text     "sender_address"
    t.text     "reply_to_name"
    t.text     "reply_to_address"
    t.text     "tos"
    t.text     "ccs"
    t.text     "bccs"
    t.text     "subject"
    t.text     "html_part"
    t.text     "text_part"
    t.text     "body_text"
    t.boolean  "has_calendar_attachment",           default: false
    t.integer  "list_subscription_id"
    t.boolean  "bounce_back",                       default: false
    t.datetime "bounce_back_time"
    t.text     "bounce_back_type"
    t.integer  "bounce_back_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auto_file_folder_name"
    t.boolean  "queued_auto_file",                  default: false
    t.integer  "upload_attachments_delayed_job_id"
    t.boolean  "attachments_uploaded",              default: false
  end

  add_index "emails", ["auto_file_folder_name"], name: "index_emails_on_auto_file_folder_name", using: :btree
  add_index "emails", ["auto_filed_folder_id", "auto_filed_folder_type"], name: "index_emails_on_auto_filed_folder_id_and_auto_filed_folder_type", using: :btree
  add_index "emails", ["date", "id"], name: "index_emails_on_date_and_id", order: {"date"=>:desc, "id"=>:desc}, using: :btree
  add_index "emails", ["date"], name: "index_emails_on_date", order: {"date"=>:desc}, using: :btree
  add_index "emails", ["email_account_id", "email_account_type", "draft_id"], name: "index_emails_on_email_account_and_draft_id", unique: true, using: :btree
  add_index "emails", ["email_account_id", "email_account_type", "uid"], name: "index_emails_on_email_account_id_and_email_account_type_and_uid", unique: true, using: :btree
  add_index "emails", ["email_account_id", "email_account_type"], name: "index_emails_on_email_account_id_and_email_account_type", using: :btree
  add_index "emails", ["email_thread_id"], name: "index_emails_on_email_thread_id", using: :btree
  add_index "emails", ["from_address"], name: "index_emails_on_from_address", using: :btree
  add_index "emails", ["id"], name: "index_emails_on_id", where: "(NOT seen)", using: :btree
  add_index "emails", ["ip_info_id"], name: "index_emails_on_ip_info_id", using: :btree
  add_index "emails", ["list_subscription_id"], name: "index_emails_on_list_subscription_id", using: :btree
  add_index "emails", ["message_id"], name: "index_emails_on_message_id", using: :btree
  add_index "emails", ["reply_to_address"], name: "index_emails_on_reply_to_address", using: :btree
  add_index "emails", ["sender_address"], name: "index_emails_on_sender_address", using: :btree
  add_index "emails", ["uid"], name: "index_emails_on_uid", unique: true, using: :btree
  add_index "emails", ["updated_at"], name: "updated_at_index_on_emails", order: {"updated_at"=>:desc}, using: :btree

  create_table "genie_rules", force: true do |t|
    t.integer  "user_id"
    t.text     "uid"
    t.text     "from_address"
    t.text     "to_address"
    t.text     "subject"
    t.text     "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genie_rules", ["from_address", "to_address", "subject", "list_id"], name: "index_genie_rules_on_everything", unique: true, using: :btree
  add_index "genie_rules", ["uid"], name: "index_genie_rules_on_uid", unique: true, using: :btree
  add_index "genie_rules", ["user_id"], name: "index_genie_rules_on_user_id", using: :btree

  create_table "gmail_accounts", force: true do |t|
    t.integer  "user_id"
    t.text     "google_id"
    t.text     "email"
    t.boolean  "verified_email"
    t.datetime "sync_started_time"
    t.text     "last_history_id_synced"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sync_delayed_job_id"
    t.datetime "last_sync_at"
    t.boolean  "sync_lock"
  end

  add_index "gmail_accounts", ["email"], name: "index_gmail_accounts_on_email", using: :btree
  add_index "gmail_accounts", ["google_id"], name: "index_gmail_accounts_on_google_id", unique: true, using: :btree
  add_index "gmail_accounts", ["user_id", "email"], name: "index_gmail_accounts_on_user_id_and_email", unique: true, using: :btree

  create_table "gmail_labels", force: true do |t|
    t.integer  "gmail_account_id"
    t.text     "label_id"
    t.text     "name"
    t.text     "message_list_visibility"
    t.text     "label_list_visibility"
    t.text     "label_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_threads",             default: 0
    t.integer  "num_unread_threads",      default: 0
  end

  add_index "gmail_labels", ["gmail_account_id", "label_id"], name: "index_gmail_labels_on_gmail_account_id_and_label_id", unique: true, using: :btree
  add_index "gmail_labels", ["gmail_account_id", "name"], name: "index_gmail_labels_on_gmail_account_id_and_name", unique: true, using: :btree
  add_index "gmail_labels", ["gmail_account_id"], name: "index_gmail_labels_on_gmail_account_id", using: :btree

  create_table "google_o_auth2_tokens", force: true do |t|
    t.integer  "google_api_id"
    t.string   "google_api_type"
    t.text     "access_token"
    t.integer  "expires_in"
    t.integer  "issued_at"
    t.text     "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "google_o_auth2_tokens", ["google_api_id", "google_api_type"], name: "index_google_o_auth2_tokens_on_google_api", using: :btree

  create_table "imap_folders", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "imap_folders", ["email_account_id", "email_account_type", "name"], name: "index_imap_folders_on_email_account_and_name", unique: true, using: :btree
  add_index "imap_folders", ["email_account_id", "email_account_type"], name: "index_imap_folders_on_email_account", using: :btree

  create_table "installed_apps", force: true do |t|
    t.integer  "installed_app_subclass_id"
    t.string   "installed_app_subclass_type"
    t.integer  "user_id"
    t.integer  "app_id"
    t.boolean  "permissions_email_headers",   default: false
    t.boolean  "permissions_email_content",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "installed_apps", ["installed_app_subclass_id", "installed_app_subclass_type"], name: "installed_apps_index", using: :btree
  add_index "installed_apps", ["user_id", "app_id"], name: "index_installed_apps_on_user_id_and_app_id", unique: true, using: :btree

  create_table "installed_panel_apps", force: true do |t|
    t.text     "panel",      default: "right"
    t.integer  "position",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ip_infos", force: true do |t|
    t.inet     "ip"
    t.text     "country_code"
    t.text     "country_name"
    t.text     "region_code"
    t.text     "region_name"
    t.text     "city"
    t.text     "zipcode"
    t.text     "latitude"
    t.text     "longitude"
    t.text     "metro_code"
    t.text     "area_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fetched",      default: false
  end

  add_index "ip_infos", ["ip"], name: "index_ip_infos_on_ip", using: :btree

  create_table "list_subscriptions", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "uid"
    t.text     "list_name"
    t.text     "list_id"
    t.text     "list_subscribe"
    t.text     "list_subscribe_mailto"
    t.text     "list_subscribe_email"
    t.text     "list_subscribe_link"
    t.text     "list_unsubscribe"
    t.text     "list_unsubscribe_mailto"
    t.text     "list_unsubscribe_email"
    t.text     "list_unsubscribe_link"
    t.text     "list_domain"
    t.datetime "most_recent_email_date"
    t.integer  "unsubscribe_delayed_job_id"
    t.boolean  "unsubscribed",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "list_subscriptions", ["email_account_id", "email_account_type"], name: "email_account_index", using: :btree
  add_index "list_subscriptions", ["email_account_id", "list_id", "list_domain"], name: "index_list_subscriptions_on_ea_id_and_list_id_list_domain", unique: true, using: :btree
  add_index "list_subscriptions", ["email_account_id", "list_unsubscribe"], name: "index_list_subscriptions_on_ea_id_and_list_unsubscribe", unique: true, using: :btree
  add_index "list_subscriptions", ["email_account_id", "list_unsubscribe_email"], name: "index_list_subscriptions_on_ea_id_and_list_unsubscribe_email", unique: true, using: :btree
  add_index "list_subscriptions", ["email_account_id", "list_unsubscribe_link"], name: "index_list_subscriptions_on_ea_id_and_list_unsubscribe_link", unique: true, using: :btree
  add_index "list_subscriptions", ["email_account_id", "list_unsubscribe_mailto"], name: "index_list_subscriptions_on_ea_id_and_list_unsubscribe_mailto", unique: true, using: :btree
  add_index "list_subscriptions", ["uid"], name: "index_list_subscriptions_on_uid", unique: true, using: :btree

  create_table "mime_type_mappings", force: true do |t|
    t.string   "mime_type"
    t.integer  "usable_category_cd", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "name"
    t.text     "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["email_account_id", "email_account_type", "email_address"], name: "index_people_on_email_account_and_email_address", unique: true, using: :btree
  add_index "people", ["email_address"], name: "index_people_on_email_address", using: :btree
  add_index "people", ["name"], name: "index_people_on_name", using: :btree

  create_table "skins", force: true do |t|
    t.text     "uid"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sync_failed_emails", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "email_uid"
    t.text     "result"
    t.text     "exception"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sync_failed_emails", ["email_account_id", "email_account_type", "email_uid"], name: "index_sync_failed_emails_on_email_account_and_email_uid", unique: true, using: :btree

  create_table "user_auth_keys", force: true do |t|
    t.integer  "user_id"
    t.text     "encrypted_auth_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_auth_keys", ["encrypted_auth_key"], name: "index_user_auth_keys_on_encrypted_auth_key", using: :btree
  add_index "user_auth_keys", ["user_id"], name: "index_user_auth_keys_on_user_id", using: :btree

  create_table "user_configurations", force: true do |t|
    t.integer  "user_id"
    t.boolean  "demo_mode_enabled",          default: true
    t.boolean  "keyboard_shortcuts_enabled", default: true
    t.boolean  "genie_enabled",              default: true
    t.text     "split_pane_mode",            default: "horizontal"
    t.boolean  "developer_enabled",          default: false
    t.integer  "skin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "email_list_view_row_height"
    t.boolean  "auto_cleaner_enabled",       default: false
    t.boolean  "inbox_tabs_enabled"
    t.integer  "email_signature_id"
  end

  add_index "user_configurations", ["email_signature_id"], name: "index_user_configurations_on_email_signature_id", using: :btree
  add_index "user_configurations", ["skin_id"], name: "index_user_configurations_on_skin_id", using: :btree
  add_index "user_configurations", ["user_id"], name: "index_user_configurations_on_user_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.boolean  "admin",                default: false
    t.text     "email"
    t.text     "password_digest"
    t.integer  "login_attempt_count",  default: 0
    t.boolean  "has_genie_report_ran", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_picture"
    t.string   "name"
    t.string   "given_name"
    t.string   "family_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
