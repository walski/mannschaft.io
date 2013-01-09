module Mannschaft
  class TeamMember
    include Mongoid::Document

    field :firstName, type: String
    field :lastName, type: String
    field :absences, type: Hash, default: {}

    embeds_many :departments
    accepts_nested_attributes_for :departments

    def as_json(options = {})
      root = self.class.name.split('::').last.gsub(/^(.)/) {|f| f.downcase}
      super({:root => root}.merge(options))
    end
  end
end