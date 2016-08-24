package Storage::Box::Auth;

use Modern::Perl;
use Crypt::JWT;
use Expect;

sub generate_private_key {
	my ($password) = @_;
	my $exp = Expect->spawn("openssl genrsa -aes256 -out private_key.pem 2048") 
		or die "Failed to generate private_key.pem";
	$exp->raw_pty(1);
	$exp->expect(1,
		[ qr/private_key\.pem:/ => sub { 
			$exp->send("$password\r"); exp_continue;
		} ]
	);
	$exp->soft_close();
}

sub generate_public_key {
	my ($password) = @_;
	my $exp = Expect->spawn("openssl rsa -pubout -in private_key.pem -out public_key.pem")
		or die "Failed to generate public_key.pem";
	$exp->raw_pty(1);
	$exp->expect(1,
		[ qr/private_key\.pem:/ => sub { 
			$exp->send("$password\r"); exp_continue;
		} ]
	);
	$exp->soft_close();
}

sub generate_keys {
	my ($password) = @_;
	generate_private_key $password;
	generate_public_key $password;
	print <<THERE;

To install this key in box.com:

1) Go to Edit Application and select your Box Platform application.

2) Scroll down to the Public Key Management section.

3) Select Add Public Key as shown below.

THERE

	do {
		local $/ = undef; 
		open my $fh, "< public_key.pem";
		print <$fh>;
	}	
}
1;
