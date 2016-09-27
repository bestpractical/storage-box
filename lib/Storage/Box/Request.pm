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
use Storage::Box::Logger;

has url => '';
has auth => '';
has curl => '';
has body => '';
has form => '';
has max_retries => 5;
has retries => 0;
has code => 200;
has error => '';

our $logger = Storage::Box::Logger::logger;

sub get {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $logger->debug("GET " . $self->url . "\n");
    $self;
}

sub post {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_POST, 1);
    $logger->debug("POST " . $self->url . "\n");
    $self;
}

sub put {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_CUSTOMREQUEST,"PUT");
    $logger->debug("PUT " . $self->url . "\n");
    $self;
}

sub delete {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    $self->curl->setopt(CURLOPT_CUSTOMREQUEST,"DELETE");
    $logger->debug("DELETE " . $self->url . "\n");
    $self;
}

sub request {
    my $self = shift;
    $self->curl( WWW::Curl::Easy->new() ) unless $self->curl;
    my $auth = $self->auth->token();
    $self->warn("No authorization token for request " . $self->url) unless $auth;
    my $headers = [
        "Accept: */*",
        "Authorization: Bearer " . $auth
    ];
    my $body;
    $self->curl->setopt(CURLOPT_FOLLOWLOCATION,1);
    $self->curl->setopt(CURLOPT_HTTPHEADER,$headers);
    $self->curl->setopt(CURLOPT_FILE, \$body );
    $self->curl->setopt(CURLOPT_URL,$self->url);
    $self->curl->setopt(CURLOPT_HTTPPOST,$self->form) if ($self->form ne ''); 
    if ($self->curl->perform) {  # CURLE_OK is 0
        $logger->warn("Curl to " . $self->url . " failed, retrying  " . $self->retries . "\n");
        if ( ++$self->retries < $self->max_retries) {
            sleep 1;
            return $self->request;
        }
        $logger->error("Curl exceeded max tries to " . $self->url . "\n");
        $self->retries(0);
        $self->body('');    # fail with empty body
        return $self;
    }
    $self->code($self->curl->getinfo(CURLINFO_RESPONSE_CODE));
    $logger->info("Request to " . $self->url . " returned status  " . $self->code . "\n");
    $self->body($body);
    $logger->debug("Response: " . substr($self->body,0,1024) .  ( length($self->body) > 1024 ? " (truncated)\n" : "\n"));
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

Copyright (C) 2016 Best Practical Solutions, LLC.

=head1 AUTHORS

Dave Goehrig <dave@dloh.org>

=cut

1;
