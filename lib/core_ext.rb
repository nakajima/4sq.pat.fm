require "cgi"
require "zlib"
require "stringio"

class String
  def blank?
    strip.empty?
  end

  def compress
    output = StringIO.new
    gz = Zlib::GzipWriter.new(output)
    gz.write(self)
    gz.close
    output.string
  end

  def decompress
    Zlib::GzipReader.new(StringIO.new(self)).read
  end
end

class Hash
  def to_query
    inject([]) { |res, (key, val)|
      res << CGI.escape(key.to_s) + "=" + CGI.escape(val.to_s)
      res
    }.join("&")
  end
end
