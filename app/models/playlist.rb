class Playlist < ApplicationRecord
    has_many :episode_playlists
    has_many :episodes, through: :episode_playlists
    belongs_to :user, optional: true
    belongs_to :selected_episode, optional: true, class_name: 'Episode', foreign_key: :episode_id

    # When creating a playlist, set its name. The `set_name` is a random word generator
    before_validation :set_name, on: :create
    validates :name, presence: true

    # Add an episode to the list of episodes. Add only if not already in the list
    def add_episode(episode)
        return false if episodes.include?(episode)

        episodes << episode
        touch(:updated_at)
        true
    end

    # Remove episode form the list of episodes
    def removal_update(episode, current_user)
        ahoy = Ahoy.instance
        # If there was only one episode (meaning there will be zero episodes left), then also update the current_user object.
        # Set to nil the selected_episode and selected_playlist
        if episodes.size == 1
            episodes.delete(episode)

            if self == current_user.selected_playlist
                # in this case, there is no more a selected playlist
                ahoy.track('playlist:selection', nil)

                self.selected_episode = nil
                self.current_time = 0
                current_user.selected_playlist = nil
                current_user.save!
            end
        # Else, if the episode that the user is currently listening to is being deleted, then perform the episode_selection procedure.
        # Get the next available episode from the list and set that as the current selected episode.
        elsif selected_episode == episode
            item = episode_playlists.where(episode: episode).first&.lower_item
            episodes.delete(episode)
            self.selected_episode = item.present? ? item.episode : episode_playlists.where(position: 1).first.episode
            self.current_time = 0
            ahoy.track('episode:selection', selected_episode.id)
        # Otherwise, just delete the episode since it will have no effect
        else
            episodes.delete(episode)
        end

        save!
    end

    # Drag and drop procedure when reorganising the order of episodes in a playlist
    def move_episode_to_position(episode, position)
        first_item = episode_playlists.where(episode: episode).first
        current_position = first_item.position
        return if position == current_position

        first_item.insert_at(position)

        # Track change of position and order update within the playlist
        ahoy = Ahoy.instance
        ahoy.track('playlist:order_update', {
                       episode: episode.id,
                       playlist: id,
                       from: current_position,
                       to: position
                   })
    end

    # For the current user, set the current playlist as the selected, and also select the first episode as being the one
    # selected for listening.
    def selection_update(current_user)
        self.selected_episode = episodes.first
        touch(:updated_at)
        save!

        current_user.selected_playlist = self
        current_user.save!
    end

    # In this case, manually select which episode in the playlist to choose for listening
    def manual_episode_selection_update(episode)
        self.selected_episode = episode
        self.current_time = 0
        save!
    end

    private

    def set_name
        self.name = Faker::Lorem.word.titleize
    end
end
