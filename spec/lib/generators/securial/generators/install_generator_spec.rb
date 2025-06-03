require "rails_helper"
require "generators/securial/install/install_generator"

RSpec.describe Securial::Generators::InstallGenerator, type: :generator do
  let(:destination_root) { Securial::Engine.root.join("tmp") }
  let(:engine) { Securial::Engine.instance }

  destination Securial::Engine.root.join("tmp")

  before do
    prepare_destination
    allow(Rails).to receive(:root).and_return(destination_root)
    allow(destination_root).to receive(:join) { |*args| Pathname.new(File.join(destination_root, *args)) }
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe "copy_initializer" do
    it "copies the securial initializer" do
      run_generator
      assert_file File.join(destination_root, "config", "initializers", "securial.rb") do |content|
        assert_match(/Securial.configure do \|config\|/, content)
        assert_match(/config.log_to_file = true/, content)
        assert_match(/config.log_to_stdout = true/, content)
        assert_match(/config.log_file_level = :debug/, content)
        assert_match(/config.log_stdout_level = :debug/, content)
      end
    end
  end

  describe "create_log_file" do
    it "creates the log directory if it doesn't exist" do
      run_generator
      expect(File.directory?(File.join(destination_root, "log"))).to be true
    end

    it "creates the log file" do
      run_generator
      expect(File.exist?(File.join(destination_root, "log", "securial.log"))).to be true
    end

    context "when log directory already exists" do
      before do
        FileUtils.mkdir_p(File.join(destination_root, "log"))
      end

      it "doesn't raise error" do
        expect { run_generator }.not_to raise_error
      end

      it "creates the log file" do
        run_generator
        expect(File.exist?(File.join(destination_root, "log", "securial.log"))).to be true
      end
    end

    context "when log file already exists" do
      before do
        FileUtils.mkdir_p(File.join(destination_root, "log"))
        FileUtils.touch(File.join(destination_root, "log", "securial.log"))
      end

      it "doesn't raise error" do
        expect { run_generator }.not_to raise_error
      end
    end
  end

  # describe "install_migrations" do
  #   skip "does not invoke migration task in test environment"
  # end
end
