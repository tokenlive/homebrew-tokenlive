# typed: false
# frozen_string_literal: true

# Homebrew Formula for TokenLive all-in-one.
#
# Local install (sibling gateway + admin checkouts):
#   ./scripts/brew-install-local.sh
#
# After install:
#   brew services start tokenlive   # when formula is registered
#   tokenlive-start                 # LaunchAgent helper
#   tokenlive                       # foreground (paths baked in)
#
class Tokenlive < Formula
  desc "TokenLive all-in-one LLM API gateway and admin console"
  homepage "https://github.com/tokenlive/tokenlive-standalone"
  version "0.9.1"
  license "Apache-2.0"

  if Hardware::CPU.intel?
    url "https://github.com/tokenlive/tokenlive-standalone/releases/download/v0.9.1/tokenlive-0.9.1-darwin-amd64.tar.gz"
    sha256 "122f33f03afd455822d444406fbce1a0d302e3020bf5a06194146a4c39e7fc35"
  else
    url "https://github.com/tokenlive/tokenlive-standalone/releases/download/v0.9.1/tokenlive-0.9.1-darwin-arm64.tar.gz"
    sha256 "6956464af87a0d103535218b8986da47c321f03d075c668941f0ba757d6a0bab"
  end

  def install
    bin.install "bin/tokenlive"
    (pkgshare/"admin").install Dir["share/tokenlive/admin/*"]
    (pkgshare/"web").mkpath
    (pkgshare/"web").install Dir["share/tokenlive/web/*"] if Dir["share/tokenlive/web/*"].any?
    libexec.install "libexec/install-brew-config.sh"

    (etc/"tokenlive").mkpath
    system "bash",
           libexec/"install-brew-config.sh",
           buildpath/"etc/tokenlive/config.yml",
           etc/"tokenlive"

    rm_f etc/"tokenlive/config.example.yml"
    (etc/"tokenlive").install "etc/tokenlive/config.example.yml"
    (var/"tokenlive").mkpath
  end

  def caveats
    <<~EOS
      Start:
        brew services start tokenlive
        # or: tokenlive

      Logs & Status:
        tokenlive logs
        tokenlive logs -f
        tokenlive logs -e
        tokenlive logs --check
        tokenlive status

      Open http://127.0.0.1:2525 — login admin / admin
      Active config: #{etc}/tokenlive/config.yml
      Latest default: #{etc}/tokenlive/config.yml.default

      Modified active configs are preserved during upgrades. Compare with:
        diff #{etc}/tokenlive/config.yml #{etc}/tokenlive/config.yml.default
    EOS
  end

  # Binary-only service; conf/data/admin/web come from build-time defaults.
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
