require 'asset_hash'

namespace :asset do
  namespace :hash do
    desc 'Generate the assets with the hashed filenames'
    task :generate do
      AssetHash.process!
    end
  end
end