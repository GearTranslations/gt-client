class CreateService
  def self.for(repository)
    return Bitbucket::Client.new(repository) if repository.is_a? Repositories::Bitbucket
  end
end
