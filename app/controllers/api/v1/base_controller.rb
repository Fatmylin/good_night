class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header

    if header
      decoded = JwtService.decode(header)
      if decoded
        @current_user = User.find(decoded[:user_id])
      else
        render_unauthorized
      end
    else
      render_unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render_unauthorized
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end
