require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')
require_relative('../../puppet/property/netscaler_traffic_domain')

Puppet::Type.newtype(:netscaler_policyexpression) do
  @doc = 'Configuration for expression resource.'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)

  newproperty(:value) do
    desc "Expression string. For example: http.req.body(100).contains(\"this\")."
  end

  newproperty(:description) do
    desc "Description for the expression."
  end

  newproperty(:comment) do
    desc "Any comments associated with the expression. Displayed upon viewing the policy expression."
  end


  newproperty(:client_security_message) do
    desc "Message to display if the expression fails. Allowed for classic end-point check expressions only. Minimum length = 1"
  end

  newproperty(:type) do
    desc "Type of expression. Can be a classic or default syntax (advanced) expression. Possible values = CLASSIC, ADVANCED"

    validate do |value|
      if ! [:CLASSIC,:ADVANCED].any?{ |s| s.to_s.eql? value }
        fail ArgumentError, "Valid options: CLASSIC, ADVANCED"
      end
    end

    munge(&:upcase)
  end



end
