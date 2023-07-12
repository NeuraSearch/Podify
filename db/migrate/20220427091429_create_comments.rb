class CreateComments < ActiveRecord::Migration[7.0]
    def change
        create_table :comments, id: :uuid do |t|
            t.text :description
            t.belongs_to :user
            t.belongs_to :episode, type: :uuid
            t.timestamps
        end
    end
end
