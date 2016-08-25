#!/usr/bin/env perl

use lib 'lib';

use Storage::Box::Auth;
use Storage::Box::User;
use Data::Dumper;

my ($user_id,$enterprise_id,%options) = @ARGV;
$enterprise_id ||= 2064336;

my $jwt = Storage::Box::Auth::enterprise(
	"vmqys6db",
	"keys/private_key.pem",
	"test",
	"96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	"$enterprise_id");

my $res =  Storage::Box::Auth::request(
	"96o6g1e6mot3j1ord2qq6ptvxcsbn4oh",
	"xhp3us3rX3kNLvMt9y3DcGSasqP6Orl3",
	$jwt);

my $token = $res->{access_token};

print Dumper Storage::Box::User::update($token,$user_id,\%options);
