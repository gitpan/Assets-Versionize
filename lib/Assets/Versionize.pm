package Assets::Versionize;
{
  $Assets::Versionize::VERSION = '0.1';
}
use Moose;
use namespace::autoclean;
use Assets::Fileinfo qw/regexp_list/;

use File::Find qw/find/;
use File::Copy qw/move/;

has dry_run => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

has verbose => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

has strict => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

has prefix => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has assets => (
    is => 'rw',
    isa => 'Assets::Fileinfo',
    required => 1
);

has extensions => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [qw/php/] }
);

sub process {
    my $self = shift;
    for my $file_dir ( @_ ) {
        if ( -f $file_dir ) {
            $self->processFile($file_dir);
        } elsif ( -d $file_dir ) {
            $self->processDirectory($file_dir);
        }
    }
}

sub processFileToString {
    my ($self, $file) = @_;
    my $changed = 0;
    my $buffer = '';
    my $verbose = $self->verbose || $self->dry_run;
    my $fileinfo = $self->assets->fileinfo;
    my $prefix_re = quotemeta($self->prefix);
    my $filepath_re = qr{(?:[-\w\.]+/)*[-\w\.]+?};
    my $version_re = '(?:\.v[0-9a-f]{6})' . ($self->strict ? '' : '?');
    my $extension_re = regexp_list(@{$self->assets->extensions});

    if ( $verbose ) {
        print STDERR "[INFO] Do with $file...\n";
    }
    open(my $fh, "<", $file) or die "Can't open file $file: $!";
    while ( <$fh> ) {
        my $linenum = $.;
        my $orig = $_;
        my $line_changed = 0;
        s/($prefix_re)($filepath_re)$version_re\.($extension_re)/
            my $file_name = $2 . '.' . $3;
            if ( exists $fileinfo->{$file_name} ) {
                $1. $2 . '.v'.substr($fileinfo->{$file_name}{md5}, 0, 6) . '.' . $3
            } else {
                $&
            }
            /gex;
        if ( $orig ne $_ ) {
            $line_changed = 1;
            $changed = 1;
        }
        if ( $line_changed && $verbose ) {
            print STDERR $file, ':', $linenum, ": \n",
                "     ", $orig,
                "  => ", $_, "\n";
        }
        $buffer .= $_;
    }
    return ($buffer, $changed);
}

sub processFile {
    my ($self, $file) = @_;
    my ($output, $changed) = $self->processFileToString($file);
    if ( $changed && !$self->dry_run ) {
        open(my $fh, ">", $file) or die "Can't create file $file: $!";
        print {$fh} $output;
    }
}

sub processDirectory {
    my ($self, $dir) = @_;
    my $extension_re = regexp_list(@{$self->extensions});
    my $wanted = sub {
        my $file = $File::Find::name;
        if ( -f $file && $file =~ /\.$extension_re$/ ) {
            $self->processFile($file);
        }
    };
    find($wanted, $dir);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Assets::Versionize - Utility to add version to assets file in web page

=head1 VERSION

version 0.1

=head1 SYNOPSIS

  use Assets::Versionize;
  use Assets::Fileinfo;
  my $assets = Assets::Fileinfo->new(directory => $assets_dir);
  my $versionizer = Assets::Versionize->new(fileinfo => $assets);
  $versionizer->process($file_or_directory);

=head1 DESCRIPTION



=cut
