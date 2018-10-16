class Api::V1::VideosController < Api::V1::ApplicationController
  before_action :authenticate_request

  def index
    @videos = current_user.videos
  end

  def create
    video = current_user.videos.new(video_params)
    video.build_trim

    if video.save
      render json: { status: video.trim.status }, status: :created
    else
      render json: { error: video.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def video_params
    params.permit(:file, timeline: [:start_time, :end_time])
  end
end
