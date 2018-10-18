class TrimVideoJob < ApplicationJob

  def perform(data)
    attacher = VideoUploader::Attacher.load(data)
    video    = attacher.context[:record]

    video.trim.update!(status: Trim.statuses.hash['processing'])

    VideoUploader::Attacher.promote(data)
  end
end
