class ApiRequestAuthorizer
  prepend SimpleCommand

  def initialize(headers = {})
    @auth_header = fetch_auth_header(headers)
  end

  def call
    fetch_user if @auth_header
  end

  private

  def fetch_user
    decoded_auth_token ||= JsonWebToken.decode(@auth_header)

    return User.find(decoded_auth_token[:user_id]) if decoded_auth_token

    errors.add(:token, 'Invalid token') && nil
  end

  def fetch_auth_header(headers)
    return headers['Authorization'].split(' ').last if headers['Authorization']

    errors.add(:token, 'Missing token') && nil
  end
end

