class phantomjs($version = "1.8.1" ) {

    $packages = ["fontconfig"]

    package { $packages: ensure => installed}

    if $::architecture == "amd64" or $::architecture == "x86_64" {
        $platid = "x86_64"
    } else {
        $platid = "i686"
    }

    $filename = "phantomjs-${version}-linux-${platid}.tar.bz2"
    $filename_unpacked = "phantomjs-${version}-linux-${platid}.tar"
    $phantom_src_path = "/usr/local/src/phantomjs-${version}/"
    $phantom_bin_path = "/opt/phantomjs-${version}-linux-${platid}/"

    file { $phantom_src_path : ensure => directory }

    exec { "download-${filename}" : 
        command => "/usr/bin/wget http://phantomjs.googlecode.com/files/${filename} -O ${filename}",
        cwd => $phantom_src_path,
        creates => "${phantom_src_path}${filename}",
        require => File[$phantom_src_path]
    }
    
    exec { "extract-${filename}" :
        command     => "/bin/bunzip2 ${filename_unpacked}; /bin/tar xvf ${filename} -C /opt/",
        creates     => "/opt/phantomjs-${version}-linux-${platid}/",
        cwd         => $phantom_src_path,
        require     => Exec["download-${filename}"],
    }

    file { "/usr/local/bin/phantomjs" :
        target => "${phantom_bin_path}/bin/phantomjs",
        ensure => link,
        require     => Exec["extract-${filename}"],
    }
    
    file { "/usr/bin/phantomjs" :
        target => "${phantom_bin_path}/bin/phantomjs",
        ensure => link,
        require     => Exec["extract-${filename}"],
    }
    
    exec { "nuke-old-version-on-upgrade" :
        command => "/bin/rm -Rf /opt/phantomjs /usr/local/bin/phantomjs",
        unless => "/usr/bin/test -f /usr/local/bin/phantomjs && /usr/local/bin/phantomjs --version | grep ${version}",
        before => Exec["download-${filename}"]
    }

}
