# == Class spmasq::service
#
# This class is meant to be called from spmasq.
# It ensure the service is running.
#
class spmasq::service {
  assert_private()

  service { $::spmasq::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}
