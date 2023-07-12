class CreateEpisodePlaylists < ActiveRecord::Migration[7.0]
    def change
        create_table :episode_playlists do |t|
            t.integer :position
            t.belongs_to :episode, type: :uuid
            t.belongs_to :playlist, type: :uuid
            t.timestamps
        end
    end
end
