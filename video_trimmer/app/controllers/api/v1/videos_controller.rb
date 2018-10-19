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

  def restart
    if params[:id].blank?
      render json: { error: 'id required' }, status: :bad_request# and return

    elsif video = current_user.videos.where(id: params[:id]).last
      video.trim.update(status: Trim.statuses.hash['scheduled'])

      video.file_attacher._promote(action: :store)

      render json: { status: video.trim.status }, status: :accepted
    else

      render json: { error: 'wrong id' }, status: :bad_request
    end
  end

  private

  def video_params
    params.permit(:file, timeline: [:start_time, :end_time])
  end
end
