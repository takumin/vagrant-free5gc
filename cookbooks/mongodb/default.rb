package 'curl'
package 'gnupg'

keyring_url  = 'https://pgp.mongodb.com/server-6.0.asc'
keyring_path = '/usr/share/keyrings/mongodb-server-6.0.gpg'

execute "curl -fsSL #{keyring_url} | gpg -o #{keyring_path} --dearmor" do
  not_if "test -e #{keyring_path}"
end

file keyring_path do
  owner 'root'
  group 'root'
  mode '0644'
end

file '/etc/apt/sources.list.d/mongodb-org-6.0.list' do
  owner 'root'
  group 'root'
  mode '0644'
  content 'deb [signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main'
  notifies :run, 'execute[apt-get update]', :immediately
end

execute 'apt-get update' do
  action :nothing
end

package 'mongodb-org'

service 'mongod.service' do
  action [:enable, :start]
end
