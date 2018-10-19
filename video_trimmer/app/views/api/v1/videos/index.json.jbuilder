json.array!(@videos) do |video|
  json.extract!(video, :id, :duration)
  json.status video.trim.status
  json.url video.file.download_url if video.trim.done?
end
