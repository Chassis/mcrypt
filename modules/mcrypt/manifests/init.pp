# A Chassis extensions to add mcrypt to your Chassis server
class mcrypt (
	$config,
	$path = '/vagrant/extensions/mcrypt'
) {
	if ( ! empty( $::config[disabled_extensions] ) and 'chassis/mcrypt' in $config[disabled_extensions] ) {
		$package = absent
	} else {
		$package = latest
	}

	$php = $config[php]

	if versioncmp( $php, '5.4') <= 0 {
		$php_package = 'php5'
	}
	else {
		$php_package = "php${$php}"
	}

	package { "${$php_package}-mcrypt":
		ensure  => $package,
		require => Package["${$php_package}-fpm"],
		notify  => Service["${$php_package}-fpm"]
	}
}
