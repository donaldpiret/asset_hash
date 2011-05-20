require 'asset_hash'
begin
  require 'rails'
  module AssetHash
    class Railtie < Rails::Railtie
      rake_tasks do
        load "tasks/asset_hash.rake"
      end
    end
  end
rescue LoadError
end
