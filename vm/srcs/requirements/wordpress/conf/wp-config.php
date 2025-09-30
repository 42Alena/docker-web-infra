
<?php
/**
 * ________________________________
 !! MY NOTES:   This is copied from the original wp-config-sample.php inside the WordPress container
  Path: /var/www/wordpress/wp-config-sample.php
  Editing wp-config.php https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
__________________________________
 * 
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', getenv('DB_NAME')  ); //cahnged to my  envVariable DB_NAME' from .env


/** Database username */
define( 'DB_USER', getenv('DB_USER') );

/** Database password */
define( 'DB_PASSWORD', getenv('DB_PASSWORD'));

/** Database hostname */
define( 'DB_HOST', getenv('DB_HOST'));

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '~M <#LV$;~XzJUK+dt.+RfkqIvSBgCbb}}{zDux$IiaxL=y^J[&7JCFpdXP|k{9|');
define('SECURE_AUTH_KEY',  'I&pyZa69Ip{P6DMfs?gpo!%R2iX#H9M:HuY}&|MC5kIL&uVP|ol7%Aw_)t%3`Zr#');
define('LOGGED_IN_KEY',    'J0i+x#({ W:l1GZP0I-tN[{#OanY3(v`s.b-|%#E(T;D)O#wrHrVr_@/vr|w8Lm%');
define('NONCE_KEY',        'dF+R2F?-/ 460&Q+~n+VeCP3cS~KuU!AD:t+3^l12J(hD11tOh7Vc%^sr{S7bQ7S');
define('AUTH_SALT',        'mRtKe>2pPeBi(-Xt/Hrn-VT]FF=<nK9RYIuzuCv)^)~|k%Q]2O4WZ7v>~}k`N0[3');
define('SECURE_AUTH_SALT', '.XOjecO>moQ24@-(C_QSfW3!bdqOc[-TDAL+R4#M2=U+biNoyK@ xZSbw|AQa%?@');
define('LOGGED_IN_SALT',   'j!6g%<#,?]S|`bs*G/4Z1^yzcq(g+[L+t6hL >[5&wGbG.R*UWsFb/$PC-ec|{|>');
define('NONCE_SALT',       'hGe`pdXB@OQ+Tgc#P/^:II!1W>^5D&lF*;R<marnZudsO]^k@Q[z7.+m]084yEC-');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
