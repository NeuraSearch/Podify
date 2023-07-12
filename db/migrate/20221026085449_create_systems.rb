class CreateSystems < ActiveRecord::Migration[7.0]
    def change
        create_table :systems, id: :uuid do |t|
            t.string :name

            t.timestamps
        end

        add_reference :users, :system, foreign_key: true, type: :uuid
        remove_column :users, :current_system, :integer
    end
end
