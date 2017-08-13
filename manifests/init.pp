# Full description of SIMP module 'spmasq' here.
#
# === Welcome to SIMP!
#
# This module is a component of the System Integrity Management Platform, a
# managed security compliance framework built on Puppet.
#
# ---
# *FIXME:* verify that the following paragraph fits this module's characteristics!
# ---
#
# This module is optimally designed for use within a larger SIMP ecosystem, but
# it can be used independently:
#
# * When included within the SIMP ecosystem, security compliance settings will
#   be managed from the Puppet server.
#
# * If used independently, all SIMP-managed security subsystems are disabled by
#   default, and must be explicitly opted into by administrators.  Please
#   review the +trusted_nets+ and +$enable_*+ parameters for details.
#
# @param service_name
#   The name of the spmasq service
#
# @param package_name
#   The name of the spmasq package
#
# @param trusted_nets
#   A whitelist of subnets (in CIDR notation) permitted access
#
# @param enable_auditing
#   If true, manage auditing for spmasq
#
# @param enable_firewall
#   If true, manage firewall rules to acommodate spmasq
#
# @param enable_logging
#   If true, manage logging configuration for spmasq
#
# @param enable_pki
#   If true, manage PKI/PKE configuration for spmasq
#
# @param enable_selinux
#   If true, manage selinux to permit spmasq
#
# @param enable_tcpwrappers
#   If true, manage TCP wrappers configuration for spmasq
#
# @author Chad Quilter
#
class spmasq (
  String                        $service_name       = 'spmasq',
  String                        $package_name       = 'spmasq',
  Simplib::Port                 $tcp_listen_port    = 9999,
  Simplib::Netlist              $trusted_nets       = simplib::lookup('simp_options::trusted_nets', {'default_value' => ['127.0.0.1/32'] }),
  Boolean                       $enable_pki         = simplib::lookup('simp_options::pki', { 'default_value'         => false }),
  Boolean                       $enable_auditing    = simplib::lookup('simp_options::auditd', { 'default_value'      => false }),
  Variant[Boolean,Enum['simp']] $enable_firewall    = simplib::lookup('simp_options::firewall', { 'default_value'    => false }),
  Boolean                       $enable_logging     = simplib::lookup('simp_options::syslog', { 'default_value'      => false }),
  Boolean                       $enable_selinux     = simplib::lookup('simp_options::selinux', { 'default_value'     => false }),
  Boolean                       $enable_tcpwrappers = simplib::lookup('simp_options::tcpwrappers', { 'default_value' => false })
) {

  $oses = load_module_metadata( $module_name )['operatingsystem_support'].map |$i| { $i['operatingsystem'] }
  unless $::operatingsystem in $oses { fail("${::operatingsystem} not supported") }

  include '::spmasq::install'
  include '::spmasq::config'
  include '::spmasq::service'

  Class[ '::spmasq::install' ]
  -> Class[ '::spmasq::config' ]
  ~> Class[ '::spmasq::service' ]

  if $enable_pki {
    include '::spmasq::config::pki'
    Class[ '::spmasq::config::pki' ]
    -> Class[ '::spmasq::service' ]
  }

  if $enable_auditing {
    include '::spmasq::config::auditing'
    Class[ '::spmasq::config::auditing' ]
    -> Class[ '::spmasq::service' ]
  }

  if $enable_firewall {
    include '::spmasq::config::firewall'
    Class[ '::spmasq::config::firewall' ]
    -> Class[ '::spmasq::service' ]
  }

  if $enable_logging {
    include '::spmasq::config::logging'
    Class[ '::spmasq::config::logging' ]
    -> Class[ '::spmasq::service' ]
  }

  if $enable_selinux {
    include '::spmasq::config::selinux'
    Class[ '::spmasq::config::selinux' ]
    -> Class[ '::spmasq::service' ]
  }

  if $enable_tcpwrappers {
    include '::spmasq::config::tcpwrappers'
    Class[ '::spmasq::config::tcpwrappers' ]
    -> Class[ '::spmasq::service' ]
  }
}
