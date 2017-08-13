# == Class spmasq::install
#
# This class is called from spmasq for install.
#
class spmasq::install {
  assert_private()

  package { $::spmasq::package_name:
    ensure => present
  }
}
