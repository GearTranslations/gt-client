module CustomTestHelpers
  def file_fixture(path)
    File.new("spec/support/fixtures/#{path}")
  end

  def json_fixture(path)
    file = file_fixture(path)
    JSON.parse(file.read)
  end
end
