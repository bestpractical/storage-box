# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box::Folder;

=pod

=head1 NAME

Storage::Box::Folder -- manages Box.com Folder resources

=head1 SYNOPSIS

	my $file = Storage::Box::Folder->new(

	)
  

=head1 DESCRIPTION

This package allows you to manage Box.com Files.

=cut

use Object::Simple -base;
use Modern::Perl;
use Storage::Box::Request;
use JSON qw/ encode_json decode_json /;
use Data::Dumper;

=pod

=head1 METHODS

=cut

has id => '0';          # id of the file, supplied by box.com
has name => '';         # name of the file
has parent => '0';      # id of the parent folder, 0 is top level default
has auth => '';         # Storage::Box::Auth object

=pod
B<create($user_token,$name,$parent,$filename)>

  Creates a new File with the given name in the specified parent Folder.

=cut 

sub create {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/folders",
        auth => $self->auth
    );
    $req->content("{\"name\":\"" . $self->name . "\",\"parent\":{\"id\":\"" . $self->parent . "\"}}");
    $req->post->request;
    my $json = decode_json  $req->body;
    $self->id($json->{id});
}


sub items {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/folders/" . $self->id . "/items",
        auth => $self->auth
    );
    $req->get->request;
    decode_json $req->body;
}

=pod

B<delete()> 

    Delete the folder

=cut
sub delete {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/folders/" . $self->id,
        auth => $self->auth
    );
    $req->delete->request;
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
