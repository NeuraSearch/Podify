class CreateEpisodesAndSystems < ActiveRecord::Migration[7.0]
    def change
        create_table :episodes_systems, id: false do |t|
            t.belongs_to :system, type: :uuid
            t.belongs_to :episode, type: :uuid

            t.timestamps
        end
    end
end
