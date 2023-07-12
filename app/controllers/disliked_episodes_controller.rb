class DislikedEpisodesController < PagesController
    def index
        @disliked_episodes = current_user.find_disliked_items
    end
end
