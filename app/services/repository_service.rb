class RepositoryService
  def file(_branch, _file_name)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def last_file_change(_branch, _file_name)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def upload_file(_branch_name, _file, _upload_path)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def create_pull_request(_title, _branch_destination, _branch_source)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  private

  def extract_data(_api_result)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
