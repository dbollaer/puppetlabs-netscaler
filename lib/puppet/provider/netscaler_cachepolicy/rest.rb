require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_cachepolicy).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "cachepolicy"
  end

  def self.instances
    instances = []
    cachepolicys = Puppet::Provider::Netscaler.call('/config/cachepolicy')
    return [] if  cachepolicys.nil?

    cachepolicys.each do |cachepolicy|
      instances << new({
        :ensure       => :present,
        :name         => cachepolicy['policyname'],
        :expression   => cachepolicy['rule'],
        :action       => cachepolicy['action'],
        :storeingroup => cachepolicy['storeingroup'],
        :invalgroups  => cachepolicy['invalgroups'],
        :invalobjects => cachepolicy['invalobjects'],
        :undefaction  => cachepolicy['undefaction'],
        :newname      => cachepolicy['newname'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :name       => :policyname,
      :expression => :rule,
    }
  end

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end
end
