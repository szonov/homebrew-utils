class ReindexerAT4 < Formula
  env :std
  desc "Reindexer is a fast document-oriented in-memory database"
  homepage "https://github.com/restream/reindexer"
  url "https://github.com/Restream/reindexer/archive/refs/tags/v4.14.0.tar.gz"
  sha256 "ce5e988cfea6a7389d69778b3d131359429c53fbfcb27a2ea46d18c7ee627350"

  head "https://github.com/restream/reindexer.git"

  depends_on "cmake" => :build
  depends_on "leveldb"

  def install
    mkdir "build"
    cd "build" do
      system "cmake", "-DCMAKE_INSTALL_PREFIX=#{prefix}", ".."
      system "make", "-j8", "reindexer_server", "reindexer_tool", "install"
    end

    mkdir "#{var}/reindexer@4"
    mkdir "#{var}/log/reindexer@4"

    inreplace "#{buildpath}/build/cpp_src/cmd/reindexer_server/contrib/config.yml" do |s|
      s.gsub! "/var/lib/reindexer", "#{var}/reindexer@4"
      s.gsub! "/var/log/reindexer", "#{var}/log/reindexer@4"
      s.gsub! "user:", "# user:"
    end

    etc.install "#{buildpath}/build/cpp_src/cmd/reindexer_server/contrib/config.yml" => "reindexer@4.conf"
  end

  def caveats
    <<-EOS
      The configuration file is available at:
        #{etc}/reindexer@4.conf
      The database itself will store data at:
        #{var}/reindexer@4/
    EOS
  end

  service do
    run [opt_bin/"reindexer_server", "--config", etc/"reindexer@4.conf"]
    log_path var/"log/reindexer@4/reindexer.log"
    error_log_path var/"log/reindexer@4/reindexer.log"
  end
end
