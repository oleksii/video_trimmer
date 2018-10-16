class VideoUploader < Shrine
  plugin :mongoid
  plugin :processing
  plugin :backgrounding
  plugin :determine_mime_type, analyzer: :mime_types

  Attacher.promote do |data|
    video_id = data.fetch('record').try(:last)
    video    = Video.find(video_id)

    TrimVideoJob.perform_later(data)
    video.trim.update(status: Trim.statuses.hash['processing'])
  end
end
