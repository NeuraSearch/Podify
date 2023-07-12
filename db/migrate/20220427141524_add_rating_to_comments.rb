class AddRatingToComments < ActiveRecord::Migration[7.0]
    def change
        add_column :comments, :rating, :integer
    end
end
