class CreatePlaylists < ActiveRecord::Migration[7.0]
    def change
        create_table :playlists, id: :uuid do |t|
            t.string :name
            t.float :current_time, default: 0
            t.belongs_to :user
            t.timestamps
        end

        add_reference :users, :playlist, foreign_key: true, type: :uuid
        add_reference :playlists, :episode, foreign_key: true, type: :uuid
    end
end
