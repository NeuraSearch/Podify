module Ahoy
    class Event < ApplicationRecord
        include Ahoy::QueryMethods

        self.table_name = 'ahoy_events'

        belongs_to :visit
        belongs_to :user

        validates :name, presence: true
        validates :time, presence: true

        # This function is called when exporting the behavioural data to a CSV file
        def self.to_csv
            CSV.generate do |csv|
                col_names = %w[time username experiment system action description]
                # We change the current task and current system once we see an entry in the logging
                curr_system = System.find_by(name: 'default')
                curr_user_id = -1
                csv << col_names
                Ahoy::Event.order(user_id: :asc, time: :asc).each do |event|
                    # Reset the current task and system when there is a new user to account for
                    if curr_user_id != event.user_id
                        curr_user_id = event.user_id
                        curr_system = System.find_by(name: 'default')
                    end

                    # Timestamp
                    record = [event.time]

                    # Username
                    record += [User.find_by_id(event.user_id).username]

                    # Check if there was a change in system
                    curr_system = System.find_by_id(event.properties) if event[:name] == 'system:set'

                    # Experiment name
                    record += [curr_system.experiment.name]

                    # System name
                    record += [curr_system.name]

                    # Action
                    record += [event.name]

                    # Description
                    event_properties = [event.properties]
                    record += event_properties == [{}] ? [''] : event_properties

                    # Add record to the CSV object
                    csv << record
                end
            end
        end
    end
end
