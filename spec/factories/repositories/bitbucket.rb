FactoryBot.define do
  factory(
    :repository_bitbucket, class: 'Repositories::Bitbucket', parent: :repository
  ) do
    type { 'Repositories::Bitbucket' }

    metadata do
      {
        user_name: Faker::Internet.username,
        app_password: Faker::Crypto.md5,
        branch_pull_request_destination: 'main',
        server_url: 'https://server.bitbucket-url.com'
      }
    end
  end
end
