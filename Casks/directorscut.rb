cask "directorscut" do
  version "0.1.9"
  sha256 "ab49dd796ea91b57f0413af59cdc47a04492ca2b1ab67a64ef97ed1ef2ccb3ad"

  url "https://github.com/MatthewWaller/homebrew-directorscut/releases/download/v#{version}/directorscut-#{version}-arm64.tar.gz"
  name "DirectorsCut"
  desc "AI video editing from the command line"
  homepage "https://github.com/MatthewWaller/homebrew-directorscut"

  depends_on macos: ">= :monterey"
  depends_on arch: :arm64
  depends_on formula: "ffmpeg"

  binary "directorscut/directorscut"

  postflight do
    # Remove quarantine so Gatekeeper doesn't block the unsigned binary
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", staged_path/"directorscut"],
                   sudo: false

    # Warm up macOS code signature verification so the first user command is fast
    system_command (staged_path/"directorscut"/"_env"/"bin"/"python").to_s,
                   args: ["-c", "print('ok')"],
                   print_stderr: false

    config_dir = Pathname.new(Dir.home) / ".directorscut"
    config_dir.mkpath unless config_dir.exist?

    env_file = config_dir / ".env"
    unless env_file.exist?
      env_example = staged_path / "directorscut" / ".env.example"
      FileUtils.cp(env_example, env_file) if env_example.exist?
    end

  end

  caveats <<~EOS
    Get started in three steps:

      1. Run interactive setup (adds your Gemini key + local TTS):
           directorscut setup

      2. Verify your install:
           directorscut doctor

      3. Make your first video:
           directorscut edit -p "your prompt" -f ./footage -o ./my_project

    Config lives at: ~/.directorscut/.env
    See the Tutorial for setting up local TTS with a reference audio file.
  EOS
end
