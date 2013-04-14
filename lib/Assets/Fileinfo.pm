package Assets::Fileinfo;
{
  $Assets::Fileinfo::VERSION = '0.1';
}
use Moose;
use namespace::autoclean;
use File::Find;
use File::Spec;
use Digest::MD5;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw( regexp_list );

our $EXTENSIONS = [qw/js css jpg jpeg png gif ico/];

has directory => (
    is => 'rw',
    isa => 'Str',
);

has extensions => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { $EXTENSIONS },
);

has cache_file => (
    is => 'rw',
    isa => 'Str',
    default => ''
);

has fileinfo => (
    is => 'rw',
    lazy => 1,
    builder => '_build_fileinfo'
);

sub md5sum {
    my $file = shift;
    open(my $fh, "<", $file) or die "Can't open file $file: $!";
    binmode($fh);
    my $ctx = Digest::MD5->new;
    $ctx->addfile($fh);
    return $ctx->hexdigest;
}

sub regexp_list {
    my @list = @_;
    return join('|', @list);
}

sub _build_fileinfo {
    my $self = shift;
    my %fileinfo;
    my $dir = $self->directory;
    my $cached = $self->loadCache;
    my $cache_invalid = 0;
    my $extension_re = regexp_list(@{$self->extensions});
    my $wanted = sub {
        my $file = $File::Find::name;
        if ( -f $file && $file =~ /\.$extension_re$/ ) {
            my $rel_path = File::Spec->abs2rel($file, $dir);
            my $mtime = [stat($file)]->[9];
            if ( exists $cached->{$rel_path} && $mtime == $cached->{$rel_path}{mtime} ) {
                $fileinfo{$rel_path} = $cached->{$rel_path};
            } else {
                $cache_invalid = 1;
                $fileinfo{$rel_path} = {
                    'mtime' => $mtime,
                    'md5' => md5sum($file)
                };
            }
        }
    };
    find($wanted, $dir);
    if ( $cache_invalid ) {
        $self->saveCache(\%fileinfo);
    }
    return \%fileinfo;
}

sub real_cache_file {
    my $self = shift;
    return $self->cache_file && File::Spec->rel2abs($self->cache_file, $self->directory);
}

sub loadCache {
    my $self = shift;
    my %cache;
    my $file = $self->real_cache_file;
    if ( $file && -r $file ) {
        open(my $fh, "<", $file) or die "Can't open file $file: $!";
        while ( <$fh> ) {
            chomp;
            my ($filename, $mtime, $md5) = split /\t/;
            if ( $mtime && $md5 && $mtime =~ /^\d+$/ && $md5 =~ /^[0-9a-f]{32}$/ ) {
                $cache{$filename} = { mtime => $mtime, md5 => $md5 };
            }
        }
    }
    return \%cache;
}

sub saveCache {
    my ($self, $data) = @_;
    my $file = $self->real_cache_file;
    if ( $file ) {
        open(my $fh, ">", $file) or die "Can't create file $file: $!";
        foreach ( keys %$data ) {
            print $fh join("\t", $_, $data->{$_}{mtime}, $data->{$_}{md5}), "\n";
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Assets::Fileinfo - Read assets files in directory and calculate md5

=head1 VERSION

version 0.1

=head1 SYNOPSIS

   use Assets::Fileinfo;
   

=head1 DESCRIPTION

输入：目录
     文件后缀
     缓存

缓存默认放到目录下 .assets-fileinfo 文件中格式：
 文件名 修改时间 md5

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Ye Wenbin, E<lt>wenbinye@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ye Wenbin

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
