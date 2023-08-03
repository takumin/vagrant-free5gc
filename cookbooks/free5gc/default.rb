package 'git'
package 'build-essential'
package 'cmake'
package 'autoconf'
package 'libtool'
package 'pkg-config'
package 'libmnl-dev'
package 'libyaml-dev'

directory '/opt/free5gc' do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
end

execute 'git clone free5gc' do
  command 'git clone --recursive -b v3.3.0 -j $(nproc) https://github.com/free5gc/free5gc.git /opt/free5gc'
  not_if 'test -e /opt/free5gc/Makefile'
  user 'vagrant'
end

execute 'env PATH=/usr/local/go/bin:$PATH make -j $(nproc)' do
  cwd '/opt/free5gc'
  not_if 'test -e /opt/free5gc/bin/amf'
  not_if 'test -e /opt/free5gc/bin/ausf'
  not_if 'test -e /opt/free5gc/bin/n3iwf'
  not_if 'test -e /opt/free5gc/bin/nrf'
  not_if 'test -e /opt/free5gc/bin/nssf'
  not_if 'test -e /opt/free5gc/bin/pcf'
  not_if 'test -e /opt/free5gc/bin/smf'
  not_if 'test -e /opt/free5gc/bin/udm'
  not_if 'test -e /opt/free5gc/bin/udr'
  not_if 'test -e /opt/free5gc/bin/upf'
  user 'vagrant'
end

execute 'env PATH=/usr/local/go/bin:$PATH make -j $(nproc) webconsole' do
  cwd '/opt/free5gc'
  not_if 'test -e /opt/free5gc/webconsole/bin/webconsole'
  user 'vagrant'
end

# Network Settings

execute 'sysctl -w net.ipv4.ip_forward=1' do
  only_if 'test $(sysctl -n net.ipv4.ip_forward) = 0'
end

execute 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' do
  action :nothing
  subscribes :run, 'execute[sysctl -w net.ipv4.ip_forward=1]', :immediately
end

execute 'iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400' do
  action :nothing
  subscribes :run, 'execute[sysctl -w net.ipv4.ip_forward=1]', :immediately
end

# Required Test Script

package 'psmisc'

link '/bin/go'  do
  to '/usr/local/go/bin/go'
end

# Testing

testing = false

if testing
  [
    'TestRegistration',
    'TestGUTIRegistration',
    'TestServiceRequest',
    'TestXnHandover',
    'TestN2Handover',
    'TestDeregistration',
    'TestPDUSessionReleaseRequest',
    'TestPaging',
    'TestNon3GPP',
    'TestReSynchronization',
    'TestDuplicateRegistration',
    'TestEAPAKAPrimeAuthentication',
  ].each do |arg|
    execute "./test.sh #{arg}" do
      cwd '/opt/free5gc'
      user 'vagrant'

      action :nothing
      subscribes :run, 'execute[git clone free5gc]'
    end
  end
end
