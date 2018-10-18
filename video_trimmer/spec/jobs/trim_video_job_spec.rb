require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe TrimVideoJob do

  let(:user)      { create(:user) }
  let(:file)      { Rack::Test::UploadedFile.new(file_path, 'video/mp4', true) }
  let(:file_path) { Rails.root.join('spec/support/files/dummy_video.mp4') }

  let(:video) do
    create(:video,
      user: user,
      file: file,
      trim: { status: :scheduled },
      timeline: { start_time: '1.3', end_time: '5.3' }
    )
  end

  it 'starts during creating a video' do
    allow(described_class).to receive(:perform_later)
    video
    expect(described_class).to have_received(:perform_later)
  end

  it 'sets video trim status as :processing and promote data to store' do
    allow(VideoUploader::Attacher).to receive(:promote).with(any_args)

    Sidekiq::Testing.inline! do
      expect(video.reload.trim.status).to be(:processing)
      expect(VideoUploader::Attacher).to have_received(:promote)
    end
  end
end
