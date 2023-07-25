kernver = run_command('uname -r').stdout.strip

package 'git'
package 'build-essential'
package "linux-headers-#{kernver}"

git '/opt/gtp5g' do
  repository 'https://github.com/free5gc/gtp5g.git'
  revision 'v0.8.2'
  recursive true
end

execute 'make -j $(nproc)' do
  cwd '/opt/gtp5g'
  not_if 'test -e /opt/gtp5g/gtp5g.ko'
end

execute 'make -j $(nproc) install' do
  cwd '/opt/gtp5g'
  not_if "test -e /lib/modules/#{kernver}/kernel/drivers/net/gtp5g.ko"
end
