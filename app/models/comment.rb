class Comment < ApplicationRecord
    belongs_to :user
    belongs_to :episode

    # Some validation criteria. The description of a comment is maximum 250 words. The rating has to be within 1 and 5.
    validates :description, presence: true, length: {
        maximum: 250,
        tokenizer: ->(str) { str.scan(/\w+/) },
        too_long: 'is too long (maximum 250 words)'
    }
    validates :rating, inclusion: { in: 1..5, message: 'is not in the range [1..5]' }, presence: true
    validates :user_id, uniqueness: { scope: :episode_id }

    # This function is called when exporting the comments list to a CSV file
    def self.to_csv
        CSV.generate do |csv|
            col_names = %w[id username episode description rating created_at updated_at]
            csv << col_names
            Comment.order(user_id: :asc, updated_at: :asc).each do |comment|
                # id
                record = [comment.id]

                # username
                record += [User.find_by_id(comment.user_id).username]

                # episode
                record += [comment.episode_id]

                # description
                record += [comment.description]

                # rating
                record += [comment.rating]

                # created_at
                record += [comment.created_at]

                # updated_at
                record += [comment.updated_at]

                csv << record
            end
        end
    end
end
