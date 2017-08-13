require 'spec_helper'

describe 'spmasq' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('spmasq') }
    it { is_expected.to contain_class('spmasq') }
    it { is_expected.to contain_class('spmasq::install').that_comes_before('Class[spmasq::config]') }
    it { is_expected.to contain_class('spmasq::config') }
    it { is_expected.to contain_class('spmasq::service').that_subscribes_to('Class[spmasq::config]') }

    it { is_expected.to contain_service('spmasq') }
    it { is_expected.to contain_package('spmasq').with_ensure('present') }
  end


  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "spmasq class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it { is_expected.to contain_class('spmasq').with_trusted_nets(['127.0.0.1/32']) }
        end

        context "spmasq class with firewall enabled" do
          let(:params) {{
            :trusted_nets     => ['10.0.2.0/24'],
            :tcp_listen_port => 1234,
            :enable_firewall => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('spmasq::config::firewall') }

          it { is_expected.to contain_class('spmasq::config::firewall').that_comes_before('Class[spmasq::service]') }
          it { is_expected.to create_iptables__listen__tcp_stateful('allow_spmasq_tcp_connections').with_dports(1234)
          }
        end

        context "spmasq class with selinux enabled" do
          let(:params) {{
            :enable_selinux => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('spmasq::config::selinux') }
          it { is_expected.to contain_class('spmasq::config::selinux').that_comes_before('Class[spmasq::service]') }
          it { is_expected.to create_notify('FIXME: selinux') }
        end

        context "spmasq class with auditing enabled" do
          let(:params) {{
            :enable_auditing => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('spmasq::config::auditing') }
          it { is_expected.to contain_class('spmasq::config::auditing').that_comes_before('Class[spmasq::service]') }
          it { is_expected.to create_notify('FIXME: auditing') }
        end

        context "spmasq class with logging enabled" do
          let(:params) {{
            :enable_logging => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('spmasq::config::logging') }
          it { is_expected.to contain_class('spmasq::config::logging').that_comes_before('Class[spmasq::service]') }
          it { is_expected.to create_notify('FIXME: logging') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'spmasq class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('spmasq') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
