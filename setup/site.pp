class common_config {

  user { 'demo':
    ensure     => 'present',
    comment    => 'Demo User',
    home       => '/home/demo',
    managehome => true,
    shell => "/bin/bash",
    password   => pw_hash('tinytitan93', 'SHA-512', 'mysalt'),
    groups     => ['demo', 'adm', 'cdrom', 'sudo', 'audio', 'dip', 'video', 'plugdev', 'render', 'i2c', 'lpadmin', 'gdm', 'sambashare', 'weston-launch', 'gpio'],
  }

  package { ['git', 'build-essential', 'libopenmpi-dev', 'libgl1-mesa-dev', 'python3', 'python3-pip', 'python3-dev']:
    ensure => 'installed',
  }
}

node 'demo00', 'demo00.charlotte.edu', 'demo00.uncc.edu' {
  include common_config
}

node 'demo01', 'demo01.charlotte.edu', 'demo01.uncc.edu' {

  include common_config
}

node 'demo02', 'demo02.charlotte.edu', 'demo02.uncc.edu' {
  include common_config
}

node 'demo03', 'demo03.charlotte.edu', 'demo03.uncc.edu' {
  include common_config
}

node 'demo04', 'demo04.charlotte.edu', 'demo04.uncc.edu' {
  include common_config
}

node 'demo05', 'demo05.charlotte.edu', 'demo05.uncc.edu' {
  include common_config
}

node 'demo06', 'demo06.charlotte.edu', 'demo06.uncc.edu' {
  include common_config
}

node 'demo07', 'demo07.charlotte.edu', 'demo07.uncc.edu' {
  include common_config
}

node 'demo08', 'demo08.charlotte.edu', 'demo08.uncc.edu' {
  include common_config
}

