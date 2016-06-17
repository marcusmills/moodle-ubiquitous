#
# Ubiquitous Moodle
#
# @author Luke Carrier <luke.carrier@floream.com>
# @copyright 2015 Floream Limited
#

require "digest"
require "logger"
require "net/http"

class CacheManager
  @cache_dir = nil
  @entries   = []
  @logger    = nil

  def initialize(cache_dir, entries, logger)
    @cache_dir = cache_dir
    @entries   = entries
    @logger    = logger
  end

  def log(severity, message)
    @logger.send(severity, message) unless @logger.nil?
  end

  def process()
    @entries.each do |entry|
      self.log :info, "Checking #{entry[:name]}..."
      entry[:qualified_filename] = File.join @cache_dir, entry[:filename]

      until self.valid? entry do
        self.attempt entry
      end
    end
  end

  def valid?(entry)
    if !File.file? entry[:qualified_filename]
      self.log :info, "\tFile #{entry[:filename]} doesn't exist"
      return false
    end

    unless self.valid_md5sum? entry[:qualified_filename], entry[:checksum]
      self.log :warn, "\tChecksum didn't match expected #{entry[:checksum]}"
      return false
    end

    self.log :info, "\tSuccess"
    return true
  end

  def attempt(entry)
    file = File.open entry[:qualified_filename], 'wb'

    begin
      self.download URI.parse(entry[:uri]), file
    ensure
      file.close
    end
  end

  def download(uri, file)
    Net::HTTP.start uri.host, uri.port do |http|
      http.request_get uri.path do |response|
        response.read_body {|segment| file.write segment}
      end
    end
  end

  def valid_md5sum?(filename, md5sum)
    return Digest::MD5.file(filename).hexdigest == md5sum
  end
end

cache = CacheManager.new(File.expand_path("../cache", __FILE__), [
], Logger.new(STDOUT))
cache.process