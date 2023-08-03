package 'curl'
package 'gnupg'

keyring_url  = 'https://apt.kitware.com/keys/kitware-archive-latest.asc'
keyring_path = '/usr/share/keyrings/kitware-archive-keyring.gpg'

execute "curl -fsSL #{keyring_url} | gpg -o #{keyring_path} --dearmor" do
  not_if "test -e #{keyring_path}"
end

file keyring_path do
  owner 'root'
  group 'root'
  mode '0644'
end

file '/etc/apt/sources.list.d/kitware.list' do
  owner 'root'
  group 'root'
  mode '0644'
  content "deb [signed-by=#{keyring_path}] https://apt.kitware.com/ubuntu focal main"
  notifies :run, 'execute[apt-get update]', :immediately
end

execute 'apt-get update' do
  action :nothing
end

package 'cmake'
package 'ninja-build'
