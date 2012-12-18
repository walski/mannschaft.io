module Mannschaft
  class Department
    include Mongoid::Document
    field :name, type: String
    belongs_to :team_member
  end
end
