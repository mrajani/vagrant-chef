# -*- mode: ruby -*-
# vi: set ft=ruby :

# Deploy Chef Server 12 and Chef Workstation VM in Virtualbox
# using this Vagrantfile, which reads configurations from
# a yaml file (vagrant.chef.yml) in the current directory.
# Generously modified from PuppetConf14 http://bit.ly/1yhmxdh

require 'yaml'

# Print an error message and stop execution on handled errors
def handle_error(error_msg)
  puts "ERROR: #{error_msg}"
  exit
end

# Check the "nodes" element from vagrant.chef.yml for existence and completeness
def verify_nodes(nodes)
  # Make sure that at least one node is defined
  if !nodes || nodes.empty?
    error_msg = 'No nodes defined in vagrant.yml'
    handle_error(error_msg)
  end

  # TODO: Add per-node checks for completeness
  #       Build up one big error message with all failed checks
end

# Convert the shell provisioner arguments from vagrant.yml
# into an array for the vagrant shell provisioner
def shell_provisioner_args(yaml_arguments)
  shell_arguments = Array.new

  # Arguments may or may not be named,
  # and named arguments may or may not have a value.
  yaml_arguments.each do |argument|
    argument.key?('name') && shell_arguments.push(argument['name'])
    argument.key?('value') && shell_arguments.push(argument['value'])
  end

  shell_arguments
end

# convert all keys in the given hash to symbols
# NOTE: Doesn't work with nested hashes, but I don't need this for those yet
def keys_to_symbols(hash_in)
  hash_out = hash_in.inject({}) do |hash_rekeyed, (key, value)|
    hash_rekeyed[key.to_sym] = value
    hash_rekeyed
  end

  hash_out
end

# Verify that vagrant.chef.yml exists
root_dir = File.dirname(__FILE__)
vagrant_yaml_file = "#{root_dir}/vagrant.chef.yml"
error_msg = "#{vagrant_yaml_file} does not exist"
handle_error(error_msg) unless File.exists?(vagrant_yaml_file)

# Read box and node configs from vagrant.yml
vagrant_yaml = YAML.load_file(vagrant_yaml_file)
error_msg = "#{vagrant_yaml_file} exists, but is empty"
handle_error(error_msg) unless vagrant_yaml
nodes = vagrant_yaml['nodes']

# Verify that node definitions exist and are well-formed
verify_nodes(nodes)

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Define vagrant VMs for each node defined in vagrant.yml
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  nodes.each do |node_name, node_details|
    config.vm.define node_name do |node|

      node.vm.box_check_update = false
      # configure box name and url (if not a vagrant cloud box)
      box_name = "#{node_details['box']}"
      node.vm.box = "#{box_name}"

      # configure basic settings and hostmanager plugin
      node.vm.hostname = node_details['hostname']


      node.vm.provider 'virtualbox' do |vb|
        vb.customize [ 'modifyvm', :id, '--memory', node_details['memory'] ]
        # vb.customize [ 'modifyvm', :id, '--cpus', node_details['cpus'] ]
        vb.name = node_name
      end

      # configure networks
      networks = node_details['networks']
      networks && networks.each do |network|
        network.each do |network_type, network_params|
          if network_params
            network_params = keys_to_symbols(network_params)
            node.vm.network network_type, network_params
          else
            node.vm.network network_type
          end
        end
      end

      # configure synced folders
      synced_folders = node_details['sync_folders']
      synced_folders && synced_folders.each do |host, guest|
        node.vm.synced_folder host, guest
      end

      # configure forwarded ports
      forwarded_ports = node_details['forwarded_ports']
      forwarded_ports && forwarded_ports.each do |forwarded_port|
        forwarded_port = keys_to_symbols(forwarded_port)
        node.vm.network 'forwarded_port', forwarded_port
      end

      # Configure provisioners
      # Each key should correspond to a valid vagrant provisioner.
      # Each value should correspond to a valid setting for that provisioner.
      #   (Except for 'arguments', which is an array of arguments to the shell provisioner script.)
      provisioners = node_details['provisioners']
      provisioners && provisioners.each do |prov_type, prov_array|
        if prov_type == 'shell'
          prov_array.each do |provisioner|
            node.vm.provision "#{prov_type}" do |node_prov|
              provisioner.each do |key, value|
                if key == 'args'
                  node_prov.args = shell_provisioner_args(value)
                else
                  node_prov.send("#{key}=", "#{value}")
                end
              end
            end
          end
        elsif prov_type == 'file'
          prov_array.each do |provisioner|
            node.vm.provision "#{prov_type}" do |node_prov|
              provisioner.each do |key, value|
                node_prov.send("#{key}=", "#{value}")
              end
            end
          end
        end
      end



    end
  end
end
