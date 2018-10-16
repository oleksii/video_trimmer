class TrimVideoJob < ApplicationJob

  def perform(data)
    # TODO: add process of trimming here
    VideoUploader::Attacher.promote(data)
  end
end
