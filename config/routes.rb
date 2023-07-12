require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
    devise_for :users, only: %i[sessions registrations]
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)

    authenticate :admin_user do
        mount Sidekiq::Web, at: 'admin/sidekiq'
    end

    root 'pages#home'

    resources :playlists, only: %i[create show edit update destroy], param: :playlist_id do
        member do
            post 'selection', to: 'playlists#selection', as: :selection
            get 'next', to: 'playlists#next', as: :next
            patch 'set_time', to: 'playlists#set_time'
            post 'add_episode/:episode_id' => 'playlists#add_episode', as: :add_episode
            post 'remove_episode/:episode_id' => 'playlists#remove_episode', as: :remove_episode
            patch 'move/:episode_id' => 'playlists#move', as: :move
            post 'episodes/:episode_id/selection' => 'playlists#episode_selection', as: :episode_selection
        end
    end
    resources :episodes, only: %i[show], param: :episode_id do
        member do
            put 'like', to: 'episodes#upvote'
            put 'dislike', to: 'episodes#downvote'
            put 'neutral', to: 'episodes#neutralvote'

            resources :comments, only: %i[new create edit update destroy]
        end
    end

    get 'liked_episodes', to: 'liked_episodes#index'
    get 'disliked_episodes', to: 'disliked_episodes#index'
    get 'feedback', to: 'comments#index'
end
