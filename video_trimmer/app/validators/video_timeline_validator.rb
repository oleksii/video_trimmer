class VideoTimelineValidator < ActiveModel::Validator
  ST_LESS_THEN_ZERO = 'start_time must be greater or equal zero'
  ST_LESS_THEN_ET   = 'start_time must be less then end_time'
  ET_LESS_OR_ZERO   = 'end_time must be greater then zero'
  ET_LESS_THEN_FILE = 'end_time must be less then video duration'
  INVALID_VIDEO     = 'video file is not valid'

  def validate(record)
    start_time = record.timeline.start_time.to_f
    end_time   = record.timeline.end_time.to_f

    record.errors[:timeline] << ST_LESS_THEN_ZERO if start_time < 0
    record.errors[:timeline] << ET_LESS_OR_ZERO   if end_time   <= 0
    record.errors[:timeline] << ST_LESS_THEN_ET   if start_time >= end_time

    if record.file_data['storage'].eql?('cache')
      file_path  = [Rails.root.to_path, record.file.url].join('/public')
      ffmpeg     = FFMPEG::Movie.new(file_path)

      record.errors[:base]     << INVALID_VIDEO     if !ffmpeg.valid?
      record.errors[:timeline] << ET_LESS_THEN_FILE if end_time >= ffmpeg.duration
    end
  end
end
