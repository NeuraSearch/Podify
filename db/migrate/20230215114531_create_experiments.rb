class CreateExperiments < ActiveRecord::Migration[7.0]
    def change
        create_table :experiments, id: :uuid do |t|
            t.string :name

            t.timestamps
        end

        add_reference :systems, :experiment, foreign_key: true, type: :uuid
    end
end
