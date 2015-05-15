# The parameters which are defined in the class can get their parameters
# either by direct definition or by specifying hiera values for them.
# For example, one can define nova_os_username directly in yaml as
# cloud::network::nuage-metadata::nova_os_username = "admin" and
# they can define nova_metadata_ip as cloud::network::nuage-metadata
# ::nova_metadata_ip = hiera{nova_metadata_ip} as that will be set
# anyway as a value for neutron.conf.

# == Class: cloud::network::nuage_metadata
#
# Network Metadata node
#
# === Parameters:
#
# [*neutron_metadata_proxy_shared_secret*]
#   Shared secret to validate proxies Neutron metadata requests
#   Defaults to 'metadatapassword'
#
# [*nova_metadata_ip*] -- not sure yet if this should be included.
#   (optional) Hostname or IP of the Nova metadata server
#   Defaults to '127.0.0.1'
#
# [*nova_api_endpoint_type*]
# NOVA_API_ENDPOINT_TYPE: one of publicURL, internalURL, adminURL
# Defaults to publicURL
#
# [*nova_os_username*]
# Defaults to admin
#
# [*nova_os_password*]
# Defaults to admin
#
# [*nova_os_tenant_name*]
# Defaults to demo
#

class cloud::network::nuage_metadata(
  $neutron_metadata_proxy_shared_secret = 'NuageNetworksSharedSecret',
  $nova_metadata_ip                     = '127.0.0.1',
  $nova_api_endpoint_type               = 'publicURL',
  $nova_os_username                     = 'admin',
  $nova_os_password                     = 'admin',
  $nova_os_tenant_name                  = 'demo',
  $metadata_port                        = '9697',
  $nova_metadata_port                   = '8775',
  $nova_client_version                  = '2',
  $nova_os_auth_url                     = undef,
  $nuage_metadata_agent_starts_with_ovs = 'True',
) {

  class { 'nuage::metadata':
    nuage_metadata_port                 => $metadata_port,
    nuage_nova_metadata_ip              => $nova_metadata_ip,    
    nuage_nova_metadata_port            => $nova_metadata_port,
    shared_secret                       => $neutron_metadata_proxy_shared_secret,
    nuage_nova_client_version           => $nova_client_version,
    nuage_nova_os_username              => $nova_os_username,
    nuage_nova_os_password              => $nova_os_password, 
    nuage_nova_os_tenant_name           => $nova_os_tenant_name,
    nuage_nova_os_auth_url              => $nova_os_auth_url,
### OR nuage_nova_os_auth_rul           => 'http://$nova_metadata_ip:5000/v2.0'
## and remove the $nova_os_auth_url from the class cloud::network::nuage-metadata
    nuage_metadata_agent_start_with_ovs => $nuage_metadata_agent_starts_with_ovs,
    nuage_nova_api_endpoint_type        => $nova_api_endpoint_type
  }

#  Call to neutron_config has not been made as the parameters
#  in neutron.conf are assumed to be set already.
}
