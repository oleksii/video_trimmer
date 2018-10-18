class Trimmer
  prepend SimpleCommand

  def initialize(args)
    @end_time    = args[:end_time]
    @start_time  = args[:start_time]
    @input_path  = args[:input_path]
    @output_path = args[:output_path]
  end

  def call
    trim_video
  end

  def duration
    FFMPEG::Movie.new(@output_path).duration if success?
  end

  private

  def trim_video
    opts = ['-ss', @start_time, '-t', @end_time]

    begin
      FFMPEG::Movie.new(@input_path).transcode(@output_path, opts)
    rescue FFMPEG::Error => message
      errors.add(:trimming, message) && nil
    else
      File.open(@output_path)
    end
  end
end
