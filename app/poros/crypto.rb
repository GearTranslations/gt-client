class Crypto
  class << self
    def secret_api_key
      SecureRandom.alphanumeric(64)
    end
  end
end
