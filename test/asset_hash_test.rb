require 'test_helper'

class AssetHashTest < ActiveSupport::TestCase
  #setup :clear_resource_directories

  setup :set_asset_paths
  teardown :clear_resource_directories

  test "truth" do
    assert_kind_of Module, AssetHash
  end

  test "copies with asset_hash and gzips a css file" do
    File.open(File.expand_path("../dummy/public/stylesheets/sample.css",  __FILE__), 'w') do |f|
      f.write("#body {background-color: #000000;}")
    end
    AssetHash.process!
    assert File.exists?(File.join(Rails.root, 'public', AssetHash::Base.fingerprint(File.expand_path("../dummy/public/stylesheets/sample.css",  __FILE__)))), "Could not find fingerprinted asset: #{AssetHash::Base.fingerprint(File.expand_path('../dummy/public/stylesheets/sample.css',  __FILE__))}"
    finger_print_hash = AssetHash::Base.fingerprint(File.expand_path("../dummy/public/stylesheets/sample.css",  __FILE__)).match(/sample-id-([^\.]+)\./)[1]
    puts "Fingerprint hash: #{finger_print_hash}"
    assert File.exists?(File.join(Rails.root, 'public', AssetHash::Base.fingerprint(File.expand_path("../dummy/public/stylesheets/sample.css",  __FILE__)) + ".gz")), "Could not find gzipped fingerprinted asset"
    #assert Dir.entries(File.join(Rails.root, 'public', 'stylesheets')).detect {|f| f.match /^sample-id-(.)+\.css\.gz$/ }, "Could not find gzipped fingerprinted asset"
  end

  test "copies images with asset_hash and does not gzip them" do
    File.open(File.expand_path("../dummy/public/images/test.png",  __FILE__), 'w') do |f|
      f.write(File.open(File.expand_path("../support/test.png",  __FILE__)))
    end
    AssetHash.process!
    assert File.exists?(File.join(Rails.root, 'public', AssetHash::Base.fingerprint(File.expand_path("../dummy/public/images/test.png",  __FILE__)))), "Could not find fingerprinted asset"
    assert !Dir.entries(File.join(Rails.root, 'public', 'images')).detect {|f| f.match /^test-id-(.)+\.png\.gz$/ }, "Image was gzipped"
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
