#!/usr/bin/env perl

use lib 'lib';

use Storage::Box::Auth;
use Storage::Box::User;
use Data::Dumper;

my ($user_id,$enterprise_id,%options) = @ARGV;
$enterprise_id ||= '2064336';

my $auth = Storage::Box::Auth->new(
	key_id => "vmqys6db",
	enterprise_id => $enterprise_id,
	public_key => "keys/public_key.pem",
	private_key => "keys/private_key.pem",
	password => "test",
	client_id => "96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	client_secret => "xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3");

$auth->enterprise->request;

my $user = Storage::Box::User->new(
	auth => $auth,
	id => $user_id
);

print Dumper $user->update(%options);
