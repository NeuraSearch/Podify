class Experiment < ApplicationRecord
    has_many :systems

    validates :name, uniqueness: true, presence: true
end
