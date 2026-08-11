# typed: false
# frozen_string_literal: true

class Tokenlive < Formula
  desc "All-in-one LLM API gateway and admin console"
  homepage "https://github.com/tokenlive/tokenlive-standalone"
  version "0.5.0"
  license "Apache-2.0"

  if Hardware::CPU.arm?
    url "https://github.com/tokenlive/tokenlive-standalone/releases/download/v0.5.0/tokenlive-0.5.0-darwin-arm64.tar.gz"
    sha256 "b1fbe02c13cfac33d95051c53995013f4cc3bc849c81004f78f7e1cd0cd363e7"
  else
    odie "TokenLive prebuilt binaries are only available for Apple Silicon (arm64). Build from source instead."
  end

  def install
    bin.install "bin/tokenlive"
    (pkgshare/"admin").install Dir["share/tokenlive/admin/*"]
    (pkgshare/"web").install Dir["share/tokenlive/web/*"] if Dir["share/tokenlive/web/*"].any?

    (etc/"tokenlive").mkpath
    (etc/"tokenlive").install "etc/tokenlive/config.yml" unless (etc/"tokenlive/config.yml").exist?
    (etc/"tokenlive").install "etc/tokenlive/config.example.yml"
    (var/"tokenlive").mkpath
  end

  def caveats
    <<~EOS
      Start:
        brew services start tokenlive
        # or: tokenlive (foreground)

      Open http://127.0.0.1:2525 — login admin / admin
      Config: #{etc}/tokenlive/config.yml
    EOS
  end

  service do
    run [opt_bin/"tokenlive"]
    keep_alive true
    working_dir var/"tokenlive"
    log_path var/"log/tokenlive.log"
    error_log_path var/"log/tokenlive.err.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tokenlive -version")
  end
end
