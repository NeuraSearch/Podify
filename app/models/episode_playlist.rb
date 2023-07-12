class EpisodePlaylist < ApplicationRecord
    default_scope { order :position }

    belongs_to :episode
    belongs_to :playlist

    acts_as_list scope: :playlist
end
