<?php

// 0. Plugin
$config['plugins'][] = 'oauth';$config['plugins'] = [];
// 1. Load the base Docker configuration
include(__DIR__ . '/config.docker.inc.php');


// Gmail OAuth 設定
$config['oauth_provider'] = 'google';
$config['oauth_client_id']     = getenv('ROUNDCUBE_OAUTH_GOOGLE_CLIENT_ID');
$config['oauth_client_secret'] = getenv('ROUNDCUBE_OAUTH_GOOGLE_CLIENT_SECRET');


$config['imap_host'] = [
  'ssl://imap.mail.us-east-1.awsapps.com' => 'Amazon WorkMail',
  'ssl://imap.gmail.com'                  => 'Gmail',
  'ssl://outlook.office365.com'            => 'Outlook',
];

$config['imap_port'] = 993;

// 他の設定
$config['plugins'] = [];
$config['log_driver'] = 'stdout';
$config['zipdownload_selection'] = true;
$config['des_key'] = 'oqiFXlygYIzxciu3oAd0oQ6y';
$config['enable_spellcheck'] = true;
$config['spellcheck_engine'] = 'pspell';


// 削除は即EXPUNGEしない
$config['flag_for_deletion'] = true;

// Trash を使う
$config['trash_mbox'] = 'Trash';

// 削除後に expunge しない
$config['skip_deleted'] = false;
$config['imap_expunge_on_logout'] = false;

// フォルダ自動作成を許可
$config['create_default_folders'] = true;