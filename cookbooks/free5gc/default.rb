NETWORK_FUNCTIONS = [
  :amf,
  :ausf,
  :n3iwf,
  :nrf,
  :nssf,
  :pcf,
  :smf,
  :udm,
  :udr,
  :upf,
]

node.reverse_merge!({
  free5gc: {
    version:    'v3.3.0',
    amf:        true,
    ausf:       true,
    n3iwf:      true,
    nrf:        true,
    nssf:       true,
    pcf:        true,
    smf:        true,
    udm:        true,
    udr:        true,
    upf:        true,
    webconsole: false,
    test:       false,
  },
})

node.validate! do
  {
    free5gc: {
      version:    string,
      amf:        optional(boolean),
      ausf:       optional(boolean),
      n3iwf:      optional(boolean),
      nrf:        optional(boolean),
      nssf:       optional(boolean),
      pcf:        optional(boolean),
      smf:        optional(boolean),
      udm:        optional(boolean),
      udr:        optional(boolean),
      upf:        optional(boolean),
      webconsole: optional(boolean),
      test:       optional(boolean),
    }
  }
end

package 'git'
package 'build-essential'
package 'cmake'
package 'autoconf'
package 'libtool'
package 'pkg-config'
package 'libmnl-dev'
package 'libyaml-dev'

# required test scripts
package 'psmisc'

directory '/opt/free5gc' do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
end

execute 'git clone free5gc' do
  command "git clone --recursive -b #{node.free5gc.version} -j $(nproc) https://github.com/free5gc/free5gc.git /opt/free5gc"
  not_if 'test -e /opt/free5gc/Makefile'
  user 'vagrant'
end

node.free5gc.keys.select{|nf|NETWORK_FUNCTIONS.include?(nf.to_sym)}.each do |nf|
  execute "env PATH=/usr/local/go/bin:$PATH make -j $(nproc) #{nf}" do
    cwd '/opt/free5gc'
    not_if "test -e /opt/free5gc/bin/#{nf}"
    user 'vagrant'
  end
end

if node.free5gc.webconsole
  execute 'env PATH=/usr/local/go/bin:$PATH make -j $(nproc) webconsole' do
    cwd '/opt/free5gc'
    not_if 'test -e /opt/free5gc/webconsole/bin/webconsole'
    user 'vagrant'
  end
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

# Testing

if node.free5gc.test
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
