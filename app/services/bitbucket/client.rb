module Bitbucket
  class Client < RepositoryService
    def initialize(repository)
      super()
      user_app = "#{repository.user_name}:#{repository.app_password}"
      @encoded_credentials = Base64.strict_encode64(user_app)
      @api_base_url = repository.server_url
      @workspace = repository.workspace
      @repository_name = repository.repository_name
    end

    def file(branch, file_name)
      path = "/#{@workspace}/#{@repository_name}/src/#{branch}/#{file_name}"
      exec('GET', "#{@api_base_url}#{path}")
    end

    def last_file_change(branch, file_name)
      params = '?pagelen=1&fields=values.next,values.path,values.commit.date,values.commit.message'
      path = "/#{@workspace}/#{@repository_name}/filehistory/#{branch}/#{file_name}#{params}"

      exec('GET', "#{@api_base_url}#{path}")
    end

    def upload_file(branch_name, file, upload_path, commit_message) # rubocop:disable Metrics/MethodLength
      path = "/#{@workspace}/#{@repository_name}/src"
      file_name = "#{upload_path}/#{File.basename(file.path)}"
      form = {
        'branch': branch_name,
        "#{file_name}": HTTP::FormData::File.new(file.path),
        'message': commit_message
      }
      api_result = HTTP.headers(authorization_header)
                       .post("#{@api_base_url}#{path}", form: form)
      {
        status: api_result.code,
        data: api_result.body.readpartial
      }
    end

    def create_pull_request(title, branch_destination, branch_source)
      path = "/#{@workspace}/#{@repository_name}/pullrequests"
      body = {
        title: title,
        source: { branch: { name: branch_source } },
        destination: { branch: { name: branch_destination } }
      }
      exec('POST', "#{@api_base_url}#{path}", body.to_json)
    end

    def get_pull_request(pull_request_id)
      path = "/#{@workspace}/#{@repository_name}/pullrequests/#{pull_request_id}"
      exec('GET', "#{@api_base_url}#{path}")
    end

    private

    def exec(method, uri, data = nil)
      options = options(method, data)
      api_result = HTTP.headers(default_headers).request(method, uri, options)
      {
        status: api_result.code,
        data: extract_data(api_result)
      }
    end

    def extract_data(api_result)
      content_types = ['text/plain', 'text/html']
      data = if content_types.include?(api_result.headers['Content-Type'])
               api_result.body.readpartial
             else
               api_result.parse
             end

      return data unless data.is_a?(Hash)

      data.deep_symbolize_keys
    end

    def options(method, data)
      params_key = params_key(method)
      {
        params_key.to_s => data
      }
    end

    def params_key(method)
      case method
      when 'POST', 'PUT'
        'body'
      else
        'params'
      end
    end

    def default_headers
      {
        'Content-Type': 'application/json'
      }.merge(authorization_header)
    end

    def authorization_header
      {
        'Authorization': "Basic #{@encoded_credentials}"
      }
    end
  end
end
