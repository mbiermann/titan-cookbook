#override default cassandra recipe attributes
override[:cassandra] = {
  :cluster_name => "Test Cluster",
  :initial_token => "",
  :version => '2.0.3',
  :user => "cassandra",
  :jvm  => {
    :xms => 64,
    :xmx => 1024
  },
  :limits => {
    :memlock => 'unlimited',
    :nofile  => 48000
  },
  :installation_dir => "/tmp/cassandra/",
  :bin_dir          => "/tmp/cassandra/bin/",
  :lib_dir          => "/tmp/cassandra/lib/",
  :conf_dir         => "/tmp/cassandra/conf/",
  :data_root_dir    => "/tmp/lib/cassandra/",
  :commitlog_dir    => "/tmp/lib/cassandra/",
  :log_dir          => "/tmp/log/cassandra/",
  :listen_address => node[:network][:interfaces][:eth1][:addresses].find {|addr, addr_info| addr_info[:family] == "inet"}.first, #should match Vagrantfile cassandra host,
  :rpc_address => node[:network][:interfaces][:eth1][:addresses].find {|addr, addr_info| addr_info[:family] == "inet"}.first, #should match Vagrantfile cassandra host,
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :vnodes           => 256,
  :seeds            => ["33.33.33.28"], #host defined in Vagrant file
  :concurrent_reads => 32,
  :concurrent_writes => 32,
  :snitch           => 'SimpleSnitch'
}
override[:cassandra][:tarball] = {
  :url => "http://www.apache.org/dist/cassandra/#{override[:cassandra][:version]}/apache-cassandra-#{override[:cassandra][:version]}-bin.tar.gz",
  :md5 => "98d266fa0b84b50971e87f0c905bf2df"
}

#cassandra works best with oracle jdk 6, let's override default java recipe attributes to install oracle java instead of openjdk
override['java']['install_flavor'] = "oracle"
override['java']['jdk_version'] = '6'
override['java']['oracle']['accept_oracle_download_terms'] = true

#titan attributes
default[:titan] = {
  :user => "cassandra", # shares backend storage with cassandra in embedded mode, so we should probabbly run titan as cassandra
  :storage_backend => "embeddedcassandra",
  :storage_cassandra_config => node[:cassandra][:conf_dir] + "cassandra.yaml",
  :storage_index_backend => "elasticsearch",
  :storage_index_name => "search",
  :storage_index_directory => "/tmp/local/var/data/elasticsearch",
  :storage_index_client_only => "true",
  :storage_index_local_mode => "false",
  :storage_index_hostnames => "33.33.33.29",  #testing: host defined in Vagrantfile for elasticsearch, also make sure network host settings in elastic search yml on the elastic search node is configured correctly in order for titan to connect to it.
  :installation_dir => "/tmp/local/titan/",
  :version => "0.3.1",  
  :properties_file_name => "titan-server-cassandra-es.properties",
  :server_conf_file_name => "titan-server-rexster.xml"
}

#reference: https://github.com/tinkerpop/rexster/wiki/Rexster-Configuration
default[:titan][:rexster] = {
  :http => {
    :server_port => 8182,
    :server_host => '0.0.0.0',
    :base_uri => 'http://localhost',
    :character_set => 'UTF-8',
    :enable_jmx => false,
    :max_post_size => 2097152,
    :max_header_size => 8192,
    :upload_timeout_millis => 30000,
    :thread_pool => {
      :worker => { #upping sizes from default 8/8: https://github.com/tinkerpop/rexster/issues/271
        :core_size => 16,
        :max_size => 32
      },
      :kernal => {
        :core_size => 4,
        :max_size => 4
      }
    }
  },
  :security => {
    :authentication => {
      :type => 'none', #'default' basic auth
      :configuration => { #if type other than 'none' 
        :users => [{:username => 'rexster', #replace
                     :password => 'rexster' #replace
                   }
                  ]                   
      }
    }    
  },
  :shutdown_port => 8183,
  :shutdown_host => '127.0.0.1',
  :script_engines => [
                      #{:name => 'gremlin-groovy', :reset_threshold => -1, :imports => ['com.company.ext_package.*'], :init_scripts => ['scripts/init.groovy'] }
                     ]
  #  TODO add metrics configuration 
}

default[:titan][:ext_pkgs] = [
                              #{:file_name => ext_pkg.jar, :uri => ftp://user:pw@example.com/ext/ext_pkg.jar}
                             ]

default[:titan][:conf_dir] = File.join("#{default[:titan][:installation_dir]}", "config")

default[:titan][:download_url] = "http://s3.thinkaurelius.com/downloads/titan/titan-all-#{default[:titan][:version]}.zip"




