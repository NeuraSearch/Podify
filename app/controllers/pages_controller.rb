class PagesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_selected_playlist_and_episode

    def home
        params = strong_params

        # Check if there was a system or query in the parameter list from the URL, e.g.:
        # localhost:3000/?system=c5c54581-4462-4399-816f-a6ab1663bb8e
        # localhost:3000/?query=my-search-query
        new_system_id = params[:system]
        query = params[:query]

        if new_system_id.present?
            new_system = System.find_by_id(new_system_id)
            if new_system
                @current_user.update_system(new_system)
                ahoy.track('system:set', new_system.id)
                @selected_playlist.update(selected_episode: nil, current_time: 0) if @selected_playlist.present?
                current_user.update(selected_playlist: nil)

                # Refresh page to apply change
                redirect_back(fallback_location: root_path)
            end
        end

        # If there was a search, return a list of the top@50 episodes. If not search, then an empty array
        @episodes = current_user.episodes_search(query)
        ahoy.track('navigation:search', query) if query
    end

    protected

    def set_selected_playlist_and_episode
        return unless current_user.present?

        @current_system = current_user.system
        return unless current_user.selected_playlist.present?

        @selected_playlist = current_user.selected_playlist
        @selected_episode = @selected_playlist.selected_episode
    end

    def ensure_frame_response
        return unless Rails.env.development?

        redirect_to root_path unless turbo_frame_request?
    end

    private

    def strong_params
        params.permit(:query, :system)
    end
end
