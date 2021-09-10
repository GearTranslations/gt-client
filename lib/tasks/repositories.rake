namespace :repositories do
  desc 'Load repositories from .yml'
  task load: :environment do
    file = File.open('repositories.yml')
    file_parse = file.read
    yml = YAML.safe_load(file_parse)
    ActiveRecord::Base.transaction do
      yml['repositories'].each do |repo|
        attributes = repo['repository']

        Repositories::Bitbucket.create!(build_attributes(attributes))
      rescue ActiveRecord::RecordInvalid => e
        puts "Error processing repository #{attributes}"
        puts "Error --> #{e.message}"
        raise e
      end
    end

    puts 'Successful upload'
  end
end

def build_attributes(attributes)
  app_password = attributes.delete('app_password')
  user_name = attributes.delete('user_name')
  server_url = attributes.delete('server_url')
  # TODO: When we have more than one type of repositories
  # Use the platform field to create the indicated repository
  attributes.delete('platform')
  branch_pr_destination = attributes.delete('branch_pull_request_destination')
  metadata = { app_password: app_password, user_name: user_name,
               branch_pull_request_destination: branch_pr_destination,
               server_url: server_url }
  attributes.merge({ metadata: metadata })
end
