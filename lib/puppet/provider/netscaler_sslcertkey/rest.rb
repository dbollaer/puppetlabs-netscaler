require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_sslcertkey).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "sslcertkey"
  end

  def self.instances
    instances = []
    sslcertkeys = Puppet::Provider::Netscaler.call('/config/sslcertkey')
    return [] if sslcertkeys.nil?

    sslcertkeys.each do |sslcertkey|
      instances << new({
        :ensure               => :present,
        :name                 => sslcertkey['certkey'],
        :certificate_filename => sslcertkey['cert'],
        :key_filename         => sslcertkey['key'],
        :password             => sslcertkey['password'],
        :fipskey              => sslcertkey['fipskey'],
        :certificate_format   => sslcertkey['inform'],
        :passplain            => sslcertkey['passplain'],
        :notify_when_expires  => sslcertkey['expirymonitor'],
        :notification_period  => sslcertkey['notificationperiod'],
        :bundle               => sslcertkey['bundle'],
        :linkcert_keyname     => sslcertkey['linkcertkeyname'],
        :nodomain_check       => sslcertkey['nodomaincheck'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
    :name                 => :certkey,
    :certificate_filename => :cert,
    :key_filename         => :key,
    :password             => :password,
    :fipskey              => :fipskey,
    :certificate_format   => :inform,
    :passplain            => :passplain,
    :notify_when_expires  => :expirymonitor,
    :notification_period  => :notificationperiod,
    :bundle               => :bundle,
    :linkcert_keyname     => :linkcertkeyname,
    :nodomain_check       => :nodomaincheck,
    }
  end

  def immutable_properties
    [
      :certificate_filename,
      :key_filename,
      :password,
      :fipskey,
      :certificate_format,
      :passplain,
      :bundle,
      :nodomain_check,
    ]
  end

  def per_provider_munge(message)
    if message[:linkcert_keyname]
      message.delete(:linkcert_keyname)
    end
    message
  end

  def create
    @create_elements = true
    result = super
    if (result.status == 200 or result.status == 201) and resource[:linkcert_keyname]
      binding_property_hash = {:certkey => resource[:name], :linkcertkeyname => resource[:linkcert_keyname] }
      result = Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}", message_custom(binding_property_hash, "sslcertkey"), {"action" => "link"})
    end
    @property_hash.clear
    return result
  end

  def destroy
    if (resource[:linkcert_keyname])
      binding_property_hash = {:certkey => resource[:name]}
      Puppet::Provider::Netscaler.post("/config/#{netscaler_api_type}", message_custom(binding_property_hash, "sslcertkey"), {"action" => "unlink"})
    end
    result = super
    @property_hash.clear
    return result
  end

  def message_custom(object, api_type)
    message = object.clone.to_hash
    message = { api_type => message }
    message = message.to_json
    message
  end
end
