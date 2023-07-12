class LikedEpisodesController < PagesController
    def index
        @liked_episodes = current_user.find_liked_items
    end
end
