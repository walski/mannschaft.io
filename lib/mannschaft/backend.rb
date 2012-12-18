require 'grape'

module Mannschaft
  class Backend < Grape::API
    version 'v1', :using => :path
    format :json

    resource :team do
      desc "Get a list of all team members"
      get '/' do
        TeamMember.all
      end

      post '/' do
        attributes = params[:teamMember]
        departments = attributes.delete(:departments) || []
        attributes[:departments] = departments.map {|department| Department.find_or_create_by(name: department.name)}

        TeamMember.create!(attributes).to_json
      end

      put '/:id' do
        team_member = TeamMember.find(params[:id])

        attributes = params[:teamMember]
        departments = attributes.delete(:departments) || []
        attributes[:departments] = departments.map {|department| Department.find_or_create_by(name: department.name)}

        team_member.attributes = attributes
        team_member.save!
        team_member.to_json
      end

      delete '/:id' do
        team_member = TeamMember.find(params[:id])
        team_member.destroy
      end
    end
  end
end