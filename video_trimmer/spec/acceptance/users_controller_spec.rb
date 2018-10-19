require 'rails_helper'
require 'rspec_api_documentation/dsl'

RSpec.resource 'User' do

  header 'Content-Type', 'application/json'
  header 'Accept', 'application/vnd.example.v1'

  post '/api/users' do
    let(:raw_post) { params.to_json }

    example 'Creating new user' do
      do_request

      status.should == 201
    end

    example 'Responding with subscribtion key', document: false do
      do_request

      user  = User.last
      token = JsonWebToken.encode(user_id: user.id.to_s)

      response_body.should == {'token' => token}.to_json
    end
  end
end
