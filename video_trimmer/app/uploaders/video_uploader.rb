class VideoUploader < Shrine
  plugin :mongoid
  plugin :processing
  plugin :delete_raw
  plugin :backgrounding
  plugin :download_endpoint, prefix: 'attachments', host: ENV['APP_HOST']
  plugin :determine_mime_type, analyzer: :mime_types

  Attacher.promote { |data| TrimVideoJob.perform_later(data) }

  process(:store) do |io, context|
    video = context[:record]
    options = {
      end_time:    video.timeline.end_time,
      start_time:  video.timeline.start_time,
      input_path:  [Rails.root.to_path, video.file.url].join('/public'),
      output_path: [Rails.root.to_path, video.file.original_filename].join('/public/uploads/')
    }

    trimmer = Trimmer.call(**options)

    if trimmer.success?
      video.update(duration: trimmer.duration)
      video.trim.update!(status: Trim.statuses.hash['done'])
      trimmer.result
    else
      video.errors[:trim] << trimmer.errors
      video.trim.update!(status: Trim.statuses.hash['failed'])
      io.download
    end
  end
end
