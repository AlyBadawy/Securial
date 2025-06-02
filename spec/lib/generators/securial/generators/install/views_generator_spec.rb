require "rails_helper"
require "generators/securial/install/views_generator"

RSpec.describe Securial::Generators::Install::ViewsGenerator, type: :generator do
  destination File.expand_path("../../../tmp/spec_generator_test", __FILE__)
  let(:fake_source_root) { File.join(destination_root, "source_root") }

  before do
    prepare_destination
    # Set up a fake source_root with files and directories
    FileUtils.mkdir_p(File.join(fake_source_root, "users"))
    File.write(File.join(fake_source_root, "users", "show.html.erb"), "dummy user view")
    File.write(File.join(fake_source_root, "index.html.erb"), "dummy index view")
    FileUtils.mkdir_p(File.join(fake_source_root, "empty_dir"))
    # Stub the generator's source_root to point at the fake source root
    allow(described_class).to receive(:source_root).and_return(fake_source_root)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  it "copies all securial views and directories to the app/views/securial directory" do
    run_generator
    expect(File).to exist(File.join(destination_root, "app/views/securial/users/show.html.erb"))
    expect(File).to exist(File.join(destination_root, "app/views/securial/index.html.erb"))
    expect(File.read(File.join(destination_root, "app/views/securial/users/show.html.erb"))).to eq("dummy user view")
    expect(File.read(File.join(destination_root, "app/views/securial/index.html.erb"))).to eq("dummy index view")
  end

  it "creates empty directories for sub-folders" do
    run_generator
    expect(File).to exist(File.join(destination_root, "app/views/securial/empty_dir"))
    expect(File.directory?(File.join(destination_root, "app/views/securial/empty_dir"))).to be true
  end
end
