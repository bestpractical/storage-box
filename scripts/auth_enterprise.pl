#!/usr/bin/env perl
#

use lib 'lib';

use Storage::Box::Auth;

my $auth = Storage::Box::Auth->new(
	key_id => "vmqys6db",
	enterprise_id => ($ARGV[0] || '2064336'),
	public_key => "keys/public_key.pem",
	private_key => "keys/private_key.pem",
	password => "test",
	client_id => "96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	client_secret => "xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3");

$auth->enterprise->request;
print $auth->token, "\n";
