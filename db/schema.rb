# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_230_215_114_531) do
    # These are extensions that must be enabled in order to support this database
    enable_extension 'pgcrypto'
    enable_extension 'plpgsql'

    create_table 'active_admin_comments', force: :cascade do |t|
        t.string 'namespace'
        t.text 'body'
        t.string 'resource_type'
        t.bigint 'resource_id'
        t.string 'author_type'
        t.bigint 'author_id'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.index %w[author_type author_id], name: 'index_active_admin_comments_on_author'
        t.index ['namespace'], name: 'index_active_admin_comments_on_namespace'
        t.index %w[resource_type resource_id], name: 'index_active_admin_comments_on_resource'
    end

    create_table 'active_storage_attachments', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.string 'name', null: false
        t.string 'record_type', null: false
        t.uuid 'record_id', null: false
        t.uuid 'blob_id', null: false
        t.datetime 'created_at', null: false
        t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
        t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness', unique: true
    end

    create_table 'active_storage_blobs', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.string 'key', null: false
        t.string 'filename', null: false
        t.string 'content_type'
        t.text 'metadata'
        t.string 'service_name', null: false
        t.bigint 'byte_size', null: false
        t.string 'checksum'
        t.datetime 'created_at', null: false
        t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
    end

    create_table 'active_storage_variant_records', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.uuid 'blob_id', null: false
        t.string 'variation_digest', null: false
        t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
    end

    create_table 'admin_users', force: :cascade do |t|
        t.string 'email', default: '', null: false
        t.string 'encrypted_password', default: '', null: false
        t.string 'reset_password_token'
        t.datetime 'reset_password_sent_at'
        t.datetime 'remember_created_at'
        t.integer 'sign_in_count', default: 0, null: false
        t.datetime 'current_sign_in_at'
        t.datetime 'last_sign_in_at'
        t.string 'current_sign_in_ip'
        t.string 'last_sign_in_ip'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.index ['email'], name: 'index_admin_users_on_email', unique: true
        t.index ['reset_password_token'], name: 'index_admin_users_on_reset_password_token', unique: true
    end

    create_table 'ahoy_events', force: :cascade do |t|
        t.bigint 'visit_id'
        t.bigint 'user_id'
        t.string 'name'
        t.jsonb 'properties'
        t.datetime 'time'
        t.index %w[name time], name: 'index_ahoy_events_on_name_and_time'
        t.index ['properties'], name: 'index_ahoy_events_on_properties', opclass: :jsonb_path_ops, using: :gin
        t.index ['user_id'], name: 'index_ahoy_events_on_user_id'
        t.index ['visit_id'], name: 'index_ahoy_events_on_visit_id'
    end

    create_table 'ahoy_visits', force: :cascade do |t|
        t.string 'visit_token'
        t.string 'visitor_token'
        t.bigint 'user_id'
        t.string 'ip'
        t.text 'user_agent'
        t.text 'referrer'
        t.string 'referring_domain'
        t.text 'landing_page'
        t.string 'browser'
        t.string 'os'
        t.string 'device_type'
        t.string 'country'
        t.string 'region'
        t.string 'city'
        t.float 'latitude'
        t.float 'longitude'
        t.string 'utm_source'
        t.string 'utm_medium'
        t.string 'utm_term'
        t.string 'utm_content'
        t.string 'utm_campaign'
        t.string 'app_version'
        t.string 'os_version'
        t.string 'platform'
        t.datetime 'started_at'
        t.index ['user_id'], name: 'index_ahoy_visits_on_user_id'
        t.index ['visit_token'], name: 'index_ahoy_visits_on_visit_token', unique: true
    end

    create_table 'comments', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.text 'description'
        t.bigint 'user_id'
        t.uuid 'episode_id'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.integer 'rating'
        t.index ['episode_id'], name: 'index_comments_on_episode_id'
        t.index ['user_id'], name: 'index_comments_on_user_id'
    end

    create_table 'episode_playlists', force: :cascade do |t|
        t.integer 'position'
        t.uuid 'episode_id'
        t.uuid 'playlist_id'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.index ['episode_id'], name: 'index_episode_playlists_on_episode_id'
        t.index ['playlist_id'], name: 'index_episode_playlists_on_playlist_id'
    end

    create_table 'episodes', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.string 'episode_name'
        t.text 'episode_description'
        t.string 'show_name'
        t.text 'show_description'
        t.date 'publication_date'
        t.integer 'duration'
        t.string 'show_filename_prefix'
        t.string 'episode_filename_prefix'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.integer 'cached_votes_total', default: 0
        t.integer 'cached_votes_score', default: 0
        t.integer 'cached_votes_up', default: 0
        t.integer 'cached_votes_down', default: 0
        t.integer 'cached_weighted_score', default: 0
        t.integer 'cached_weighted_total', default: 0
        t.float 'cached_weighted_average', default: 0.0
        t.text 'categories'
    end

    create_table 'episodes_systems', id: false, force: :cascade do |t|
        t.uuid 'system_id'
        t.uuid 'episode_id'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.index ['episode_id'], name: 'index_episodes_systems_on_episode_id'
        t.index ['system_id'], name: 'index_episodes_systems_on_system_id'
    end

    create_table 'experiments', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.string 'name'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
    end

    create_table 'playlists', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.string 'name'
        t.float 'current_time', default: 0.0
        t.bigint 'user_id'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.uuid 'episode_id'
        t.index ['episode_id'], name: 'index_playlists_on_episode_id'
        t.index ['user_id'], name: 'index_playlists_on_user_id'
    end

    create_table 'systems', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
        t.string 'name'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.uuid 'experiment_id'
        t.index ['experiment_id'], name: 'index_systems_on_experiment_id'
    end

    create_table 'users', force: :cascade do |t|
        t.string 'username', default: '', null: false
        t.string 'encrypted_password', default: '', null: false
        t.string 'reset_password_token'
        t.datetime 'reset_password_sent_at'
        t.datetime 'remember_created_at'
        t.integer 'sign_in_count', default: 0, null: false
        t.datetime 'current_sign_in_at'
        t.datetime 'last_sign_in_at'
        t.string 'current_sign_in_ip'
        t.string 'last_sign_in_ip'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.uuid 'playlist_id'
        t.uuid 'system_id'
        t.index ['playlist_id'], name: 'index_users_on_playlist_id'
        t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
        t.index ['system_id'], name: 'index_users_on_system_id'
        t.index ['username'], name: 'index_users_on_username', unique: true
    end

    create_table 'votes', force: :cascade do |t|
        t.string 'votable_type'
        t.uuid 'votable_id'
        t.string 'voter_type'
        t.bigint 'voter_id'
        t.boolean 'vote_flag'
        t.string 'vote_scope'
        t.integer 'vote_weight'
        t.datetime 'created_at', null: false
        t.datetime 'updated_at', null: false
        t.index %w[votable_id votable_type vote_scope], name: 'index_votes_on_votable_id_and_votable_type_and_vote_scope'
        t.index %w[votable_type votable_id], name: 'index_votes_on_votable'
        t.index %w[voter_id voter_type vote_scope], name: 'index_votes_on_voter_id_and_voter_type_and_vote_scope'
        t.index %w[voter_type voter_id], name: 'index_votes_on_voter'
    end

    add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
    add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
    add_foreign_key 'playlists', 'episodes'
    add_foreign_key 'systems', 'experiments'
    add_foreign_key 'users', 'playlists'
    add_foreign_key 'users', 'systems'
end
