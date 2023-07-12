class PlaylistsController < PagesController
    before_action :ensure_frame_response, only: :edit
    before_action :set_playlist, except: :next

    # Create a playlist
    def create
        playlist = Playlist.new
        playlist.user = current_user
        playlist.save

        respond_to do |format|
            ahoy.track('playlist:create', {
                           playlist: playlist.id,
                           system: @current_system.id
                       })
            format.html { redirect_to playlist_path(playlist) }
            format.json
        end
    end

    # If trying to access a playlist, but it does not exist, redirect user to root
    def show
        redirect_to root_path unless @playlist.present?
    end

    # This is performed when the audio file has been fully listened to
    # and it reached the end.
    def next
        ahoy.track('episode:selection_reached_end_audio', current_user.selected_playlist.selected_episode.id)
    end

    # Add an episode to the playlist
    def add_episode
        episode = Episode.find_by_id(params.permit(:episode_id)[:episode_id])
        status = @playlist.add_episode(episode)

        if status
            ahoy.track('playlist:add_episode', {
                           playlist: @playlist.id,
                           episode: episode.id
                       })
        end
    end

    # Remove an episode from the playlist
    def remove_episode
        episode = @playlist.episodes.find_by_id(params.permit(:episode_id)[:episode_id])
        ahoy.track('playlist:remove_episode', {
                       playlist: @playlist.id,
                       episode: episode.id
                   })

        @playlist.removal_update(episode, current_user)

        respond_to do |format|
            format.html { redirect_to(@playlist) }
            format.js { render :new }
        end
    end

    # Drag and drop reordering of the episodes within a playlist
    def move
        my_params = params.permit(:playlist_id, :episode_id, :position)
        episode = @playlist.episodes.find_by_id(my_params[:episode_id])
        @playlist.move_episode_to_position(episode, my_params[:position].to_i)

        respond_to do |format|
            format.turbo_stream
            format.html { redirect_to(@playlist) }
        end
    end

    # Selection procedure of playlist and thus also of episode
    def selection
        return if @playlist.episodes.empty?

        @playlist.selection_update(current_user)
        @playlist.manual_episode_selection_update(@playlist.episodes.first)
        ahoy.track('playlist:selection', @playlist.id)
        ahoy.track('episode:selection', @playlist.selected_episode.id)

        respond_to do |format|
            format.turbo_stream
            format.html { redirect_to(@playlist) }
        end
    end

    # Selection procedure only for episode (change of episode within a playlist)
    def episode_selection
        my_params = params.permit(:playlist_id, :episode_id, :skip)
        playlist = Playlist.find_by_id(my_params[:playlist_id])
        episode = @playlist.episodes.find_by_id(params[:episode_id])

        if @selected_playlist != @playlist
            @playlist.selection_update(current_user)
            ahoy.track('playlist:selection', @playlist.id)
        end

        # If the next button was clicked, fetch the next episode in the list.
        # If the previous button was clicked, fetch the previous episode in the list.
        episode = case my_params[:skip]
                  when 'next'
                      lower_item = playlist.episode_playlists.where(episode: episode).first&.lower_item
                      if lower_item.present?
                          lower_item.episode
                      else
                          # if nil, set to first episode in the list (loop from beginning)
                          playlist.episodes.first
                      end
                  when 'previous'
                      higher_item = @selected_playlist.episode_playlists.where(episode: @selected_episode).first&.higher_item
                      if higher_item.present?
                          higher_item.episode
                      else
                          episode
                      end

                  else
                      episode
                  end

        @playlist.manual_episode_selection_update(episode)
        ahoy.track('episode:selection', episode.id)

        respond_to do |format|
            format.turbo_stream
            format.html { redirect_to(@playlist) }
        end
    end

    # Deletion of a playlist
    def destroy
        ahoy.track('playlist:delete', @playlist.id)
        if @selected_playlist == @playlist
            current_user.selected_playlist = nil
            current_user.save!
        end

        @playlist.destroy
        respond_to do |format|
            format.html { redirect_to URI(request.referer).path }
            format.json
        end
    end

    # Callback used to track progress of the listening activity. This is called every 3 seconds
    # from the Javascript frontend.
    def set_time
        new_time = params.permit(:current_time, :playlist_id)[:current_time]
        @playlist.update(current_time: new_time)
        ahoy.track('episode:current_time', new_time)
    end

    def edit; end

    # Update a playlist (for now, this is only the name)
    def update
        return unless params[:playlist].present?

        originale_name = @playlist.name
        new_name = params.require(:playlist).permit(:name)[:name]
        @playlist.name = new_name

        respond_to do |format|
            if @playlist.save
                ahoy.track('playlist:rename', {
                               playlist: @playlist.id,
                               from: originale_name,
                               to: new_name
                           })
                format.turbo_stream { render turbo_stream: turbo_stream.replace(@playlist, partial: 'playlists/playlist', locals: { playlist: @playlist }) }
                format.html { redirect_to playlist_url(@playlist) }
                format.json { render :show, status: :ok, location: @playlist }
            else
                format.html { render :edit, status: :unprocessable_entity }
                format.json { render json: @playlist.errors, status: :unprocessable_entity }
            end
        end
    end

    private

    def set_playlist
        @playlist = current_user.playlists.find_by_id(params[:playlist_id])
    end
end
