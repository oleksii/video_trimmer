require 'rails_helper'

RSpec.describe Trimmer do
  subject { described_class.call(**opts) }

  let(:end_time)    { '2.4' }
  let(:start_time)  { '4.2' }
  let(:input_path)  { Rails.root.join('spec/support/files/dummy_video.mp4').to_path }
  let(:output_path) { Rails.root.join('spec/support/files/trimmed_video.mp4').to_path }

  let(:opts) do
    {
      end_time:    end_time,
      start_time:  start_time,
      input_path:  input_path,
      output_path: output_path
    }
  end

  describe '.call' do
    context 'when success' do
      it 'returns trimmed file in result' do
        trimmer = subject
        expect(trimmer.success?).to be(true)
        expect(trimmer.result.to_path).to eq(output_path)
        expect(trimmer.errors.empty?).to be(true)
      end

      it 'trims a video' do
        input_video_duration = FFMPEG::Movie.new(input_path).duration

        expect(subject.duration).to be < input_video_duration
      end
    end

    context 'when failure' do
      let(:output_path) { '' }

      it 'returns nil in result and adds errors' do
        trimmer = subject
        expect(trimmer.success?).to be(false)
        expect(trimmer.result).to be(nil)
        expect(trimmer.errors.empty?).to be(false)
      end
    end
  end

  describe '#duration' do
    let(:duration) { 'shorter' }
    let(:instance) { double('instance of FFMPEG') }

    before do
      allow(FFMPEG::Movie).to receive(:new).with(any_args).and_return(instance)
      allow(instance).to receive(:transcode).with(any_args).and_return(nil)
      allow(instance).to receive(:duration).with(any_args).and_return(duration)
    end

    it 'returns duration of video' do
      trimmer = subject
      expect(trimmer.success?).to be(true)
      expect(trimmer.duration).to be(duration)
    end
  end
end
