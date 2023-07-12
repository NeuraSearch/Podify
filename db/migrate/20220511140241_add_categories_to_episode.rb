class AddCategoriesToEpisode < ActiveRecord::Migration[7.0]
    def change
        add_column :episodes, :categories, :text
    end
end
