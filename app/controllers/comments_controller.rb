class CommentsController < PagesController
    before_action :set_episode, only: %i[new create]
    before_action :set_comment, only: %i[edit update destroy]
    before_action :ensure_frame_response, only: :new

    def index
        @comments = current_user.comments.order(created_at: :desc)
    end

    # The `new` and `create` methods are used when creating a new comment of an episode
    def new
        @comment = Comment.new
    end

    def create
        @comment = Comment.new(comment_params)
        @comment.user = current_user
        @comment.episode = @episode

        respond_to do |format|
            if @comment.save
                ahoy.track('episode:feedback', {
                               feedback_id: @comment.id,
                               episode: @episode.id,
                               rating: @comment.rating,
                               description: @comment.description
                           })
                format.turbo_stream { render turbo_stream: turbo_stream.replace(@episode, partial: 'episodes/episode', locals: { episode: @episode }) }
                format.html { redirect_to URI(request.referer).path }
                format.json
            else
                format.html { render :new, status: :unprocessable_entity }
                format.json { render json: @comment.errors, status: :unprocessable_entity }
            end
        end
    end

    def edit; end

    def update
        strong_params = params.require(:comment).permit(:description, :rating)
        @comment.update(strong_params)
        episode_id = @comment.episode.id

        respond_to do |format|
            if @comment.save
                ahoy.track('episode:feedback_update', {
                               id: @comment.id,
                               episode: episode_id,
                               rating: @comment.rating,
                               description: @comment.description
                           })
                format.turbo_stream { render turbo_stream: turbo_stream.replace(@comment, partial: 'comments/comment', locals: { comment: @comment }) }
                format.html { redirect_to URI(request.referer).path }
                format.json { render :show, status: :ok, location: @comment }
            else
                format.html { render :edit, status: :unprocessable_entity }
                format.json { render json: @comment.errors, status: :unprocessable_entity }
            end
        end
    end

    def destroy
        episode_id = @comment.episode.id

        ahoy.track('episode:feedback_delete', {
                       id: @comment.id,
                       episode: episode_id
                   })

        @comment.destroy
        respond_to do |format|
            format.html { redirect_to URI(request.referer).path }
            format.json
        end
    end

    private

    def set_comment
        @comment = Comment.find_by_id(params.permit(:id)[:id])
    end

    def set_episode
        @episode = Episode.find_by_id(params.require(:episode_id))
    end

    def comment_params
        params.require(:comment).permit(:description, :rating)
    end
end
