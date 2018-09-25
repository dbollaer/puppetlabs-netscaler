require_relative '../../../puppet/provider/netscaler'
require 'json'

Puppet::Type.type(:netscaler_policyexpression).provide(:rest, {:parent => Puppet::Provider::Netscaler}) do
  def netscaler_api_type
    "policyexpression"
  end

  def self.instances
    instances = []
    policyexpressions = Puppet::Provider::Netscaler.call('/config/policyexpression')
    return [] if  policyexpressions.nil?

    policyexpressions.each do |policyexpression|
      instances << new({
        :ensure                  => :present,
        :name                    => policyexpression['name'],
        :value                   => policyexpression['value'],
        :description             => policyexpression['description'],
        :comment                 => policyexpression['comment'],
        :client_security_message => policyexpression['clientsecuritymessage'],
        :type                    => policyexpression['type'],
      })
    end

    instances
  end

  mk_resource_methods

  # Map for conversion in the message.
  def property_to_rest_mapping
    {
      :client_security_message  => :clientsecuritymessage,
    }
  end

  def immutable_properties
    []
  end

  def per_provider_munge(message)
    message
  end
end
