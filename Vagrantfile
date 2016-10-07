require 'yaml'
require 'pp'
VAGRANTFILE_API_VERSION = "2"

nodes = YAML.load_file(File.open("vagrant.yml"))['nodes']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box_check_update = false
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  nodes.each do |node, node_details|
    vbname = node['hostname'].split('.')[0]
    config.vm.define vbname do |guest|
      guest.vm.hostname = node['hostname']
      guest.hostmanager.aliases = node['aliases'] if defined?(node['aliases'])
      guest.vm.box = node['box']
      guest.vm.network :private_network, ip: node['ip']
      guest.vm.provider :virtualbox do |vbox|
        vbox.name = "#{node['os']}-" + vbname
        vbox.customize ["modifyvm", :id, "--memory", node['memory']] if node['memory']
      end
      script_folder = "#{node['provisioners']['script_folder']}"
      guest.vm.synced_folder script_folder, "/shared"
      node['provisioners']['shell'] && node['provisioners']['shell'].each do |key, value|
        # name the provision script with key script1,script2,local1
        guest.vm.provision "#{key}", type: "shell" do |sh|
          sh.path = "#{script_folder}#{value}" if (key =~ /^script\d/)
          sh.path = "#{value}" if (key =~ /local/)
          os      = node['os'] if defined?(node['os'])
          release = node['release'] if defined?(node['release'])
          sh.args = [ "#{os}", "#{release}"]
        end
      end
    end
  end
end
