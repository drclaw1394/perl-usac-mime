package uSAC::MIME;
use strict;
use warnings;
use version; our $VERSION=version->declare("v0.1");

use feature "say";

=head1 NAME

uSAC::MIME

=head1 ABSTRACT

uSAC::MIME - MIME database with consise forward and backward file extension to mime type lookups

=head1 SYNOPSIS

	use uSAC::MIME;

	#Create a new DB and index
	my $db=uSAC::MIME->new(addtional_ext=>"mime/type");
	my ($forward, $backward)=$db->index;

	#Do Lookups
	$forward->{txt};		
	$backward->{"text/plain"};	

	#Manipulate the DB
	$db->add_ext_to_mime("foo"=>"mime/bar");
	$db->remove_ext_to_mime("txt"=>"text/plain");
	($forward,$backward)=$db->index;

=head1 DESCRIPTION

Small, simple and direct file extension to mime type (forward) mapping and MIME type to file extension set (backwards) mapping.

Creates a unique version of an internal mime database for your program to manipulate as you wish

=cut

my $mime_to_extension ={
	"text/html"=>"html htm shtml",
	"text/css"=>"css",
	"text/xml"=>"xml",
	"image/gif"=>"gif",
	"image/jpeg"=>"jpeg jpg",
	"application/javascript"=>"js",
	"application/atom+xml"=>"atom",
	"application/rss+xml"=>"rss",

	"text/mathml"=>"mml",
	"text/plain"=>"txt",
	"text/vnd.sun.j2me.app-descriptor"=>"jad",
	"text/vnd.wap.wml"=>"wml",
	"text/x-component"=>"htc",

	"image/png"=>"png",
	"image/svg+xml"=>"svg svgz",
	"image/tiff"=>"tif tiff",
	"image/vnd.wap.wbmp"=>"wbmp",
	"image/webp"=>"webp",
	"image/x-icon"=>"ico",
	"image/x-jng"=>"jng",
	"image/x-ms-bmp"=>"bmp",

	"font/woff"=>"woff",
	"font/woff2"=>"woff2",

	"application/java-archive"=>"jar war ear",
	"application/json"=>"json",
	"application/mac-binhex40"=>"hqx",
	"application/msword"=>"doc",
	"application/pdf"=>"pdf",
	"application/postscript"=>"ps eps ai",
	"application/rtf"=>"rtf",
	"application/vnd.apple.mpegurl"=>"m3u8",
	"application/vnd.google-earth.kml+xml"=>"kml",
	"application/vnd.google-earth.kmz"=>"kmz",
	"application/vnd.ms-excel"=>"xls",
	"application/vnd.ms-fontobject"=>"eot",
	"application/vnd.ms-powerpoint"=>"ppt",
	"application/vnd.oasis.opendocument.graphics"=>"odg",
	"application/vnd.oasis.opendocument.presentation"=>"odp",
	"application/vnd.oasis.opendocument.spreadsheet"=>"ods",
	"application/vnd.oasis.opendocument.text"=>"odt",

	"application/vnd.wap.wmlc"=>"wmlc",
	"application/x-7z-compressed"=>"7z",
	"application/x-cocoa"=>"cco",
	"application/x-java-archive-diff"=>"jardiff",
	"application/x-java-jnlp-file"=>"jnlp",
	"application/x-makeself"=>"run",
	"application/x-perl"=>"pl pm",
	"application/x-pilot"=>"prc pdb",
	"application/x-rar-compressed"=>"rar",
	"application/x-redhat-package-manager"=>"rpm",
	"application/x-sea"=>"sea",
	"application/x-shockwave-flash"=>"swf",
	"application/x-stuffit"=>"sit",
	"application/x-tcl"=>"tcl tk",
	"application/x-x509-ca-cert"=>"der pem crt",
	"application/x-xpinstall"=>"xpi",
	"application/xhtml+xml"=>"xhtml",
	"application/xspf+xml"=>"xspf",
	"application/zip"=>"zip",

	"application/octet-stream"=>"bin exe dll",
	"application/octet-stream"=>"deb",
	"application/octet-stream"=>"dmg",
	"application/octet-stream"=>"iso img",
	"application/octet-stream"=>"msi msp msm",

	"audio/midi"=>"mid midi kar",
	"audio/mpeg"=>"mp3",
	"audio/ogg"=>"ogg",
	"audio/x-m4a"=>"m4a",
	"audio/x-realaudio"=>"ra",

	"video/3gpp"=>"3gpp 3gp",
	"video/mp2t"=>"ts",
	"video/mp4"=>"mp4",
	"video/mpeg"=>"mpeg mpg",
	"video/quicktime"=>"mov",
	"video/webm"=>"webm",
	"video/x-flv"=>"flv",
	"video/x-m4v"=>"m4v",
	"video/x-mng"=>"mng",
	"video/x-ms-asf"=>"asx asf",
	"video/x-ms-wmv"=>"wmv",
	"video/x-msvideo"=>"avi",
};


=head1 METHODS

=over 

=item C<new(%mappings_to_add)>

Creates a new mime database from the internal database. Adds the optional mappings to it
The C<index> method needs to be called on the returned object to perform lookups

=back

=cut

sub new {
	my $package=shift//__PACKAGE__;
	my %additional=@_;
	my $self={$mime_to_extension->%*};
	bless $self, $package;
	for(keys %additional){
		$self->add_ext_to_mime($_, $additional{$_});
	}
	$self;
}

=over 

=item C<new_empty(%mappings_to_add)>

Creates a new empty database. Adds the optional mappings to it
The C<index> method needs to be called on the returned object to perform lookups

=back

=cut

sub new_empty {
	my $package=shift//__PACKAGE__;
	my %additional=@_;
	my $self={};
	bless $self, $package;
	for(keys %additional){
		$self->add_ext_to_mime($_, $additional{$_});
	}
	$self;
}

sub new_from_file {
	#ignore any line with only one word, or   { or }
	my $package=shift//__PACKAGE__;
	my $path=shift;
	my $self={};
	bless $self, $package;


	my $res=open my $fh, "<", $path;
	unless($res){
		warn "could not process file";
		return $self;
	}
	else {
		for(<$fh>){
			tr/;//d;
			s/^\s+//;
			next if /^\s*#/;
			next if /^\s*$/;
			next if /{|}/;

			my @fields=split /\s+/;
			#first field is the mime type, remaining are extensions
			for my $ext (@fields[1..$#fields]){
				$self->add_ext_to_mime($ext=>$fields[0]);
			}
		}
	}
	$self;
	
}

sub write_to_file {
	my $self=shift;
	my $path=shift;
	my $res=open my $fh, ">", $path;
	unless($res){
		warn "could not open file";
		return;
	}
	else{
		my @keys= sort keys $self->%*;
		my $output="";
		for(@keys){
			$output.= "$_ ".$self->{$_}."\n";
		}
		print $fh $output;
	}
	return 1;

}

=over

=item C<index>

Generates the hash tables for forward (extension to mime) mappings, and backwards(mime to extension set) mapping.

	my ($forward,$backward)=$db->index;
	$forward->{"txt");

=back

=cut


sub index{
	my $db=shift;
	my @tmp;
	my @tmp2;
	for my $mime (keys $db->%*){
		for($db->{$mime}){
			my $exts=[split " "];
			push @tmp, map {$_,$mime} $exts->@*;
			push @tmp2, $mime, $exts

		}
	}
	#first hash is forward map from extention to mime type
	#second hash is reverse map from mime to to array or extension
	({@tmp},{@tmp2});
}

=over

=item  C<add_ext_to_mime>

Adds a single mapping from file extension to mime type. the  C<index> method will need to be called after adding to make changes in the lookup hashes

=back

=cut

#add an ext=>mime mapping. need to reindex after
#returns
sub add_ext_to_mime {
	my ($db,$ext,$mime)=@_;
	my $exts_string=$db->{$mime}//"";
	unless($exts_string=~/\b$ext\b/){
		my @items=split " ", $exts_string;
		push @items, $ext;
		$db->{$mime}=join " ", @items;
	}
	$db;
}

=over

=item  C<add_ext_to_mime>

Removes aa single mapping from file extension to mime type. the  C<index> method will need to be called after adding to make changes in the lookup hashes

=back

=cut

sub remove_ext_to_mime {
	my ($db,$ext,$mime)=@_;
	my $exts_string=$db->{$mime};
	return unless defined $exts_string;
	if($exts_string=~s/\b$ext\b//){
		$exts_string=~s/ +/ /;
		if($exts_string eq " "){
			delete $db->{mime};
		}
		else {
			$db->{$mime}=$exts_string;
		}
	}
	$db
}

1;

__END__
=head1 AUTHOR

Ruben Westerberg 

=head1 COPYRIGHT

Ruben Westerberg

=head1 LICENSE

MIT or Perl, whichever you choose.

=cut

__DATA__
text/html                                        html htm shtml
text/css                                         css
text/xml                                         xml
image/gif                                        gif
image/jpeg                                       jpeg jpg
application/javascript                           js
application/atom+xml                             atom
application/rss+xml                              rss

text/mathml                                      mml
text/plain                                       txt
text/vnd.sun.j2me.app-descriptor                 jad
text/vnd.wap.wml                                 wml
text/x-component                                 htc

image/png                                        png
image/svg+xml                                    svg svgz
image/tiff                                       tif tiff
image/vnd.wap.wbmp                               wbmp
image/webp                                       webp
image/x-icon                                     ico
image/x-jng                                      jng
image/x-ms-bmp                                   bmp

font/woff                                        woff
font/woff2                                       woff2

application/java-archive                         jar war ear
application/json                                 json
application/mac-binhex40                         hqx
application/msword                               doc
application/pdf                                  pdf
application/postscript                           ps eps ai
application/rtf                                  rtf
application/vnd.apple.mpegurl                    m3u8
application/vnd.google-earth.kml+xml             kml
application/vnd.google-earth.kmz                 kmz
application/vnd.ms-excel                         xls
application/vnd.ms-fontobject                    eot
application/vnd.ms-powerpoint                    ppt
application/vnd.oasis.opendocument.graphics      odg
application/vnd.oasis.opendocument.presentation  odp
application/vnd.oasis.opendocument.spreadsheet   ods
application/vnd.oasis.opendocument.text          odt
application/vnd.openxmlformats-officedocument.presentationml.presentation
pptx
application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
xlsx
application/vnd.openxmlformats-officedocument.wordprocessingml.document
docx
application/vnd.wap.wmlc                         wmlc
application/x-7z-compressed                      7z
application/x-cocoa                              cco
application/x-java-archive-diff                  jardiff
application/x-java-jnlp-file                     jnlp
application/x-makeself                           run
application/x-perl                               pl pm
application/x-pilot                              prc pdb
application/x-rar-compressed                     rar
application/x-redhat-package-manager             rpm
application/x-sea                                sea
application/x-shockwave-flash                    swf
application/x-stuffit                            sit
application/x-tcl                                tcl tk
application/x-x509-ca-cert                       der pem crt
application/x-xpinstall                          xpi
application/xhtml+xml                            xhtml
application/xspf+xml                             xspf
application/zip                                  zip

application/octet-stream                         bin exe dll
application/octet-stream                         deb
application/octet-stream                         dmg
application/octet-stream                         iso img
application/octet-stream                         msi msp msm

audio/midi                                       mid midi kar
audio/mpeg                                       mp3
audio/ogg                                        ogg
audio/x-m4a                                      m4a
audio/x-realaudio                                ra

video/3gpp                                       3gpp 3gp
video/mp2t                                       ts
video/mp4                                        mp4
video/mpeg                                       mpeg mpg
video/quicktime                                  mov
video/webm                                       webm
video/x-flv                                      flv
video/x-m4v                                      m4v
video/x-mng                                      mng
video/x-ms-asf                                   asx asf
video/x-ms-wmv                                   wmv
video/x-msvideo                                  avi
