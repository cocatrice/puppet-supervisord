# Class: supervisord::pip
#
# Optional class to install setuptool and pip
#
class supervisord::pip inherits supervisord {

  Exec {
    path => '/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  if ! defined(Package['curl']) {
    ensure_packages('curl')
  }

  exec { 'install_setuptools':
    command => "curl ${supervisord::setuptools_url} | python",
    cwd     => '/tmp',
    unless  => 'which easy_install',
    before  => Exec['install_pip'],
    require => Package['curl'],
  }

  exec { 'install_pip':
    command => 'easy_install pip',
    unless  => 'which pip',
  }

  # See https://github.com/pypa/setuptools/issues/581
  exec { 'reinstall_setuptools':
    command => 'pip install --upgrade setuptools',
    onlyif  => 'pip list | grep "setuptools 33.1.1" || ! pip list | grep "setuptools"',
    require => Exec['install_pip'],
  }

  if $::osfamily == 'RedHat' {
    exec { 'pip_provider_name_fix':
      command   => 'alternatives --install /usr/bin/pip-python pip-python /usr/bin/pip 1',
      subscribe => Exec['install_pip'],
      unless    => 'which pip-python',
    }
  }

}
