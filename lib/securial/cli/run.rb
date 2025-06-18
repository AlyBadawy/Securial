# rubocop:disable Rails/Output
def run(command, chdir: nil)
  puts "→ #{command}"
  if chdir
    Dir.chdir(chdir) do
      system(command) || abort("❌ Command failed: #{command}")
    end
  else
    system(command) || abort("❌ Command failed: #{command}")
  end
end
