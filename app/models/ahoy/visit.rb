module Ahoy
    class Visit < ApplicationRecord
        self.table_name = 'ahoy_visits'

        has_many :events, class_name: 'Ahoy::Event'
        belongs_to :user

        def display_name
            id
        end

        # This function is called when exporting the behavioural data to a CSV file
        def self.to_csv
            CSV.generate do |csv|
                first_visit = Ahoy::Visit.first
                attributes = first_visit.attributes
                attributes.delete('id')
                attributes.delete('user_id')
                col_names = %w[id username] + attributes.keys
                csv << col_names
                Ahoy::Visit.order(user_id: :asc, started_at: :asc).each do |visit|
                    attributes = visit.attributes
                    attributes.delete('id')
                    attributes.delete('user_id')

                    # ID
                    record = [visit.id]

                    # Username
                    record += [visit.user.username]

                    # All available metadata about the visit
                    record += visit.attributes.values_at(*attributes.keys)

                    # Add record to the CSV object
                    csv << record
                end
            end
        end
    end
end
