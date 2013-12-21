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
  :installation_dir => "/usr/local/cassandra/",
  :bin_dir          => "/usr/local/cassandra/bin/",
  :lib_dir          => "/usr/local/cassandra/lib/",
  :conf_dir         => "/usr/local/cassandra/conf/",
  :data_root_dir    => "/usr/local/cassandra/data/",
  :commitlog_dir    => "/usr/local/cassandra/commit/",
  :log_dir          => "/usr/local/cassandra/log/",
  :listen_address   => node[:ipaddress],
  :rpc_address      => node[:ipaddress],
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :vnodes           => 256,
  :seeds            => [node[:ipaddress]], #host defined in Vagrant file
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
  :installation_dir => "/usr/local/titan/",
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




