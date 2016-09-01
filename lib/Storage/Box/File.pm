# vim: ai ts=4 sts=4 et sw=4 ft=perl

package Storage::Box::File;
use Object::Simple -base;

=pod

=head1 NAME

Storage::Box::File -- manages Box.com File resources

=head1 SYNOPSIS

  my $file = Storage::Box::File::create($user_token,$name,$parent,$data)
  

=head1 DESCRIPTION

This package allows you to manage Box.com Files.

=cut

use Modern::Perl;
use JSON qw/ encode_json decode_json /;
use Storage::Box::Request;

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
        url => "https://upload.box.com/api/2.0/files/content",
        auth => $self->auth
    );
    $req->field('attributes',"{\"name\":\"" . $self->name . "\",\"parent\":{\"id\":\"" . $self->parent . "\"}}");
    $req->file($self->name);
    $req->post->request;
    return $self unless ($req->code == 201);
    my $json = decode_json($req->body);
    $self->id($json->{entries}[0]->{id});   # update our id
    $self;
}

=pod

B<download($token,$fileid)> 

    Downloads a file

=cut

sub download {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/files/" . $self->id . "/content",
        auth => $self->auth
    );
    $req->get->perform;
    $req->body;
}
 
sub delete {
    my $self = shift;
    my $req = Storage::Box::Request->new(
        url => "https://api.box.com/2.0/files/" . $self->id,
        auth => $self->auth
    );
    $req->delete->perform;
    $req->code == 200 || $req->code == 404;
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