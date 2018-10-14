class JsonWebToken
  class << self
    def encode(payload)
      JWT.encode(payload, ENV['RAILS_KEY'])
    end

    def decode(token)
      body = JWT.decode(token, ENV['RAILS_KEY'])[0]
      HashWithIndifferentAccess.new(body)
    rescue
      nil
    end
  end
end
