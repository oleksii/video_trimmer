require 'rails_helper'
require 'rspec_api_documentation/dsl'

RSpec.resource 'Video' do
  explanation 'Creating Video and receiving the status of trimming in the response'

  TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNWJjNGY5NmZlYTczMWQwMDAxMGM3Y2FiIn0.RKiCea1oi7kqs7ToTg-M31k9GNCFbzhdeU1HiWJwkCA'

  header 'Content-Type', 'multipart/form-data'
  header 'Accept', 'application/vnd.example.v1'
  header 'Authorization', TOKEN

  let!(:user)      { create(:user, id: user_id) }
  let(:user_id)    { JsonWebToken.decode(TOKEN)[:user_id] }

  let(:file)       { Rack::Test::UploadedFile.new(file_path, 'video/mp4', true) }
  let(:file_path)  { Rails.root.join('spec/support/files/dummy_video.mp4') }

  let(:timeline)   { { start_time: '1.5', end_time: '4.6' } }

  post '/api/videos' do
    parameter :file, 'Video file', required: true
    with_options scope: :timeline do
      parameter :start_time, 'Start time', required: true
      parameter :end_time,   'Start time', required: true
    end

    context 'with valid params' do
      example 'Creating new video' do
        do_request

        status.should == 201
        response_body.should == {'status' => :scheduled}.to_json
      end
    end

    context 'with invalid params' do
      example 'Creating new video without file' do
        do_request({ file: nil, timeline: timeline })

        status.should == 422
      end

      example 'Creating new video without timeline' do
        do_request({ file: file, timeline: { start_time: '1.3', end_time: '0.5' } })

        status.should == 422
      end
    end
  end
end
