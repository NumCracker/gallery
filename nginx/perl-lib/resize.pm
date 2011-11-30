package resize;
use nginx;
use File::Path qw(mkpath);
use Image::Magick;

our $base_dir="/var/pictures/";
our $cache_dir="/var/pictures_resized/";
our $image;

sub handler {
 my $r = shift;
 return DECLINED unless $r->uri =~ m/\.resize_to\.\d{1,}?x\d{1,}?\./;
 my $uri=$r->uri;
 $uri=~ s!^/resize!!;

 my $dest_file="$cache_dir/$uri";
 unless( -f $dest_file ){

     my @path_tokens=split("/", $uri);
     my $filename=pop @path_tokens;

     mkpath(join("/", $cache_dir, @path_tokens));

     my @filename_tokens=split('\.', $filename);

     # We know  the last part is the extension;
     # We know the one before that is the dimensions
     # We know that the one before that is the resize_to string

     my $ext=pop @filename_tokens;
     my $dimensions=pop @filename_tokens;
     pop @filename_tokens;
     $filename=join('.', @filename_tokens, $ext);

     my $real_file_path=join("/",   $base_dir, @path_tokens, $filename);
     return DECLINED unless -f $real_file_path;

     my ($width,$height)=split("x", $dimensions);
     if ($height<1) {
         $dimensions=$width;
     }

     $image= new Image::Magick;
     $image->Read($real_file_path);
     $image->Scale($dimensions);
     $image->Strip();
     $image->Write($dest_file);
 }
 $r->sendfile($dest_file);
 return OK;

}

1;
__END__
