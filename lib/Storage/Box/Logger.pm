package Storage::Box::Logger;

=pod

=head1 NAME

Storage::Box::Logger -- a delegatable logger for Storage::Box

=head1 SYNOPSIS

    my $logger = Log::Dispatch->new([outputs => [ 'Screen', min_level => 'debug' ]]);
    Storage::Box::Logger::logger->delegate($logger);

    or

    $Storage::Box::Logger::debug = 1;

=head1 DESCRIPTION

Storage::Box::Logger provides basic logging for Storage::Box
and allows one to delegate logging to another logging object
such as one created by Log::Dispatch.  By default the logger 
object responds to the typical logging messages:

=over

=item debug

=item info

=item warn

=item error

=item critical

=back

It will print all statuses except debug to STDERR if no 
delegate is supplied.  If a delegate is supplied it will
dispatch all logging to the delegate.

=cut

use Exporter;
@EXPORT = (logger);

our $debug;
our $delegate;
our $logger = Storage::Box::Logger->new;

sub AUTOLOAD {
	my ($sub) = $AUTOLOAD =~ /::([^:]+)$/;
	my $self = shift;
	return $delegate->$sub(@_) if ($delegate && $delegate->can($sub));
	print STDERR $@;
}

sub logger {
    $logger;
}

sub new {
	my $class = shift;
	my $self = @_ ? ( @_ > 1 ? { @_ } : { %$_[0] } ) : {};
	bless $self, ref $class || $class;
}

=pod

=head1 AUTHOR 

Dave Goehrig E<lt>dave@dloh.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2016 Best Practical Solutions, LLC.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

1;

