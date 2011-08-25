require File.expand_path("../test_helper",  __FILE__)

class AssetHashTest < ActiveSupport::TestCase
  #setup :clear_resource_directories

  setup :set_asset_paths
  teardown :clear_resource_directories

  test "truth" do
    assert_kind_of Module, AssetHash
  end

  test "AssetHash.process! in a rails app copies with asset_hash and gzips a css file" do
    path = File.expand_path("../dummy/public/stylesheets/sample.css",  __FILE__)
    File.open(path, 'w') do |f|
      f.write("#body {background-color: #000000;}")
    end
    AssetHash.process!
    assert File.exists?(File.join(Rails.root, 'public', AssetHash.fingerprint(path))), "Could not find fingerprinted asset: #{AssetHash.fingerprint(path)}"
    assert File.exists?(File.join(Rails.root, 'public', AssetHash.fingerprint(path) + ".gz")), "Could not find gzipped fingerprinted asset"
  end

  test "copies images with asset_hash and does not gzip them" do
    path = File.expand_path("../dummy/public/images/test.png",  __FILE__)
    File.open(path, 'w') do |f|
      f.write(File.open(File.expand_path("../support/test.png",  __FILE__)))
    end
    AssetHash.process!
    assert File.exists?(File.join(Rails.root, 'public', AssetHash.fingerprint(path))), "Could not find fingerprinted asset"
    assert !Dir.entries(File.join(Rails.root, 'public', 'images')).detect {|f| f.match /^test-(.)+\.png\.gz$/ }, "Image was gzipped"
  end

  test "the fingerprint method should return the filename with an asset hash inserted" do
    path = File.expand_path("../dummy/public/stylesheets/sample.css",  __FILE__)
    File.open(path, 'w') do |f|
      f.write("#body {background-color: #000000;}")
    end
    md5_hash = Digest::MD5.file(path).hexdigest
    finger_print = AssetHash::Base.fingerprint(path)
    assert_equal finger_print, "/stylesheets/sample-#{md5_hash}.css"
  end

  test "the fingerprint method should fallback to the normal filename" do
    assert_equal "/stylesheets/non-existing.css", AssetHash.fingerprint(File.expand_path("../dummy/public/stylesheets/non-existing.css",  __FILE__))
  end

  protected

  def set_asset_paths
    AssetHash::Base.asset_paths = ['stylesheets', 'images']
  end

  def clear_resource_directories
    %w(images javascripts stylesheets).each do |dirname|
      Dir["#{File.expand_path("../dummy/public/#{dirname}",  __FILE__)}/*"].each do |file|
        next if File.basename(file) == File.basename(File.expand_path("../dummy/public/#{dirname}",  __FILE__))
        FileUtils.rm_rf file
      end
    end
  end
end
