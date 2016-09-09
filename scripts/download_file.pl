#!/usr/bin/env perl
#
use lib 'lib';
use Data::Dumper;
use Storage::Box::File;
use Storage::Box::Auth;

my ($user_id,$file_id) = @ARGV;

my $auth = Storage::Box::Auth->new(
	key_id => "vmqys6db",
	user_id => $user_id,
	public_key => "keys/public_key.pem",
	private_key => "keys/private_key.pem",
	password => "test",
	client_id => "96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	client_secret => "xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3");

$auth->user->request;

my $file = Storage::Box::File->new(
	auth => $auth,
	id => $file_id
);

open my $fh, "> $file_id" or die "couldnt write to file $!\n";
print $fh $file->download;
close $fh;

