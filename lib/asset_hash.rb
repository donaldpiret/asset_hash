require 'digest/md5'
require 'time'
require 'mime/types'
require 'asset_hash/railtie' if defined?(Rails::Railtie)

module AssetHash
  def self.process!
    AssetHash::Base.process!
  end

  def self.fingerprint(path)
    AssetHash::Base.fingerprint(path)
  end

  class Base
    DEFAULT_ASSET_PATHS = ['favicon.ico', 'images', 'javascripts', 'stylesheets', 'assets']
    @@asset_paths = DEFAULT_ASSET_PATHS

    DEFAULT_GZIP_TYPES = ['text/css', 'application/javascript']
    @@gzip_types = DEFAULT_GZIP_TYPES

    def self.gzip_types=(types)
      @@gzip_types = types
    end

    def self.gzip_types
      @@gzip_types
    end

    def self.path_prefix
      defined?(Rails) ? File.join(Rails.root, 'public') : ''
    end

    def self.asset_paths=(paths)
      @@asset_paths = paths
    end

    def self.asset_paths
      @@asset_paths
    end

    def self.absolute_path(path)
      File.join path_prefix, path
    end

    def self.assets
      asset_paths.inject([]) {|assets, path|
        path = absolute_path(path)
        assets << path if File.exists? path and !File.directory? path
        assets += Dir.glob(path+'/**/*').inject([]) {|m, file|
          m << file unless File.directory? file; m
        }
      }
    end

    def self.fingerprint(path)
      path = File.join path_prefix, path unless path =~ /#{path_prefix}/
      begin
        d = Digest::MD5.file(path).hexdigest
        path = path.gsub(path_prefix, '')
        extension = (path =~ /\.gz$/ ? File.extname(File.basename(path, ".gz")) + ".gz" : File.extname(path))
        File.join File.dirname(path), "#{File.basename(path, extension)}-#{d}#{extension}"
      rescue Errno::ENOENT
        return original_path(path)#path.gsub(path_prefix, '')
      end
    end

    def self.original_path(path)
      path = path.gsub(path_prefix, '')
      extension = (path =~ /\.gz$/ ? File.extname(File.basename(path, ".gz")) + ".gz" : File.extname(path))
      File.join File.dirname(path), "#{File.basename(path, extension)}#{extension}"
    end

    def self.process!
      assets.each do |asset|
        mime_type = MIME::Types.of(asset).first.to_s
        if gzip_types.include?(mime_type) && !File.exists?(asset + ".gz")
          # You can GZIP the type of this file and no gzipped version was found already
          # Gzip the original asset then move it to the right filename
          gz_path = asset + ".gz"
          `gzip -c "#{asset}" > "#{gz_path}"`
          FileUtils.mv(gz_path, File.join(path_prefix, fingerprint(asset) + ".gz"))
        end
        FileUtils.cp(asset, File.join(path_prefix, fingerprint(asset)))
      end
    end

  end

end
