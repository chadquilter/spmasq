require 'spec_helper'

describe 'sqmasq', :type => 'class' do
  let(:title) {'sqmasq'}
  it { should contain_concat('dnsmasq.conf').that_requires('Package[dnsmasq]') }
  it { should contain_concat__fragment('dnsmasq-header').with({
    :name    => 'dnsmasq-header',
    :order   => '00',
    :target  => 'dnsmasq.conf',
    :content => /^# MAIN CONFIG START\ndomain-needed\nbogus-priv/,
  }) }
  it { should contain_package('dnsmasq').that_comes_before('Service[dnsmasq]') }
  it { should contain_service('dnsmasq') }

end
