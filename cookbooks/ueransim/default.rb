package 'build-essential'
package 'libsctp-dev'
package 'lksctp-tools'
package 'iproute2'

directory '/opt/ueransim' do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
end

execute 'git clone ueransim' do
  command 'git clone --recursive -j $(nproc) https://github.com/aligungr/UERANSIM.git /opt/ueransim'
  not_if 'test -e /opt/ueransim/CMakeLists.txt'
  user 'vagrant'
end

execute 'cmake -D CMAKE_BUILD_TYPE=Release -G Ninja -B build .' do
  cwd '/opt/ueransim'
  not_if 'test -e /opt/ueransim/build/CMakeCache.txt'
end

execute 'cmake --build build --target all' do
  cwd '/opt/ueransim'
  not_if 'test -e /opt/ueransim/build/nr-cli'
  not_if 'test -e /opt/ueransim/build/nr-gnb'
  not_if 'test -e /opt/ueransim/build/nr-ue'
end

['nr-cli', 'nr-gnb', 'nr-ue'].each do |bin|
  execute "install /opt/ueransim/build/#{bin} /usr/local/bin/#{bin}" do
    not_if "test -e /usr/local/bin/#{bin}"
  end
end
