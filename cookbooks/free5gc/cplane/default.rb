package 'git'
package 'build-essential'
package 'cmake'
package 'autoconf'
package 'libtool'
package 'pkg-config'
package 'libmnl-dev'
package 'libyaml-dev'

git '/opt/free5gc' do
  repository 'https://github.com/free5gc/free5gc.git'
  revision 'v3.3.0'
  recursive true
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
end

# Required Test Script

package 'psmisc'

link '/bin/go'  do
  to '/usr/local/go/bin/go'
end
