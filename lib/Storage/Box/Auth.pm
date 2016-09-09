# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box::Auth;
use Object::Simple -base;

=pod

=head1 NAME

Storage::Box::Auth -- provides OAuth2 + JWT authentication and key management

=head1 SYNOPSIS

  Storage::Box::Auth::generate_keys("my-super-secret-password");
  ...
  Storate::Box::Auth::enterprise("keyid","enterpriseid")
    or
  Storate::Box::Auth::user("keyid","userid")

=head1 DESCRIPTION

This package manages the OAuth2 + JWT authentication scheme for applications used
by box.com.  It provides utility methods for generating a rsa aes256 2048bit 
public / private key pair.  It also provides authentication for both user and
enterprise account types.

=cut

use Modern::Perl;
use Crypt::JWT;
use Expect;
use Data::UUID;
use WWW::Curl::Easy;
use WWW::Curl::Form;
use JSON qw/ decode_json /;

=pod

=head1 METHODS


=cut

has password => "";                     # password for private key
has private_key => 'private_key.pem';
has public_key => 'public_key.pem';
has key_id => '';                       # id of public key supplied by box.com
has client_id => '';                    # id of the application supplied by box.com
has client_secret => '';                # secret of the application supplied by box.com
has enterprise_id => '';                # id of the enterprise supplied by box.com
has user_id => '';                      # id of the user supplied by box.com
has jwt => '';                          # JSON Web Token generated by user or enterprise
has token => '';                        # OAuth2 token generated by request
has expires => 0;

=pod 

B<generate_private_key()>

  Using openssl, this generates a 2048 bit aes256 private key file

=cut 


sub generate_private_key {
    my $self = shift;
    my $exp = Expect->spawn("openssl genrsa -aes256 -out " . $self->private_key . " 2048") 
        or die "Failed to generate " . $self->private_key;
    $exp->raw_pty(1);
    $exp->expect(1,
        [ qr/private_key\.pem:/ => sub { 
            $exp->send($self->password . "\r"); exp_continue;
        } ]
    );
    $exp->soft_close();
};

=pod

B<generate_public_key()>

  Using openssl, outputs the public key associated with the private_key.pem.
  The password must be the password associated with the private key.

=cut

sub generate_public_key {
    my $self = shift;
    my $exp = Expect->spawn("openssl rsa -pubout -in " . $self->private_key . " -out " . $self->public_key)
        or die "Failed to generate " . $self->public_key;
    $exp->raw_pty(1);
    $exp->expect(1,
        [ qr/private_key\.pem:/ => sub { 
            $exp->send($self->password . "\r"); exp_continue;
        } ]
    );
    $exp->soft_close();
};

=pod

B<generate_keys($password)>

  Using openssl, this generate a public / private keypair with the given password.
  This function also outputs basic instructions for installing the public key at box.com

=cut

sub generate_keys {
    my ($self) = @_;
    $self->generate_private_key;
    $self->generate_public_key;
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

=pod

B<enterprise($self)>

    Creates a JWT assertion for an enterprise account.
    requires the following attributes be set:

    * password = password for the keyfile
    * key_id = key id generated by Box.com
    * private_key = path to the private keyfile
    * client_id = client id of the application creating the assertion
    * enterprise_id = token specific to an enterprise when creating and managing app users

=cut

sub enterprise {
    my $self = shift;
    my $ug = Data::UUID->new;
    my $jti = $ug->to_b64string($ug->create);
    my $time = time;
    my %claims = (
        iss => $self->client_id,
        sub => $self->enterprise_id,
        box_sub_type => "enterprise",
        aud => "https://api.box.com/oauth2/token",
        exp => $time + 60,
        iat => $time,
        jti => $jti
    );
    $self->jwt(Crypt::JWT::encode_jwt( 
        alg => "RS256",
        payload => \%claims,
        key => $self->private_key,
        keypass => $self->password,
        extra_headers =>  { kid => $self->key_id },
    ));
}

=pod

B<user($self)>

    Creates a JWT assertion for a user account.

    * password = password for the keyfile
    * key_id = key id generated by Box.com
    * private_key = path to the private keyfile
    * client_id = client id of the application creating the assertion
    * user_id = app user_id for a token specific to an individual app user.

=cut

sub user {
    my $self = shift;
    my $ug = Data::UUID->new;
    my $jti = $ug->to_b64string($ug->create);
    my $time = time;
    my %claims = (
        iss => $self->client_id,
        sub => $self->user_id,
        box_sub_type => "user",
        aud => "https://api.box.com/oauth2/token",
        exp => $time + 60,
        iat => $time,
        jti => $jti
    );
    $self->jwt(Crypt::JWT::encode_jwt( 
        alg => "RS256",
        payload => \%claims,
        key => $self->private_key,
        keypass => $self->password,
        extra_headers =>  { kid => $self->key_id },
    ));
}

=pod

B<request($client_id,$client_secret,$jwt)>

    Requests an OAuth2 token for the given client, secret, and jwt

=cut

sub request {
    my $self = shift;
    my $body;

    my $form = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&" .
        "assertion=" . $self->jwt . "&" .
        "client_id=" . $self->client_id . "&" .
        "client_secret=" . $self->client_secret;

    my $curl = WWW::Curl::Easy->new;
    $curl->setopt(CURLOPT_URL,"https://api.box.com/oauth2/token");
    $curl->setopt(CURLOPT_POST,1);
    $curl->setopt(CURLOPT_HTTPHEADER, [
        "Content-Type: application/x-www-form-urlencoded"
    ]);
    $curl->setopt(CURLOPT_FILE, \$body );
    $curl->setopt(CURLOPT_POSTFIELDS,$form);
    
    return $self if ($curl->perform || $curl->getinfo(CURLINFO_RESPONSE_CODE) != 200 );
    my $res = decode_json $body;
    $self->expires(time + $res->{expires_in});
    $self->token($res->{access_token});
    $self;
}

sub expired {
    my $self = shift;
    time >= $self->expires;
}

=pod

=head1 TO DO

stuff

=head1 BUGS

lots

=head1 COPYRIGHT

Best Practical LLC.

=head1 AUTHORS

Dave Goehrig <dave@dloh.org>

=cut

1;
