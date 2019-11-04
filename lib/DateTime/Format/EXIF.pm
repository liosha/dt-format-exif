use strict;
use warnings;
package DateTime::Format::EXIF;

# ABSTRACT: DateTime parser for EXIF timestamps

=head1 SYNOPSIS

    use Image::ExifTool;
    use DateTime::Format::EXIF;

    my $image_info = Image::ExifTool::ImageInfo("example.jpg");
    my $dt = DateTime::Format::EXIF->parse_datetime($image_info->{DateTimeOriginal});

=head1 DESCRIPTION

DateTime parser for EXIF timestamps

=cut

use DateTime::Format::Builder (
    parsers => {
        parse_datetime => [
            {
                params => [ qw( year month day hour minute second time_zone ) ],
                regex  => qr/   ^
                                (\d\d\d\d):(\d\d):(\d\d) \s
                                (\d\d):(\d\d):(\d\d (?:\.\d{1,9})?)
                                (Z | [\+\-]\d\d:\d\d)?
                                $/xms,
                postprocess => \&_postprocess,
            },
        ],
    },
);


sub _postprocess {
    my %args = @_;
    my ($date, $p) = @args{qw( input parsed )};

    # timezone
    if (!$p->{time_zone}) {
        $p->{time_zone} = 'floating';
    }
    elsif ($p->{time_zone} eq 'Z') {
        $p->{time_zone} = 'UTC';
    }

    # nanoseconds
    my ($s, $fs) = split /(?=\.)/ => $p->{second};
    $p->{second} = $s;
    $p->{nanosecond} = int($fs * 1e9)  if $fs;

    return $date;
}


1;
