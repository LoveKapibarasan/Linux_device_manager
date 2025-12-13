<?php
// ★ 必須
$config['plugins'] = [];

// ★ これが無いとドロップダウンが出ない
$config['username_domain'] = '';

$config['default_host'] = array(
    'workmail' => 'ssl://imap.mail.us-west-1.awsapps.com',
    'gmail'    => 'ssl://imap.gmail.com',
);


$config['default_port'] = 993;

$config['smtp_server'] = array(
    'workmail' => 'ssl://smtp.mail.us-west-1.awsapps.com',
    'gmail'    => 'ssl://smtp.gmail.com',
);

$config['smtp_port'] = 465;

// ユーザーにサーバ選択を許可
$config['imap_auth_type'] = 'LOGIN';
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

$config['login_autocomplete'] = 2;
$config['default_host'] = array(
    'Amazon WorkMail' => 'ssl://imap.mail.us-west-1.awsapps.com',
    'Gmail'           => 'ssl://imap.gmail.com',
);
