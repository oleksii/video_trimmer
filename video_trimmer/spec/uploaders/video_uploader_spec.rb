require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe VideoUploader do

  let(:user)      { create(:user) }
  let(:file)      { Rack::Test::UploadedFile.new(file_path, 'video/mp4', true) }
  let(:file_path) { Rails.root.join('spec/support/files/dummy_video.mp4') }
  # let(:file)      { File.open(file_path.to_path) }

  let(:video) do
    create(:video,
      user:     user,
      file:     file,
      trim:     { status: :processing },
      timeline: { start_time: '1.3', end_time: '2.3' }
    )
  end

  let(:data) do
    {
      "attachment"   => video.file_data.to_json,
      "record"       => [video.class.to_s, video.id.to_s],
      "name"         => 'file',
      "shrine_class" => 'VideoUPloader'
    }
  end

  describe 'triming cached file by processing during promoting to store' do
    let(:duration) { '100' }
    let(:command) do
      double('command',
        errors:   {},
        result:   Tempfile.new,
        success?: true,
        duration: duration
      )
    end

    before do
      allow(Trimmer).to receive(:call).with(any_args).and_return(command)
    end

    it 'calls Trimmer' do
      Sidekiq::Testing.inline! do
        VideoUploader::Attacher.promote(data)

        expect(Trimmer).to have_received(:call)
      end
    end

    context 'when success' do
      it 'sets video trim status as :done' do
        Sidekiq::Testing.inline! do
          expect(video.trim.status).to be(:processing)

          VideoUploader::Attacher.promote(data)

          expect(video.reload.trim.status).to be(:done)
        end
      end

      it 'sets video duration' do
        Sidekiq::Testing.inline! do
          expect(video.duration).to be(nil)

          VideoUploader::Attacher.promote(data)

          expect(video.reload.duration).to eq(duration)
        end
      end
    end

    context 'when failure' do
      let(:command) do
        double('command',
          errors:   {some_error: ['message']},
          result:   nil,
          success?: false,
          duration: nil
        )
      end

      it 'sets video trim status as :failed' do
        Sidekiq::Testing.inline! do
          expect(video.trim.status).to be(:processing)

          VideoUploader::Attacher.promote(data)

          expect(video.reload.trim.status).to be(:failed)
        end
      end

      it 'sets video duration' do
        Sidekiq::Testing.inline! do
          expect(video.duration).to be(nil)

          VideoUploader::Attacher.promote(data)

          expect(video.reload.duration).to be(nil)
        end
      end
    end
  end
end
