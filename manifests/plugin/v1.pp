# == Define: serverdensity_agent::plugin::v1
#
# Defines serverdensity_agent legacy (v1) plugins
#
# === Parameters
#
# [*pluginname*]
#   String. The name for the plugin, it will be placed
#   at $plugindir/$pluginname.py
#   Default: $title
#
# [*content*]
#   String. The file content of the plugin
#   Default: undef
#
# [*source*]
#   String. Alternate way of specifying the content with a puppet
#   filebucket URI (puppet:///)
#   Default: undef
#
# [*config*]
#   Hashmap. A single level hash of key value pairs that will be placed
#   under $configdir/$priority-$pluginname.cfg in the [$pluginname] section
#   Default: undef
#
# [*config_priority*]
#   Integer. Text to be pre-pended to the config filename to support ordering
#   Default: '500'
#
# === Examples
#
# serverdensity_agent::plugin::v1{ 'myplugin':
#   source    => 'puppet:///mymodule/myplugin.py',
#   config    => {
#     custom_key1   => 'foo',
#     custom_key2   => 1234,
#   }
# }
#
#
define serverdensity_agent::plugin::v1 (
  $pluginname = $title,
  $content = undef,
  $source = undef,
  $config = undef,
  $config_priority = '500'
  ) {

  include serverdensity_agent

  $configdir = '/etc/sd-agent/plugins.d'

  if $serverdensity_agent::v1_plugin_directory {
    $plugindir = $serverdensity_agent::v1_plugin_directory
  } else {
    $plugindir = '/usr/local/sd-agent-plugins'
  }

  file { "sd_plugin_${title}":
    ensure  => file,
    path    => "${plugindir}/${pluginname}.py",
    source  => $source,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['sd-agent-v1-plugin-dir'],
    notify  => Class['serverdensity_agent::service'],
  }

  if size(keys($config)) > 0 {
    file { "sd_config_${title}":
      ensure  => file,
      path    => "${configdir}/${config_priority}-${pluginname}.cfg",
      content => template('serverdensity_agent/plugin/config.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File[$configdir],
      before  => File["sd_plugin_${title}"],
    }
  }
}
