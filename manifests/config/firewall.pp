# == Class spmasq::config::firewall
#
# This class is meant to be called from spmasq.
# It ensures that firewall rules are defined.
#
class spmasq::config::firewall {
  assert_private()

  # FIXME: ensure your module's firewall settings are defined here.
  iptables::listen::tcp_stateful { 'allow_spmasq_tcp_connections':
    trusted_nets => $::spmasq::trusted_nets,
    dports       => $::spmasq::tcp_listen_port
  }
}
