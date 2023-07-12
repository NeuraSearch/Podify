class System < ApplicationRecord
    # When a new system is created, by default add all episodes in the catalogue to it.
    # This means that the system will have the entire catalogue. Episodes can be removed
    # from the system from the admin dashboard.
    before_validation :add_all_episodes

    has_many :users
    has_and_belongs_to_many :episodes
    belongs_to :experiment

    validates :name, presence: true

    private

    def add_all_episodes
        episodes << Episode.all
    end
end
