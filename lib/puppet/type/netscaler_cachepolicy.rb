require_relative('../../puppet/parameter/netscaler_name')
require_relative('../../puppet/property/netscaler_truthy')

Puppet::Type.newtype(:netscaler_cachepolicy) do
  @doc = 'Manage basic netscaler cache policy objects'

  apply_to_device
  ensurable

  newparam(:name, :parent => Puppet::Parameter::NetscalerName, :namevar => true)
  #XXX Validat with the below
  #ensure: change from absent to present failed: Could not set 'present' on ensure: REST failure: HTTP status code 400 detected.  Body of failure is: { "errorcode": 1075, "message": "Invalid name; names must begin with an alphanumeric character or underscore and must contain only alphanumerics, '_', '#', '.', ' ', ':', '@', '=' or '-' [name, hunner's website]", "severity": "ERROR" } at 55:/etc/puppetlabs/puppet/environments/produc

  newproperty(:expression) do
    desc "Expression, or name of a named expression, against which traffic is evaluated. Written in the classic or default syntax.
  Note:
  Maximum length of a string literal in the expression is 255 characters. A longer string can be split into smaller strings of up to 255 characters each, and the smaller strings concatenated with the + operator. For example, you can create a 500-character string as follows: '\"<string of 255 characters>\" \+ \"<string of 245 characters>\"'
  The following requirements apply only to the NetScaler CLI:
  * If the expression includes one or more spaces, enclose the entire expression in double quotation marks.
  * If the expression itself includes double quotation marks, escape the quotations by using the \ character.
  * Alternatively, you can use single quotation marks to enclose the rule, in which case you do not have to escape the double quotation marks."
  end

  newproperty(:action) do
    desc "Name of the cache action to perform if the request matches this cache policy."
  end

  #The content group must exist before being mentioned here. Use the "show cache contentgroup" command to view the list of existing content groups. Minimum length = 1
  newproperty(:storeingroup) do
    desc "Name of the content group in which to store the object when the final result of policy evaluation is CACHE"
  end

  newproperty(:invalgroups) do
    desc "Content group(s) to be invalidated when the INVAL action is applied. Maximum number of content groups that can be specified is 16."
  end

  newproperty(:invalobjects) do
    desc "Content groups(s) in which the objects will be invalidated if the action is INVAL."
  end

  newproperty(:undefaction) do
    desc "Action to be performed when the result of rule evaluation is undefined.<br> Possible values = NOCACHE, RESET"
  end

  newproperty(:newname) do
    desc "New name for the cache policy. Must begin with an ASCII alphabetic or underscore (_) character, and must contain only ASCII alphanumeric, underscore, hash (#), period (.), space, colon (:), at (@), equals (=), and hyphen (-) characters."
  end

end
