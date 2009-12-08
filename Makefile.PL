use inc::Module::Install;

name 'PicBot';
all_from 'lib/PicBot.pm';

requires 'Robit' => '0.00';
requires 'LWP::UserAgent::POE' => '0.02';

install_script 'picbot';

WriteAll;
