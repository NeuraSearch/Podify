class CreateEpisodes < ActiveRecord::Migration[7.0]
    def change
        create_table :episodes, id: :uuid do |t|
            t.string :episode_name
            t.text :episode_description
            t.string :show_name
            t.text :show_description
            t.date :publication_date
            t.integer :duration
            t.string :show_filename_prefix
            t.string :episode_filename_prefix

            t.timestamps
        end
    end
end
