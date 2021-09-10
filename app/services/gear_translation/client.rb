module GearTranslation
  class Client
    API_URL = Rails.application.secrets.gear_translation_api[:url].freeze

    def initialize(access_token)
      super()
      @token = access_token
    end

    def create_project(file, aligned_from, language_to)
      path = '/v2/projects/create'
      form = build_form(file, aligned_from, language_to)
      api_result = HTTP.headers(authorization_header)
                       .post("#{API_URL}#{path}", form: form)
      {
        status: api_result.code,
        data: extract_data(api_result)
      }
    end

    def project_status(external_id)
      path = "/v2/subprojects/#{external_id}/information"
      api_result = HTTP.headers(authorization_header)
                       .get("#{API_URL}#{path}")
      {
        status: api_result.code,
        data: extract_data(api_result)
      }
    end

    def translated_file(external_id)
      path = "/v2/subprojects/#{external_id}/translated_document"
      api_result = HTTP.headers(authorization_header)
                       .get("#{API_URL}#{path}")
      {
        status: api_result.code,
        data: extract_data(api_result)
      }
    end

    private

    def build_form(file, aligned_from, language_to)
      {
        'aligned_from': aligned_from,
        'language_to': language_to,
        'file': HTTP::FormData::File.new(file.path)
      }
    end

    def extract_data(api_result)
      content_types = ['text/plain', 'text/html', 'text/html; charset=utf-8']
      data = if content_types.include?(api_result.headers['Content-Type'])
               api_result.body.readpartial
             else
               api_result.parse
             end

      return data unless data.is_a?(Hash)

      data.deep_symbolize_keys
    end

    def authorization_header
      { 'session-token': @token }
    end
  end
end
