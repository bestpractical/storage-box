# vim: ai ts=4 sts=4 et sw=4 ft=perl
#
package Storage::Box::Request;

=pod

=head1 NAME

Storage::Box::Request

=head1 SYNOPSIS

	my $request = Storage::Box::Request->new(
        url => "https://api.box.com",
        auth => $auth
    );

=head1 DESCRIPTION

=cut

use Object::Simple -base;
use Modern::Perl;
use JSON qw/ encode_json decode_json /;
use WWW::Curl::Easy;
use WWW::Curl::Form;

has url => '';
has auth => '';
has curl => '';
has body => '';
has form => '';
has max_retries => 5;
has retries => 0;
has code => 200;

sub get {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self;
}

sub post {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_POST, 1);
    $self;
}

sub put {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_CUSTOMREQUEST,"PUT");
    $self;
}

sub delete {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_CUSTOMREQUEST,"DELETE");
    $self;
}

sub request {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    my $headers = [
        "Accept: */*",
        "Authorization: Bearer " . $self->auth->token()
    ];
    my $body;
    $self->curl->setopt(CURLOPT_FOLLOWLOCATION,1);
    $self->curl->setopt(CURLOPT_HTTPHEADER,$headers);
    $self->curl->setopt(CURLOPT_FILE, \$body );
    $self->curl->setopt(CURLOPT_URL,$self->url);
    $self->curl->setopt(CURLOPT_HTTPPOST,$self->form) if ($self->form ne ''); 
    if ($self->curl->perform) {  # CURLE_OK is 0
        if ( ++$self->retries < $self->max_retries) {
            sleep 1;
            return $self->request;
        }
        $self->retries(0);
        $self->body('');    # fail with empty body
        return $self;
    }
    $self->code($self->curl->getinfo(CURLINFO_RESPONSE_CODE));
    $self->body($body);
    $self;
}

sub field {
    my $self = shift;
    my ($key,$value) = @_;
    $self->form( WWW::Curl::Form->new() ) unless $self->form;
    $self->form->formadd($key,$value);
    $self;
}

sub file {
    my $self = shift;
    my $filename = shift;
    $self->form( WWW::Curl::Form->new() ) unless $self->form;
    $self->form->formadd('attributes',"{\"name\":\"" . $self->name . "\",\"parent\":{\"id\":\"" . $self->parent . "\"}}");
    $self->form->formaddfile($filename, 'attachment', "multipart/form-data");
    $self;
}

sub content {
    my $self = shift;
    my $data = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_POSTFIELDS, $data );
    $self;
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
