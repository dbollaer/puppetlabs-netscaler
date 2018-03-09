require_relative '../../../puppet/provider/netscaler'
require 'base64'
require 'json'

Puppet::Type.type(:netscaler_file).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "systemfile"
  end

  def self.recursive_instances(dir='')
    instances = []
    #look for files at a certain location
    location=dir.gsub(/\//, '%2F')
    files = Puppet::Provider::Netscaler.call('/config/systemfile',{'args'=>"filelocation:%2Fnsconfig%2F#{location}"})
    return [] if files.nil?


    files.each do |file|
      if file['filemode'] && file['filemode'][0] == 'DIRECTORY'
        instances += recursive_instances("#{file['filename']}/")
      else
        file_contents = Puppet::Provider::Netscaler.call("/config/systemfile", {'args'=>"filelocation:%2Fnsconfig%2F#{location},filename:#{file['filename']}"}) || []
        file_contents.each do |file_content|
          instances << new({
            :ensure   => :present,
            :name     => "#{dir}#{file_content['filename']}",
            :encoding => file_content['fileencoding'],
          })
        end
      end
    end

    instances
  end
  def self.instances
    recursive_instances('')
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name     => :filename,
      :content  => :filecontent,
      :encoding => :fileencoding,
    }
  end

  def immutable_properties
    [
      :encoding,
    ]
  end

  def flush
    if @property_hash and ! @property_hash.empty?
      path = @property_hash[:name]
      filename = File.basename(path)
      path = "/nsconfig/#{File.dirname(path)}".gsub(/\//, '%2F')
      Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{filename}", {'args'=>"filelocation:#{path}"})
      result = create()
    end
    return result
  end

  def destroy
    path = @property_hash[:name]
    filename = File.basename(path)
    path = "/nsconfig/#{File.dirname(path)}".gsub(/\//, '%2F')
    result = Puppet::Provider::Netscaler.delete("/config/#{netscaler_api_type}/#{filename}", {'args'=>"filelocation:#{path}"})
    @property_hash.clear
    return result
  end

  def per_provider_munge(message)
    path = message[:name]
    message[:name] = File.basename(path)
    message[:filelocation] = "/nsconfig/#{File.dirname(path)}"
    message[:content] =  Base64.strict_encode64(message[:content])
    message
  end
end
