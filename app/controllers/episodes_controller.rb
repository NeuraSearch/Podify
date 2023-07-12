class EpisodesController < PagesController
    before_action :set_episode

    # Access the page of an episode. Also, if available, store the rank of the episode (from the homepage and the top@50 results)
    def show
        rank = params.permit(:rank)[:rank]
        ahoy.track('navigation:search_clicked_rank', rank) if rank
        @liked = liked?
        @current_comment = current_user.comments.find_by(episode_id: @episode.id)
    end

    # Like
    def upvote
        current_user.likes @episode
        ahoy.track('episode:like', @episode.id)

        vote_respond
    end

    # Dislike
    def downvote
        current_user.dislikes @episode
        ahoy.track('episode:dislike', @episode.id)

        vote_respond
    end

    # Removal of vote (e.g., user likes and then clicks like again. This will remove the like)
    def neutralvote
        if current_user.voted_up_on? @episode
            current_user.unlike @episode
        elsif current_user.voted_down_on? @episode
            current_user.undislike @episode
        end
        ahoy.track('episode:remove_vote', @episode.id)

        vote_respond
    end

    private

    def set_episode
        @episode = Episode.find(params[:episode_id])
    end

    def liked?
        return nil unless current_user.voted_for? @episode

        current_user.voted_up_on? @episode
    end

    def vote_respond
        respond_to do |format|
            format.html { redirect_to URI(request.referer).path }
            format.js { render :new }
        end
    end
end
