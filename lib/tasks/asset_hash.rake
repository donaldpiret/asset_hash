require 'asset_hash'

namespace :asset do
  namespace :hash do
    desc 'Generate the assets with the hashed filenames'
    task :generate do
      AssetHash.process!
    end

    desc "Create a custom origin cloudfront distribution"
    task :create_cloudfront_distribution do
      begin
        require 'aws/s3'
        require 'time'
        require 'digest/sha1'
        require 'net/https'
        require 'base64'
        STDOUT.puts "Enter your AWS Access ID (Don't forget to sign up for Cloudfront)"
        access_key_id = STDIN.gets.strip
        STDOUT.puts "Enter your AWS Secret Key"
        secret_access_key = STDIN.gets.strip
        STDOUT.puts "Enter the url of the domain to distribute on cloudfront (eg. google.com)"
        cloudfront_distribution_url = STDIN.gets.strip
        STDOUT.puts "Enter a description for your cloudfront distribution"
        cloudfront_distribution_description = STDIN.gets.strip
        AWS::S3::Base.establish_connection!(
          :access_key_id => access_key_id,
          :secret_access_key => secret_access_key
        )
        digest = OpenSSL::Digest.new('sha1')
        digest = OpenSSL::HMAC.digest(digest, secret_access_key, date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S %Z"))
        uri = URI.parse("https://cloudfront.amazonaws.com/2010-11-01/distribution")
        req = Net::HTTP::Post.new(uri.path)
        req.initialize_http_header({
          'x-amz-date' => date,
          'Content-Type' => 'text/xml',
          'Authorization' => "AWS %s:%s" % [access_key_id, Base64.encode64(digest)]
        })
        req.body = <<EOF
<DistributionConfig xmlns="http://cloudfront.amazonaws.com/doc/2010-11-01/">
<CustomOrigin>
<DNSName>#{cloudfront_distribution_url}</DNSName>
<OriginProtocolPolicy>http-only</OriginProtocolPolicy>
</CustomOrigin>
<Comment>#{cloudfront_distribution_description}</Comment>
<Enabled>true</Enabled>
<CallerReference>#{Time.now.utc.to_i}</CallerReference>
</DistributionConfig>
EOF
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        res = http.request(req)
        STDOUT.puts res.code == '201' ? "Distribution created: #{res.body.match(/\<Id\>(.+)\<\/Id\>/)[1]}" : "Distribution failed: #{res.body}"
      rescue LoadError => e
        STDERR.puts "Could not find the aws-s3 gem, Run `gem install aws-s3` to install s3"
      end
    end
  end
end