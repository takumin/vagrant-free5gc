version = '1.17.13'

sha256sum = Hashie::Mash.new
sha256sum['amd64'] = '4cdd2bc664724dc7db94ad51b503512c5ae7220951cac568120f64f8e94399fc'
sha256sum['arm64'] = '914daad3f011cc2014dea799bb7490442677e4ad6de0b2ac3ded6cee7e3f493d'

case node[:kernel][:machine]
when 'x86_64'
  arch = 'amd64'
when 'aarch64'
  arch = 'arm64'
else
  raise
end

download_archive_url  = "https://dl.google.com/go/go#{version}.linux-#{arch}.tar.gz"
download_archive_name = File.basename(download_archive_url)
download_archive_path = File.join('/tmp', download_archive_name)

if File.exist?('/usr/local/go/bin/go') then
  check_version = run_command('/usr/local/go/bin/go version', error: false)

  if check_version.success? then
    installed_version = check_version.stdout.lines[0].gsub(/^go version go([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1').chomp

    if installed_version != version then
      directory '/usr/local/go' do
        action :delete
      end
    end
  end
end

package 'curl'

http_request download_archive_path do
  url download_archive_url
  not_if [
    'test -d /usr/local/go',
    "echo #{sha256sum[arch]} #{download_archive_path} | sha256sum -c --ignore-missing --status",
  ].join(' || ')
end

execute "tar -xvf #{download_archive_path}" do
  cwd '/usr/local'
  not_if 'test -d /usr/local/go'
end

file download_archive_path do
  action :delete
  only_if 'test -d /usr/local/go'
end

remote_file '/etc/profile.d/go-path.sh' do
  owner 'root'
  group 'root'
  mode  '0644'
end

unless ENV['PATH'].include?('/usr/local/go/bin') then
  ENV['PATH'] << ':/usr/local/go/bin'
end

file '/etc/sudoers' do
  action :edit
  block do |content|
    unless content.match?(/secure_path=\"\/usr\/local\/go\/bin/)
      content.gsub!(/secure_path=\"(.*)\"/){"secure_path=\"/usr/local/go/bin:#{$1}\""}
    end
  end
end

# required free5gc test scripts
link '/bin/go'  do
  to '/usr/local/go/bin/go'
end
