require 'rails_helper'
require 'rspec_api_documentation/dsl'
require 'sidekiq/testing'

RSpec.resource 'Video' do

  TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNWJjNGY5NmZlYTczMWQwMDAxMGM3Y2FiIn0.RKiCea1oi7kqs7ToTg-M31k9GNCFbzhdeU1HiWJwkCA'

  header 'Content-Type', 'multipart/form-data'
  header 'Accept', 'application/vnd.example.v1'
  header 'Authorization', TOKEN

  let!(:user)      { create(:user, id: user_id) }
  let(:user_id)    { JsonWebToken.decode(TOKEN)[:user_id] }

  let(:file)       { Rack::Test::UploadedFile.new(file_path, 'video/mp4', true) }
  let(:file_path)  { Rails.root.join('spec/support/files/dummy_video.mp4') }

  let(:start_time) { '1.5' }
  let(:end_time)   { '4.6' }
  let(:timeline)   { { start_time: start_time, end_time: end_time } }

  # Creating Video and receiving the status of trimming in the response

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

    context 'with invalid params', document: false do
      let(:invalid_file) { Rack::Test::UploadedFile.new(Tempfile.new.to_path, 'video/mp4', true) }

      example 'Creating new video without file' do
        do_request({ file: invalid_file, timeline: timeline })

        status.should == 422
      end

      example 'Creating new video without timeline' do
        do_request({ file: file, timeline: { start_time: '1.3', end_time: '0.5' } })

        status.should == 422
      end
    end
  end

  # Viewing Video information

  get '/api/videos' do
    let(:video) do
      create(:video,
        user: user,
        file: file,
        duration: '29.4',
        trim: { status: :done },
        timeline: { start_time: '1.3', end_time: '5.3' }
      )
    end

    before { video }

    example 'Getting videos information' do
      do_request

      status.should == 200
    end
  end

  # Restarting failed Video trimming

  patch '/api/videos/restart' do
    parameter :id, 'Id of failed video', required: true

    let(:video) do
      create(:video,
        user: user,
        file: file,
        trim: { status: :failed },
        timeline: { start_time: '1.3', end_time: '5.3' }
      )
    end

    before { video }

    context 'with valid params' do
      let(:id) { video.id.to_s }

      example 'Restarting failed Video trimming' do
        allow(VideoUploader::Attacher).to receive(:promote).with(any_args)

        Sidekiq::Testing.inline! do
          do_request

          video.reload.trim.status.should == :processing
        end

        status.should == 202
      end
    end

    context 'with invalid params', document: false do
      let(:id) { '111111' }

      example 'Restarting failed Video trimming with wrong id' do
        do_request

        status.should == 400
      end
    end
  end
end
