#!/usr/bin/perl -w

our( @line, $filename );

#==============================================================================
#=== This is the 'fileselection1' class
#==============================================================================
package fileselection1;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;
} # End of sub BEGIN

sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW/LC_MESSAGES/print_scale.mo)
#	$class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;

	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'fileselection1' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'fileselection1' class
#==============================================================================
sub on_file_cancel_clicked {&destroy_Form;} # End of sub on_file_cancel_clicked

sub on_file_ok_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	$filename = $form -> { 'TOPLEVEL' }  -> get_filename();
	if( -f $filename )
	{
		open FILE,'< ' . $filename;
		@line = <FILE>;
	}
	close FILE;
	&destroy_Form;
} # End of sub on_file_ok_clicked

sub on_fileselection1_delete_event {&destroy_Form;} # End of sub on_fileselection1_delete_event


#==============================================================================
#=== This is the 'label' class
#==============================================================================
package label;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;
} # End of sub BEGIN

sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	$class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;

	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'label' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'label' class 
#==============================================================================
sub on_label_delete_event {&destroy_Form;} # End of sub on_label_delete_event

sub on_label_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $ll, $tp, $w, $l, $gap, $bk, $tl );
	&main::sendout( 'rdlab' . &main::encode( $form -> { 'spinbutton23' } -> get_value_as_int , 2 ) . "\015");
	$ll = &main::get_res();

	&main::get_res();
	if( $ll =~ /^\@/ && length( $ll ) >= 24 )
	{
		$tp = &main::decode(substr($ll,1,2));
		$w = &main::decode(substr($ll,5,4));
		$l = &main::decode(substr($ll,9,4));
		$gap = &main::decode(substr($ll,13,4));
		$bk = &main::decode(substr($ll,17,4));
		$tl = &main::decode(substr($ll,21,4));

		if( $tp ){	$form -> { 'combo-entry7' } -> set_text( "1．貼標" );	}
		else	{	$form -> { 'combo-entry7' } -> set_text( "0．連續紙" );	}
		
		$form -> { 'spinbutton64' } -> set_value( $l );
		$form -> { 'spinbutton63' } -> set_value( $w );
		if( $tp )
		{
			$form -> { 'spinbutton65' } -> set_sensitive( 1 );
			$form -> { 'spinbutton65' } -> set_value( $gap );
		}
		else
		{$form -> { 'spinbutton65' } -> set_sensitive( 0 );}
	
		$form -> { 'spinbutton66' } -> set_value( $bk );
		$form -> { 'spinbutton67' } -> set_value( $tl );
	}
} # End of sub on_label_read_clicked

sub on_label_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
        my( $content, $suite, $tp, $w, $l, $gap, $bk, $tl );
	
	$content = undef;
	$suite = $form -> { 'spinbutton23' } -> get_value_as_int;

	
	$tp = substr( $form -> {'combo-entry7'} -> get_text(),0,1);$content .= &main::encode( $tp ,2 ); $content .= "AA";
	$w = $form -> {'spinbutton63'} -> get_value_as_int(); $content .= &main::encode( $w , 4 );
	$l = $form -> {'spinbutton64'} -> get_value_as_int(); $content .= &main::encode( $l , 4 );
	if( $tp eq 1 )
	{#表為貼標
		$gap = $form -> {'spinbutton65'} -> get_value_as_int(); 
		$content .= &main::encode( $gap , 4 );
	}
	else#表為連續紙
	{$content .= "AAAA";}
	$bk = $form -> {'spinbutton66'} -> get_value_as_int(); $content .= &main::encode( $bk , 4 );
	$tl = $form -> {'spinbutton67'} -> get_value_as_int(); $content .= &main::encode( $tl , 4 );

	&main::sendout( 'wrlab' . &main::encode( $suite , 2 ) . $content . "\015" );

	&main::get_res();

} # End of sub on_label_write_clicked

sub on_default_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	$form -> {'combo-entry7'} -> set_text("1．貼標");
	$form -> {'spinbutton63'} -> set_value( 600 );
	$form -> {'spinbutton64'} -> set_value( 400 );
	$form -> { 'spinbutton65' } -> set_sensitive( 1 );
	$form -> {'spinbutton65'} -> set_value( 50 );
	$form -> {'spinbutton66'} -> set_value( 10 );
	$form -> {'spinbutton67'} -> set_value( 2 );

} # End of sub on_default_clicked





#==============================================================================
#=== This is the 'date' class
#==============================================================================
package date;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;

	use Time::tm;
	use Time::Local 'timelocal_nocheck';
	use Time::Local;

} # End of sub BEGIN

sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	$class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;

#	$window -> lookup_widget('unit_write') -> set_sensitive( 0 );;
	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'date' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End 閰她f sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'date' class
#==============================================================================
sub on_date_delete_event {&destroy_Form;} # End of sub on_date_delete_event

sub on_date_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $ll, $j ,$timefrom1970);
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	&main::sendout( 'rddtm' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if($ll =~ /^\@/)
	{
		$j = &main::decode(substr($ll,1));
		$timefrom1970 = timelocal_nocheck( $j, 0, 0, 1, 0, 0 );
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $timefrom1970 );
		$mon += 1;
		$year += 1900;
		$form -> { 'spinbutton24' } -> set_value( $hour );
		$form -> { 'spinbutton25' } -> set_value( $min );
		$form -> { 'spinbutton26' } -> set_value( $sec );
		$form -> { 'spinbutton27' } -> set_value( $mon );
		$form -> { 'spinbutton28' } -> set_value( $mday );
		$form -> { 'spinbutton29' } -> set_value( $year );
	}

} # End of sub on_date_read_clicked

sub on_date_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $timefrom1970, $timefrom2000, $opstr);
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);

	$hour = $form -> { 'spinbutton24' } -> get_value_as_int;
	$min  = $form -> { 'spinbutton25' } -> get_value_as_int;
	$sec  = $form -> { 'spinbutton26' } -> get_value_as_int;
	$mon  = $form -> { 'spinbutton27' } -> get_value_as_int - 1;
	$mday = $form -> { 'spinbutton28' } -> get_value_as_int;
	$year = $form -> { 'spinbutton29' } -> get_value_as_int;

	$timefrom1970 = timelocal( $sec, $min, $hour, $mday, $mon , $year );
	$timefrom2000 = $timefrom1970 - timelocal_nocheck( 0, 0, 0, 1, 0, 0 );

	$opstr = &main::encode( $timefrom2000 , 8 );
	&main::sendout( 'wrdtm' . $opstr . "\015" );
	&main::get_res();
} # End of sub on_date_write_clicked

sub on_tare_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $ll ,$j );
	&main::sendout('rdtar' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if($ll =~ /^\@/)
	{
		$j = &main::decode(substr($ll,1));
		$form -> {'spinbutton69'} -> set_value( $j );
	}
} # End of sub on_tare_read_clicked

sub on_tare_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	&main::sendout('wrtar' . &main::encode($form -> {'spinbutton69'} -> get_value_as_int, 6 ) . "\015");
	$form -> {'spinbutton69'} -> set_value( undef );
	&main::get_res();
} # End of sub on_tare_write_clicked

sub on_unit_price_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $ll, $j);
	&main::sendout('rdupr' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if($ll =~ /^\@/)
	{
		$j = &main::decode(substr($ll,1));
		$form -> {'spinbutton68'} -> set_value( $j );
	}
} # End of sub on_unit_price_read_clicked

sub on_unit_price_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	&main::sendout('wrupr' . &main::encode( $form -> {'spinbutton68'} -> get_value_as_int, 6 ) . "\015");
	$form -> {'spinbutton68'} -> set_value( undef );
	&main::get_res();

} # End of sub on_unit_price_write_clicked

sub on_unit_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $ll, $j);
	&main::sendout('rdcun' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if($ll =~ /^\@/)
	{
		$j = &main::decode( substr( $ll, 1 ) );
		$form -> {'spinbutton70'} -> set_value( $j );

	}
} # End of sub on_unit_read_clicked

sub on_unit_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

=cut
	&main::sendout('wrcun' . &main::encode( $form -> {'spinbutton70'} -> get_value_as_int, 2 ) . "\015");
	$form -> {'spinbutton70'} -> set_value( undef );
	&main::get_res();
=cut
} # End of sub on_unit_write_clicked

sub on_default_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	$form -> {'spinbutton68'} -> set_value( 0 );
	$form -> {'spinbutton69'} -> set_value( 0 );
	$form -> {'spinbutton70'} -> set_value( 0 );

} # End of sub on_default_clicked



#==============================================================================
#=== This is the 'print_format' class
#==============================================================================
package print_format;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================
my @layer = undef;

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;
} # End of sub BEGIN

sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	$class->load_translations('print_scale', 'test', undef, '/home/allways/prs_ext/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;
	$window -> lookup_widget('frame4') -> set_sensitive( 0 );
	$window -> lookup_widget('frame5') -> set_sensitive( 0 );

	&preview( $window -> FORM, 0);

	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals

	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'print_format' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'print_format' class
#==============================================================================
sub on_default_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	if( ( $form -> {'type_match_string'} -> active ) eq 0 )
	{#就是當 “不是”對應字串的時候
		$form -> {'spinbutton32'} -> set_value( 200 );#座標x
		$form -> {'spinbutton33'} -> set_value( 170 );#座標y
		$form -> {'spinbutton34'} -> set_value( 1 );#放大倍數x
		$form -> {'spinbutton35'} -> set_value( 1 );#放大倍數y

		$form -> {'combo-entry4'} -> set_text("1．  0    度");
		$form -> {'checkbutton1'} -> set_active( 0 );#鏡射
		$form -> {'checkbutton2'} -> set_active( 0 );#顛倒
		$form -> {'combo-entry5'} -> set_text("");

		$form -> {'spinbutton36'} -> set_value( 0 );#限制範圍左
		$form -> {'spinbutton39'} -> set_value( 431 );#限制範圍右
		$form -> {'spinbutton40'} -> set_value( 0 );#限制範圍上
		$form -> {'spinbutton41'} -> set_value( 399 );#限制範圍下
	}
	else
	{#就是當 “是”對應字串的時候
		$form -> {'spinbutton53'} -> set_value( 0 );#對應字串
		$form -> {'spinbutton54'} -> set_value( 0 );#起始
		$form -> {'spinbutton55'} -> set_value( 0 );#結束
		$form -> {'spinbutton56'} -> set_value( 0 );#位置
	}

	if( ( $form -> {'type_string'} -> active ) eq 1 || ( $form -> {'type_figure'} -> active ) eq 1 )
	{#就是當為字串為數字的時候，此處為字串格式設定

		$form -> {'spinbutton42'} -> set_value( 8 );#字串格式設定前進x
		$form -> {'spinbutton43'} -> set_value( 0 );#字串格式設定前進y
		$form -> {'spinbutton44'} -> set_value( 0 );#字串格式設定換行x
		$form -> {'spinbutton45'} -> set_value( 16 );#字串格式設定換行y
		$form -> {'spinbutton46'} -> set_value( 0 );#字串格式設定回頭x
		$form -> {'spinbutton47'} -> set_value( 0 );#字串格式設定回頭y
	}

	if( $form -> {'type_figure'} -> active eq 1 )
	{#當數字的時
		$form -> {'spinbutton48'} -> set_value( 0 );#填充字元
		$form -> {'radiobutton14'} -> set_active( 1 );#若為數字設定時其填充字元，0為無正號，1為帶符號
	}

	if( $form -> {'type_bar'} -> active eq 1 )
	{#條碼
		$form -> {'combo-entry6'} -> set_text("1．Code 128");
		$form -> {'spinbutton49'} -> set_value( 75 );
		$form -> {'spinbutton50'} -> set_value( 8 );
		$form -> {'spinbutton51'} -> set_value( 2 );
		$form -> {'spinbutton52'} -> set_value( 1 );
	}
} # End of sub on_default_clicked

sub on_print_format_delete_event {&destroy_Form;} # End of sub on_print_format_delete_event

sub on_type_bar_toggled {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	if( $form -> {'type_bar'} -> active )
	{
		$form -> {'frame3'} -> set_sensitive( 1 );
		$form -> {'frame4'} -> set_sensitive( 1 );

		$form -> {'frame2'} -> set_sensitive( 0 );
		$form -> {'frame1'} -> set_sensitive( 0 );
		$form -> {'frame5'} -> set_sensitive( 0 );
	}
	&on_default_clicked;
} # End of sub on_type_bar_toggled

sub on_type_figure_toggled {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	if( $form -> {'type_figure'} -> active )
	{
		$form -> {'frame1'} -> set_sensitive( 1 );
		$form -> {'frame2'} -> set_sensitive( 1 );
		$form -> {'frame3'} -> set_sensitive( 1 );

		$form -> {'frame4'} -> set_sensitive( 0 );
		$form -> {'frame5'} -> set_sensitive( 0 );
	}
	&on_default_clicked;
} # End of sub on_type_figure_toggled

sub on_type_match_string_toggled {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	if( $form -> {'type_match_string'} -> active )
	{
		$form -> {'frame5'} -> set_sensitive( 1 );

		$form -> {'frame2'} -> set_sensitive( 0 );
		$form -> {'frame3'} -> set_sensitive( 0 );
		$form -> {'frame4'} -> set_sensitive( 0 );
		$form -> {'frame1'} -> set_sensitive( 0 );
	}
	&on_default_clicked;
} # End of sub on_type_match_string_toggled

sub on_type_string_toggled {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	if( $form -> {'type_string'} -> active )
	{
		$form -> {'frame1'} -> set_sensitive( 1 );
		$form -> {'frame3'} -> set_sensitive( 1 );

		$form -> {'frame2'} -> set_sensitive( 0 );
		$form -> {'frame4'} -> set_sensitive( 0 );
		$form -> {'frame5'} -> set_sensitive( 0 );
	}
	&on_default_clicked;
} # End of sub on_type_string_toggled

sub on_print_format_read_clicked {

	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $item, $suite, $ll, %prf, $i, $xl, $xr);

	GETITEM:
	{
		if( $form -> {'item_label'} -> active )
		{ $item = $form -> { 'label_suite' } -> get_value_as_int() - 1 ;last GETITEM; }
		if( $form -> {'transhead'} -> active ) { $item =  6; last GETITEM; }
		if( $form -> {'transbody'} -> active ) { $item =  7; last GETITEM; }
		if( $form -> {'transaccount'} -> active ) { $item =  8; last GETITEM; }
		if( $form -> {'reporthead'} -> active ) { $item =  9; last GETITEM; }
		if( $form -> {'reportbody'} -> active ) { $item = 10; last GETITEM; }
		if( $form -> {'reportaccount'} -> active ) { $item = 11; last GETITEM; }
	}

	$suite = $form -> {'suite'} -> get_value_as_int();

	&main::sendout('rdpfl' . &main::encode($item,2) . "\015");
	$ll = &main::get_res();
	&main::get_res();

	if( &main::decode( substr( $ll, 1 )) eq 0 ){ return; }

	if( $suite >= &main::decode( substr( $ll, 1 ) ) )#當目前指定的組數超過已建立的組數時
	{
		$suite = &main::decode( substr( $ll, 1 ) ) - 1 ;
		$form -> {'suite'} -> set_value( $suite );
	}

	$form -> {'frame1'} -> set_sensitive( 0 );
	$form -> {'frame2'} -> set_sensitive( 0 );
	$form -> {'frame3'} -> set_sensitive( 0 );
	$form -> {'frame4'} -> set_sensitive( 0 );
	$form -> {'frame5'} -> set_sensitive( 0 );

	&main::sendout('rdprf' . &main::encode( $suite, 4 ) . &main::encode( $item, 2 ) . "\015");
	$ll = &main::get_res();
	&main::get_res();

	if( $ll =~ /^\@/ )
	{
		$prf{'item'} = &main::decode(substr($ll,1,2));#重量、重量小數點、單價、單價小數點位置………1到20順序排列
		SETITEM:
		{
			if( $prf{'item'} eq  1 ){ $form -> {'combo-entry3'}->set_text("1．重量"); last SETITEM;}
			if( $prf{'item'} eq  2 ){ $form -> {'combo-entry3'}->set_text("2．重量小數點位置");last SETITEM;}
			if( $prf{'item'} eq  3 ){ $form -> {'combo-entry3'}->set_text("3．單價");last SETITEM;}
			if( $prf{'item'} eq  4 ){ $form -> {'combo-entry3'}->set_text("4．單價小數點位置");last SETITEM;}
			if( $prf{'item'} eq  5 ){ $form -> {'combo-entry3'}->set_text("5．未折扣總價");last SETITEM;}
			if( $prf{'item'} eq  6 ){ $form -> {'combo-entry3'}->set_text("6．折扣金額");last SETITEM;}
			if( $prf{'item'} eq  7 ){ $form -> {'combo-entry3'}->set_text("7．未稅已折扣總價");last SETITEM;}
			if( $prf{'item'} eq  8 ){ $form -> {'combo-entry3'}->set_text("8．總價");last SETITEM;}
			if( $prf{'item'} eq  9 ){ $form -> {'combo-entry3'}->set_text("9．稅金");last SETITEM;}
			if( $prf{'item'} eq 10 ){ $form -> {'combo-entry3'}->set_text("10．總價小數點位置");last SETITEM;}
			if( $prf{'item'} eq 11 ){ $form -> {'combo-entry3'}->set_text("11．扣重");last SETITEM;}
			if( $prf{'item'} eq 12 ){ $form -> {'combo-entry3'}->set_text("12．重量單位");last SETITEM;}
			if( $prf{'item'} eq 13 ){ $form -> {'combo-entry3'}->set_text("13．計價單位");last SETITEM;}
			if( $prf{'item'} eq 14 ){ $form -> {'combo-entry3'}->set_text("14．累計金額");last SETITEM;}
			if( $prf{'item'} eq 15 ){ $form -> {'combo-entry3'}->set_text("15．品名");last SETITEM;}
			if( $prf{'item'} eq 16 ){ $form -> {'combo-entry3'}->set_text("16．商品號碼");last SETITEM;}
			if( $prf{'item'} eq 17 ){ $form -> {'combo-entry3'}->set_text("17．製造日期");last SETITEM;}
			if( $prf{'item'} eq 18 ){ $form -> {'combo-entry3'}->set_text("18．有效日期");last SETITEM;}
			if( $prf{'item'} eq 19 ){ $form -> {'combo-entry3'}->set_text("19．交易日期");last SETITEM;}
			if( $prf{'item'} eq 20 ){ $form -> {'combo-entry3'}->set_text("20．頁數");last SETITEM;}
		}

		$prf{'rep'} = &main::decode(substr($ll,3,2));##表現形式：1為數字、2為字串、3為條碼、7為對應字串
		if( $prf{'rep'} eq 1 )
		{#若為數字
			$form -> {'frame2'} -> set_sensitive(1);
			$form -> {'frame1'} -> set_sensitive(1);
			$form -> {'frame3'} -> set_sensitive(1);
			$form -> {'type_figure'} -> set_active(1);
		}
		if( $prf{'rep'} eq 2 )
		{
			$form -> {'frame1'} -> set_sensitive( 1 );
			$form -> {'frame3'} -> set_sensitive( 1 );
			$form -> {'type_string'} -> set_active(1);
		}
		if( $prf{'rep'} eq 3 )
		{
			$form -> {'frame4'} -> set_sensitive( 1 );
			$form -> {'frame3'} -> set_sensitive( 1 );
			$form -> {'type_bar'} -> set_active(1);
		}
		if( $prf{'rep'} eq 7 )
		{
			$form -> {'frame5'} -> set_sensitive( 1 );
			$form ->{'type_match_string'} -> set_active(1);
		}

		if( $prf{'rep'} ne 7 )
		{#此為基本設定，除了對應字串外其餘都會有
			$prf{'x'} = &main::decode(substr($ll,5,4));#座標x
			$form -> {'spinbutton32'} -> set_value( $prf{'x'} );

			$prf{'y'} = &main::decode(substr($ll,9,4));#座標y
			$form -> {'spinbutton33'} -> set_value( $prf{'y'} );

			$prf{'sclx'} = &main::decode(substr($ll,13,2));#放大倍數x
			$form -> {'spinbutton34'} -> set_value( $prf{'sclx'} );

			$prf{'scly'} = &main::decode(substr($ll,15,2));#放大倍數y
			$form -> {'spinbutton35'} -> set_value( $prf{'scly'} );

			$prf{'orien'} = &main::decode(substr($ll,17,2));
			#旋轉角度0為0，1為90，2為180，3為270，鏡射為4，顛倒為8
			if( $prf{'orien'} & ( 2 ** 3 ) )
			{	$form -> {'checkbutton2'} -> set_active( 1 ); } #確定上下顛倒
			else
			{	$form -> {'checkbutton2'} -> set_active( 0 ); } #確定不上下顛倒
			if( $prf{'orien'} & ( 2 ** 2 ) )
			{	$form -> {'checkbutton1'} -> set_active( 1 ); } #確定鏡射
			else
			{	$form -> {'checkbutton1'} -> set_active( 0 ); } #確定不鏡射
			if( $prf{'orien'} & ( 2 ** 1 ) )
			{
				if( $prf{'orien'} & ( 2 ** 0 ) )
				{ $form -> {'combo-entry4'} -> set_text("4．270  度"); }
				else
				{ $form -> {'combo-entry4'} -> set_text("3．180  度"); }
			}
			else
			{
				if( $prf{'orien'} & ( 2 ** 0 ) )
				{ $form -> {'combo-entry4'} -> set_text("2． 90   度"); }
				else
				{ $form -> {'combo-entry4'} -> set_text("1．  0    度");}
			}

			$prf{'pm'} = &main::decode(substr($ll,19,2));#or:2,xor:3,and:1
			if( $prf{'pm'} eq 1 )
			{ $form -> {'combo-entry5'} -> set_text("1．AND"); }
			elsif( $prf{'pm'} eq 2 )
			{ $form -> {'combo-entry5'} -> set_text("2．OR"); }
			else
			{ $form -> {'combo-entry5'} -> set_text("3．XOR"); }

			$prf{'xbl'} = &main::decode(substr($ll,21,4));

			$prf{'yu'} = &main::decode(substr($ll,25,4));#列印限制範圍“上”
			$form -> {'spinbutton40'} -> set_value( $prf{'yu'} );

			$prf{'xbr'} = &main::decode(substr($ll,29,4));

			$prf{'yd'} = &main::decode(substr($ll,33,4));#列印限級範圍“下”
			$form -> {'spinbutton41'} -> set_value( $prf{'yd'} );

			$prf{'xbitl'} = &main::decode(substr($ll,37,2));
			$prf{'xbitr'} = &main::decode(substr($ll,39,2));

			$i  = 7;
			while( ( ( 2 ** $i-- ) & $prf{'xbitl'} ) eq 0 ){}
			$i = 7 - $i - 1;
			$xl= $prf{'xbl'} * 8 + $i ;
			$form -> {'spinbutton36'} -> set_value( $xl );

			$i = 0;
			while( ( ( 2 ** $i++ ) & $prf{'xbitr'} ) eq 0 ){}
			$xr= $prf{'xbr'} * 8 + $i - 1;
			$form -> {'spinbutton39'} -> set_value( $xr );
		}
		else
		{#若為對應字串時
			$prf{'match_string'} = &main::decode(substr($ll,5,2));#對應字串
			$form -> {'spinbutton53'} -> set_value( $prf{'match_string'} );

			$prf{'start'} = &main::decode(substr($ll,7,2));#起始
			$form -> {'spinbutton54'} -> set_value( $prf{'start'} );

			$prf{'stop'} = &main::decode(substr($ll,9,2));#結束
			$form -> {'spinbutton55'} -> set_value( $prf{'stop'} );

			$prf{'position'} = &main::decode(substr($ll,11,2));#位置
			$form -> {'spinbutton56'} -> set_value( $prf{'position'} );
		}

		if( ( $prf{'rep'} eq 2 ) || ( $prf{'rep'} eq 1 ) )
		{#若為字串或是為數字時
			if( ( $prf{'forward_x'} = &main::decode(substr($ll,41,4) ) ) > 99 )#字串格式設定前進x
			{$prf{'forward_x'} -= 2 ** 16;	}
			$form -> {'spinbutton42'} -> set_value( $prf{'forward_x'} );

			if( ( $prf{'forward_y'} = &main::decode(substr($ll,45,4) ) ) > 99 )#字串格式設定前進y
			{$prf{'forward_y'} -= 2 ** 16;	}
			$form -> {'spinbutton43'} -> set_value( $prf{'forward_y'} );

			$prf{'backward_x'} = &main::decode(substr($ll,49,4));#字串格式設定回頭x
			$form -> {'spinbutton46'} -> set_value( $prf{'backward_x'} );

			$prf{'backward_y'} = &main::decode(substr($ll,53,4));#字串格式設定回頭y
			$form -> {'spinbutton47'} -> set_value( $prf{'backward_y'} );

			if( ( $prf{'linefeed_x'} = &main::decode(substr($ll,57,4) ) ) > 99 )#字串格式設定換行x
			{
				$prf{'linefeed_x'} -= 2 ** 16;
			}
			$form -> {'spinbutton44'} -> set_value( $prf{'linefeed_x'} );

			if( ( $prf{'linefeed_y'} = &main::decode(substr($ll,61,4) ) ) > 99 )#字串格式設定換行y
			{
				$prf{'linefeed_y'} -= 2 ** 16;
			}
			$form -> {'spinbutton45'} -> set_value( $prf{'linefeed_y'} );
		}

		if( $prf{'rep'} eq 1 )
		{#若為數字設定時
			$prf{'padstring'} = &main::decode(substr($ll,70,1));#
			$form -> {'spinbutton48'} -> set_value( $prf{'padstring'} );
			$prf{'signed'} = &main::decode(substr($ll,71,2));#
			if( $prf{'signed'} eq 1 )
			{ $form -> {'radiobutton15'} -> set_active(1); }
			else
			{ $form -> {'radiobutton14'} -> set_active(1); }
		}

		if( $prf{'rep'} eq 3 )
		{#只有是條碼的時候才需要
			$prf{'bar_type'} = &main::decode(substr($ll,41,2));#其條碼型態：code128 ，Codabar 等等，值為0到7
			SETBAR:
			{
			if( $prf{'bar_type'} eq 0 ){ $form -> {'combo-entry6'} -> set_text("1．Code 128"); last SETBAR; }
			if( $prf{'bar_type'} eq 1 ){ $form -> {'combo-entry6'} -> set_text("2．CodeBar"); last SETBAR; }
			if( $prf{'bar_type'} eq 2 ){ $form -> {'combo-entry6'} -> set_text("3．Code 25"); last SETBAR; }
			if( $prf{'bar_type'} eq 3 ){ $form -> {'combo-entry6'} -> set_text("4．Upc E"); last SETBAR; }
			if( $prf{'bar_type'} eq 4 ){ $form -> {'combo-entry6'} -> set_text("5．Upc A"); last SETBAR; }
			if( $prf{'bar_type'} eq 5 ){ $form -> {'combo-entry6'} -> set_text("6．EAN 8"); last SETBAR; }
			if( $prf{'bar_type'} eq 6 ){ $form -> {'combo-entry6'} -> set_text("7．EAN 13"); last SETBAR; }
			if( $prf{'bar_type'} eq 7 ){ $form -> {'combo-entry6'} -> set_text("8．Code 39"); last SETBAR; }
			}
			#&main::decode(substr($ll,43,2));沒有用到
			$prf{'mainheight'} = &main::decode(substr($ll,45,4));#主體高
			$form -> {'spinbutton49'} -> set_value( $prf{'mainheight'} );

			$prf{'protectheight'} = &main::decode(substr($ll,49,4));#護線高
			$form -> {'spinbutton50'} -> set_value( $prf{'protectheight'} );

			$prf{'line'} = &main::decode(substr($ll,53,2));#線寬
			$form -> {'spinbutton51'} -> set_value( $prf{'line'} );

			$prf{'thinline'} = &main::decode(substr($ll,55,2));#薄線寬
			$form -> {'spinbutton52'} -> set_value( $prf{'thinline'} );
		}
	}
} # End of sub on_print_format_read_clicked

sub on_print_format_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $suite, $content, $item, $orien, $ll ,$type );
	my( $x_place, $y_place, $string );

	$content = undef;

	GETITEM:
	{
		if( $form -> {'item_label'} -> active )
		{$item = $form -> { 'label_suite' } -> get_value_as_int() - 1;last GETITEM;}
		if( $form -> {'transhead'} -> active ){$item = 6;last GETITEM; }
		if( $form -> {'transbody'} -> active ){$item = 7;last GETITEM; }
		if( $form -> {'transaccount'} -> active ){$item = 8;last GETITEM; }
		if( $form -> {'reporthead'} -> active ){$item = 9; last GETITEM; }
		if( $form -> {'reportbody'} -> active ){$item = 10; last GETITEM; }
		if( $form -> {'reportaccount'} -> active ){$item = 11; last GETITEM; }
	}

	$suite = $form -> {'suite'} -> get_value_as_int();
	&main::sendout('rdpfl' . &main::encode($item,2) . "\015");
	$ll = &main::get_res();
	&main::get_res();

	if( $suite > &main::decode( substr( $ll, 1 ) ) )#當目前指定的組數超過已建立的組數時
	{
		$suite = &main::decode( substr( $ll, 1 ) );
		$form -> {'suite'} -> set_value( $suite );
	}

	$content .= &main::encode( $type = substr( $form -> {'combo-entry3'} -> get_text , 0, 1 ), 2 );
	#重量、重量小數點、單價、單價小數點位置………1到20順序排列且為第1-2字元
	GETREP:
	{#為第3-4字元
		if( $form -> {'type_figure'} -> active ){ $content .= &main::encode( 1, 2); last GETREP;}
		if( $form -> {'type_string'} -> active ){ $content .= &main::encode( 2, 2); last GETREP;}
		if( $form -> {'type_bar'} -> active ){ $content .= &main::encode( 3, 2); last GETREP;}
		if( $form -> {'type_match_string'} -> active ){ $content .= &main::encode( 7, 2); last GETREP;}
	}

	if( ( $form -> {'type_match_string'} -> active ) eq 0 )
	{#就是當 “不是”對應字串的時候且編碼動作為第5到40的ASCII字元
		$content .= &main::encode( $form -> {'spinbutton32'} -> get_value_as_int(), 4 );#座標x
		$content .= &main::encode( $form -> {'spinbutton33'} -> get_value_as_int(), 4 );#座標y
		$content .= &main::encode( $form -> {'spinbutton34'} -> get_value_as_int(), 2 );#放大倍數x
		$content .= &main::encode( $form -> {'spinbutton35'} -> get_value_as_int(), 2 );#放大倍數y

		$orien= 0;
		if( $form -> {'checkbutton2'} -> active ){$orien += 8;}
		if( $form -> {'checkbutton1'} -> active ){$orien += 4;}
		$orien += substr( $form -> {'combo-entry4'} -> get_text(), 0, 1 ) - 1;
		$content .= &main::encode( $orien , 2 );#旋轉角度0為0，1為90，2為180，3為270，鏡射為4，顛倒為8
		$content .= &main::encode( substr( $form -> {'combo-entry5'} -> get_text(), 0, 1 ), 2 );#or:2,xor:3,and:1
		$content .= &main::encode( $form -> {'spinbutton36'} -> get_value_as_int() / 8 , 4 );
		$content .= &main::encode( $form -> {'spinbutton40'} -> get_value_as_int(), 4 );#列印限制範圍“上”
		$content .= &main::encode( $form -> {'spinbutton39'} -> get_value_as_int() / 8 , 4 );
		$content .= &main::encode( $form -> {'spinbutton41'} -> get_value_as_int(), 4 );#列印限制範圍“下”
		$content .= &main::encode( 2 ** ( 8 - $form -> {'spinbutton36'} -> get_value_as_int() % 8 ) - 1, 2 );
		$content .= &main::encode( 2 ** 8 - 2 ** ( $form -> {'spinbutton39'} -> get_value_as_int() % 8 )  , 2 );
	}
	else
	{#就是當 “是”對應字串的時候且編碼動作為第5到12的ASCII字元
		$content .= &main::encode( $form -> {'spinbutton53'} -> get_value_as_int(), 2 );#對應字串
		$content .= &main::encode( $form -> {'spinbutton54'} -> get_value_as_int(), 2 );#起始
		$content .= &main::encode( $form -> {'spinbutton55'} -> get_value_as_int(), 2 );#結束
		$content .= &main::encode( $form -> {'spinbutton56'} -> get_value_as_int(), 2 );#位置
		$content .= "A" x 76;#76個字元沒有暫時用到，為13-88的字元
	}

	if( ( $form -> {'type_string'} -> active ) eq 1 || ( $form -> {'type_figure'} -> active ) eq 1 )
	{#就是當為字串為數字的時候，此處為字串格式設定，為41到64的字元
		if( $form -> {'spinbutton42'} -> get_value_as_int() > 0 )#字串格式設定前進x
		{$content .= &main::encode( $form -> {'spinbutton42'} -> get_value_as_int(), 4 );}
		else
		{$content .= &main::encode( 2 ** 16 + $form -> {'spinbutton42'} -> get_value_as_int(), 4 );}

		if( $form -> {'spinbutton43'} -> get_value_as_int() > 0 )#字串格式設定前進y
		{$content .= &main::encode( $form -> {'spinbutton43'} -> get_value_as_int(), 4 );}
		else
		{$content .= &main::encode( 2 ** 16 + $form -> {'spinbutton43'} -> get_value_as_int(), 4 );}

		$content .= &main::encode( $form -> {'spinbutton46'} -> get_value_as_int(), 4 );#字串格式設定回頭x
		$content .= &main::encode( $form -> {'spinbutton47'} -> get_value_as_int(), 4 );#字串格式設定回頭y

		if( $form -> {'spinbutton44'} -> get_value_as_int() > 0 )#字串格式設定換行x
		{$content .= &main::encode( $form -> {'spinbutton44'} -> get_value_as_int(), 4 );}
		else
		{$content .= &main::encode( 2 ** 16 + $form -> {'spinbutton44'} -> get_value_as_int(), 4 );}

		if( $form -> {'spinbutton45'} -> get_value_as_int() > 0 )#字串格式設定換行y
		{$content .= &main::encode( $form -> {'spinbutton45'} -> get_value_as_int(), 4 );}
		else
		{$content .= &main::encode( 2 ** 16 + $form -> {'spinbutton45'} -> get_value_as_int(), 4 );}

		if( $form -> {'type_string'} -> active eq 1 )
		{$content .= "A" x 24;}#24個字元沒有暫時用到，為65-88的字元
	}

	if( $form -> {'type_figure'} -> active eq 1 )
	{#當數字的時才需要為65到72
		$content .= "AAAAA";#65到69的?r元暫用不到
		$content .= &main::encode( $form -> {'spinbutton48'} -> get_value_as_int(), 1 );#填充字元

		if( $form -> {'radiobutton14'} -> active )#若為數字設定時其填充字元，0為無正號，1為帶符號
		{$content .= &main::encode( 0, 2 );}
		else
		{$content .= &main::encode( 1, 2 );}
		$content .= "A" x 16;#16個字元沒有暫時用到，為73-88的字元
	}

	if( $form -> {'type_bar'} -> active eq 1 )
	{#條碼，為41到56的字元
		$content .= &main::encode( substr( $form -> {'combo-entry6'} -> get_text() , 0, 1 ) - 1, 2 );
		#若為條碼，其條碼型態：code128 or Codabar，值為0到7
		$content .= "AA";#decode(substr($ll,43,2));沒有用到
		$content .= &main::encode( $form -> {'spinbutton49'} -> get_value_as_int() , 4 );#主體高
		$content .= &main::encode( $form -> {'spinbutton50'} -> get_value_as_int() , 4 );#護線高
		$content .= &main::encode( $form -> {'spinbutton51'} -> get_value_as_int() , 2 );#線寬
		$content .= &main::encode( $form -> {'spinbutton52'} -> get_value_as_int() , 2 );#薄線寬
		$content .= "A" x 32;#32個字元沒有暫時用到，為57-88的字元
	}

	&main::sendout('lk' . "\015");#把機器鎖住
	&main::get_res();

	&main::sendout('wrprf' . &main::encode( $suite, 4 ) . &main::encode( $item, 2 ) . $content . "\015");
	&main::get_res();

	&main::sendout('ul' . "\015");#解鎖
	&main::get_res();

	if( ( $form -> {'type_figure'} -> active ) eq 1 ){ $string = $suite . "(123)"; }
	if( ( $form -> {'type_string'} -> active ) eq 1 ){ $string = $suite . "(str)"; }
	if( ( $form -> {'type_bar'} -> active ) eq 1 ){ $string = $suite . "(|||)"; }
	if( ( $form -> {'type_match_string'} -> active ) eq 1 ){ $string = $suite . "(mst)"; }

	$x_place = $form -> {'spinbutton32'} -> get_value_as_int();
	$y_place = $form -> {'spinbutton33'} -> get_value_as_int();

	SETTYPE:
	{
		if( $type eq  1 ){ $type = "Weight";          last SETTYPE;}
		if( $type eq  2 ){ $type = "Weight Point Position";last SETTYPE;}
		if( $type eq  3 ){ $type = "Unit Price";          last SETTYPE;}
		if( $type eq  4 ){ $type = "Unit Price Point Position";last SETTYPE;}
		if( $type eq  5 ){ $type = "Not Disc. Price";    last SETTYPE;}
		if( $type eq  6 ){ $type = "Discount Amount";      last SETTYPE;}
		if( $type eq  7 ){ $type = "No Tax Price";last SETTYPE;}
		if( $type eq  8 ){ $type = "Price";          last SETTYPE;}
		if( $type eq  9 ){ $type = "Tax";          last SETTYPE;}
		if( $type eq 10 ){ $type = "Price Point Position";last SETTYPE;}
		if( $type eq 11 ){ $type = "Tare";         last SETTYPE;}
		if( $type eq 12 ){ $type = "Weight Unit";     last SETTYPE;}
		if( $type eq 13 ){ $type = "Count Unit";     last SETTYPE;}
		if( $type eq 14 ){ $type = "Total Price";     last SETTYPE;}
		if( $type eq 15 ){ $type = "Product Name";         last SETTYPE;}
		if( $type eq 16 ){ $type = "Product Number";     last SETTYPE;}
		if( $type eq 17 ){ $type = "Manufactured Date";     last SETTYPE;}
		if( $type eq 18 ){ $type = "Valid Throgh";     last SETTYPE;}
		if( $type eq 19 ){ $type = "Transaction Time";     last SETTYPE;}
		if( $type eq 20 ){ $type = "Page";         last SETTYPE;}
	}

	$string .= $type;
	$layer[ $suite ] = "$x_place,$y_place,$string";

	&plot( $form );

} # End of sub on_print_format_write_clicked

sub on_drawingarea2_expose_event{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	&plot( $form );
}


sub on_item_label_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'item_label'} -> active ){&preview( $form, $form -> { 'label_suite' } -> get_value_as_int() - 1 );}
}

sub on_label_suite_changed{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'item_label'} -> active ){&preview( $form, $form -> { 'label_suite' } -> get_value_as_int() - 1 );}
}

sub on_transhead_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'transhead'} -> active ){&preview( $form, 6 );}
}

sub on_transbody_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'transbody'} -> active ){&preview( $form, 7 );}
}

sub on_transaccount_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'transaccount'} -> active ){&preview( $form, 8 );}
}

sub on_reporthead_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'reporthead'} -> active ){&preview( $form, 9 );}
}

sub on_reportbody_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'reportbody'} -> active ){&preview( $form, 10 );}
}

sub on_reportaccount_toggled{
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	@layer = undef;
	if( $form -> {'reportaccount'} -> active ){&preview( $form, 11 );}
}

sub preview{
        my( $form, $type, $item, $suite, $ll, $x_place, $y_place, $rep, $string );

	$form = shift;
	$item = shift;

	&main::sendout('rdpfl' . &main::encode( $item, 2 ) . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if( ( $suite = &main::decode( substr( $ll, 1 ))) gt 0 )
	{
		$suite--;
		for( 0 .. $suite )
		{#
			&main::sendout('rdprf' . &main::encode( $_, 4 ) . &main::encode( $item, 2 ) . "\015");
			$ll = &main::get_res();
			&main::get_res();
			if( $ll =~ /^\@/ )
			{
				$type = &main::decode(substr($ll,1,2));#
				#print $type . "\n";
				SETTYPE:
				{
					if( $type eq  1 ){ $type = "Weight";          last SETTYPE;}
					if( $type eq  2 ){ $type = "Weight Point Position";last SETTYPE;}
					if( $type eq  3 ){ $type = "Unit Price";          last SETTYPE;}
					if( $type eq  4 ){ $type = "Unit Price Point Position";last SETTYPE;}
					if( $type eq  5 ){ $type = "Not Disc. Price";    last SETTYPE;}
					if( $type eq  6 ){ $type = "Discount Amount";      last SETTYPE;}
					if( $type eq  7 ){ $type = "No Tax Price";last SETTYPE;}
					if( $type eq  8 ){ $type = "Price";          last SETTYPE;}
					if( $type eq  9 ){ $type = "Tax";          last SETTYPE;}
					if( $type eq 10 ){ $type = "Price Point Position";last SETTYPE;}
					if( $type eq 11 ){ $type = "Tare";         last SETTYPE;}
					if( $type eq 12 ){ $type = "Weight Unit";     last SETTYPE;}
					if( $type eq 13 ){ $type = "Count Unit";     last SETTYPE;}
					if( $type eq 14 ){ $type = "Total Price";     last SETTYPE;}
					if( $type eq 15 ){ $type = "Product Name";         last SETTYPE;}
					if( $type eq 16 ){ $type = "Product Number";     last SETTYPE;}
					if( $type eq 17 ){ $type = "Manufactured Date";     last SETTYPE;}
					if( $type eq 18 ){ $type = "Valid Throgh";     last SETTYPE;}
					if( $type eq 19 ){ $type = "Transaction Time";     last SETTYPE;}
					if( $type eq 20 ){ $type = "Page";         last SETTYPE;}

				}

				$rep = &main::decode(substr($ll,3,2));#

				SETREP:
				{
					if( $rep eq 1 ){ $string = $_ . "(123)"; last SETREP; }
					if( $rep eq 2 ){ $string = $_ . "(str)"; last SETREP; }
					if( $rep eq 3 ){ $string = $_ . "(|||)"; last SETREP; }
					if( $rep eq 7 ){ $string = $_ . "(mst)"; last SETREP; }
				}

				$x_place = &main::decode(substr($ll,5,4));#x

				$y_place = &main::decode(substr($ll,9,4));#y

				$string .= $type;

				$layer[ $_ ] = "$x_place,$y_place,$string";
			}
		}
	}
	&plot( $form );
}

sub plot{
	my $form = shift;
	my( $bgcolor, $drawing_area, $drawable, $black_gc, $white_gc, $font, $x_place, $y_place , $string );

	$drawing_area = $form -> {'drawingarea2'};

	$bgcolor = Gtk::Gdk::Color->parse_color( 'white' );
	$bgcolor = $drawing_area->window->get_colormap()->color_alloc( $bgcolor );
	$drawing_area->window->set_background( $bgcolor );
	$drawable = $drawing_area->window;

	$black_gc = $drawing_area->style->black_gc;

	$white_gc = $drawing_area->style->white_gc;
	$font = Gtk::Gdk::Font->load("-misc-fixed-medium-r-*-*-*-140-*-*-*-*-*-*");

	$drawable->draw_rectangle( $white_gc, 1, 0, 0, 1000, 1000 );

	foreach( @layer )
	{
		( $x_place, $y_place, $string ) = split( ',' , $_ );
		$drawable->draw_string( $font, $black_gc, $x_place, $y_place, $string );
	}
}

sub on_formatwritetofile_clicked {

	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my ( $path, $i, $ll, $j, @pr_len );
	$path = $form -> { 'combo-entry10' } -> get_text();
	
	open FILE,'>' . $path;

	for( $i = 0; $i < 12; $i++ )
	{
		&main::sendout('rdpfl' . &main::encode( $i, 2 ) . "\015");
		$ll = &main::get_res();
		&main::get_res();

		if( $ll =~ /^\@/)
		{
			$pr_len[$i] = &main::decode(substr($ll,1));#1到12組裡總共有哪些項是已設定的
		}
		
		for( $j = 0; $j < $pr_len[ $i ]; $j++ )
		{
			&main::sendout('rdprf' . &main::encode( $j, 4) . &main::encode( $i, 2) . "\015");
			#表第幾項，及第1-12之其中一組
			$ll = &main::get_res();
			&main::get_res();

			$ll = substr($ll,1);
			print FILE $j . ' ' . $i . ' ' . $ll . "\n";
		}
	}

	close FILE;
	
} # End of sub on_formatwritetofile_clicked

sub on_formatwritetoscale_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my ( $path, $line, @subopn );

	$path = $form -> { 'combo-entry10' } -> get_text();

	open FILE , '<' . $path;

	&main::sendout('lk' . "\015");#把機器鎖住
	&main::get_res();
	
	while( $line = <FILE> )
	{
		chomp( $line );
		@subopn = split( /\s+/, $line );
		&main::sendout('wrprf' . &main::encode($subopn[0],4) . &main::encode($subopn[1],2) . $subopn[2] . "\015");
		&main::get_res();
	}
	close FILE;

	&main::sendout('ul' . "\015");#解鎖
	&main::get_res();

} # End of sub on_formatwritetoscale_clicked

sub on_browse_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	
	fileselection1 -> app_run;
	$form -> {'combo-entry10'} -> set_text( $filename );
	$filename = undef;
	
} # End of sub on_browse_clicked


#==============================================================================
#=== This is the 'plu' class
#==============================================================================
package plu;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;


	use Time::tm;
	use Time::Local 'timelocal_nocheck';
	use Time::Local;
	use DBI;
} # End of sub BEGIN

sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	$class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;

	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'plu' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'plu' class
#==============================================================================
sub on_plu_delete_event {&destroy_Form;} # End of sub on_plu_delete_event

sub on_plu_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $page, $suite, $ll ,$wdate, $pdate, $disc, $start_time, $stop_time, $uprice, $prtare, $name , $number);
	my( $unit, $cunit, $tdisc, $tax, $class, $pf, $i, $timefrom1970 );
	my( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst );

	$page = $form -> { 'spinbutton71' } -> get_value_as_int() - 1;
	
	$suite = 70 * $page + $form -> { 'spinbutton3' } -> get_value_as_int() - 1;
	&main::sendout('rdplu' . &main::encode($suite,4) . "\015");
	$ll = &main::get_res();

	&main::get_res();
	if($ll =~ /^\@/)
	{
		$wdate = &main::decode(substr($ll,1,4));
		$timefrom1970 = timelocal_nocheck( 0, 0, 0, $wdate + 1, 0, 0 );
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $timefrom1970 );
		$mon += 1;
		$year += 1900;
		$wday eq 0 and $wday = "星期日";
		$wday eq 1 and $wday = "星期一"; $wday eq 2 and $wday = "星期二";$wday eq 3 and $wday = "星期三";
		$wday eq 4 and $wday = "星期四";$wday eq 5 and $wday = "星期五";$wday eq 6 and $wday = "星期六";
		$form -> { 'label31' } -> set_text( $wday );
		$form -> { 'spinbutton10' } -> set_value( $year );
		$form -> { 'spinbutton5' } -> set_value( $mon );
		$form -> { 'spinbutton6' } -> set_value( $mday );

		$pdate = &main::decode(substr($ll,5,4));
		$timefrom1970 = timelocal_nocheck( 0,0, 0, $pdate + 1, 0, 0 );
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $timefrom1970 );
		$mon += 1;
		$year += 1900;
		$wday eq 0 and $wday = "星期日";
		$wday eq 1 and $wday = "星期一"; $wday eq 2 and $wday = "星期二";$wday eq 3 and $wday = "星期三";
		$wday eq 4 and $wday = "星期四";$wday eq 5 and $wday = "星期五";$wday eq 6 and $wday = "星期六";
		$form -> { 'label32' } -> set_text( $wday );
		$form -> { 'spinbutton7' } -> set_value( $year );
		$form -> { 'spinbutton8' } -> set_value( $mon );
		$form -> { 'spinbutton9' } -> set_value( $mday );

		$disc =  &main::decode(substr($ll,9,8));
		if( $disc eq 0 )
		{
			$form -> {'percent'} -> set_active( 1 );
			$form -> { 'spinbutton57' } -> set_value( $disc );
		}
		elsif( $disc < 100 )
		{#表為百分比
			$form -> {'percent'} -> set_active( 1 );
			$disc = 100 - $disc;
			$form -> { 'spinbutton57' } -> set_value( $disc );
		}
		else
		{#表為直接扣除
			$form -> {'radiobutton18'} -> set_active( 1 );
			$disc = 2 ** 32 - $disc;
			$form -> { 'spinbutton57' } -> set_value( $disc );
		}

		$start_time = &main::decode(substr($ll,17,8));
		$timefrom1970 = timelocal_nocheck($start_time,0,0,1,0,0);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $timefrom1970 );
		$mon += 1;
		$year += 1900;
		$wday eq 0 and $wday = "星期日";
		$wday eq 1 and $wday = "星期一"; $wday eq 2 and $wday = "星期二";$wday eq 3 and $wday = "星期三";
		$wday eq 4 and $wday = "星期四";$wday eq 5 and $wday = "星期五";$wday eq 6 and $wday = "星期六";
		$form -> { 'label29' } -> set_text( $wday );
		$form -> { 'spinbutton11' } -> set_value( $year );
		$form -> { 'spinbutton12' } -> set_value( $mon );
		$form -> { 'spinbutton13' } -> set_value( $mday );
		$form -> { 'spinbutton14' } -> set_value( $hour );
		$form -> { 'spinbutton15' } -> set_value( $min );
		$form -> { 'spinbutton16' } -> set_value( $sec );


		$stop_time = &main::decode(substr($ll,25,8));
		$timefrom1970 = timelocal_nocheck($stop_time,0,0,1,0,0);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $timefrom1970 );
		$mon += 1;
		$year += 1900;
		$wday eq 0 and $wday = "星期日";
		$wday eq 1 and $wday = "星期一"; $wday eq 2 and $wday = "星期二"; $wday eq 3 and $wday = "星期三";
		$wday eq 4 and $wday = "星期四"; $wday eq 5 and $wday = "星期五"; $wday eq 6 and $wday = "星期六";
		$form -> { 'label30' } -> set_text( $wday );
		$form -> { 'spinbutton17' } -> set_value( $year );
		$form -> { 'spinbutton18' } -> set_value( $mon );
		$form -> { 'spinbutton19' } -> set_value( $mday );
		$form -> { 'spinbutton20' } -> set_value( $hour );
		$form -> { 'spinbutton21' } -> set_value( $min );
		$form -> { 'spinbutton22' } -> set_value( $sec );

		$uprice = 0;
		for( $i = 33; $i < 39; $i += 2 )
		{#unit price
			$uprice <<= 8;
			$uprice += &main::decode(substr($ll,$i,2));
		}

		$prtare = 0;
		for( $i = 39; $i < 45; $i += 2 )
		{#tare
			$prtare <<= 8;
			$prtare += &main::decode(substr($ll,$i,2));
		}

		$name = undef;
		for( $i = 45; $i < 85; $i += 2 )
		{$name .= chr(&main::decode(substr($ll,$i,2)));}
		$name =~ s/\00//g;
		
		$number = undef;
		for( $i = 85; $i < 125; $i += 2 )
		{$number .= chr(&main::decode(substr($ll,$i,2)));}
		$number =~ s/\00//g;

		$unit = &main::decode(substr($ll,125,2));
		print $unit . "\n";
		if( $unit eq 255 ){ $unit = "1．個數";} else { $unit = "2．重量"; }

		#cunit 暫時不用到
		#$cunit = &main::decode(substr($ll,127,2));
		#print "cunit" . $cunit . "\n";
		if( $tdisc = &main::decode(substr($ll,129,2) ) )
		{$form -> {'checkbutton3'} -> set_active( 1 );}
		else
		{$form -> {'checkbutton3'} -> set_active( 0 );}

		$tax = &main::decode(substr($ll,131,2));
		$class = &main::decode(substr($ll,133,2));
		$pf = &main::decode(substr($ll,135,2)) + 1;

		$form -> { 'spinbutton57' } -> set_value( $disc );
		$form -> { 'spinbutton58' } -> set_value( $uprice );
		$form -> { 'spinbutton59' } -> set_value( $prtare );
		$form -> { 'entry11' } -> set_text( $name );
		$form -> { 'entry12' } -> set_text( $number );
		$form -> { 'combo-entry8' } -> set_text( $unit );
		#cunit
		$form -> { 'spinbutton60' } -> set_value( $tax );
		$form -> { 'spinbutton61' } -> set_value( $class );
		$form -> { 'spinbutton62' } -> set_value( $pf );
	}
} # End of sub on_plu_read_clicked

sub on_plu_write_clicked {

	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $page, $suite, $content ,$timefrom1970, $timefrom2000 );
	my( $sec, $min, $hour, $mday, $mon, $year);
	my( $ll ,$wdate, $pdate, $disc, $uprice, $prtare, $name , $number, $i, $l, $opstr);
	my( $unit ,$tdisc, $tax, $class, $pf );

	$content = undef;

	$page = $form -> { 'spinbutton71' } -> get_value_as_int() - 1;
	
	$suite = 70 * $page + $form -> { 'spinbutton3' } -> get_value_as_int - 1;

	$mon = $form -> {'spinbutton5'} -> get_value_as_int() - 1;
	$mday = $form -> {'spinbutton6'} -> get_value_as_int();
	$year = $form -> {'spinbutton10'} -> get_value_as_int();
	$timefrom1970 = timelocal( 0, 0, 0, $mday, $mon, $year );
	$timefrom2000 = $timefrom1970 - timelocal_nocheck( 0, 0, 0, 1, 0, 0 );
	$timefrom2000 /= 86400;
	$content .= &main::encode( $timefrom2000 , 4 );

	$mon = $form -> {'spinbutton8'} -> get_value_as_int() - 1;
	$mday = $form -> {'spinbutton9'} -> get_value_as_int();
	$year = $form -> {'spinbutton7'} -> get_value_as_int();
	$timefrom1970 = timelocal( 0, 0, 0, $mday, $mon, $year );
	$timefrom2000 = $timefrom1970 - timelocal_nocheck( 0, 0, 0, 1, 0, 0 );
	$timefrom2000 /= 86400;
	$content .= &main::encode( $timefrom2000 , 4 );

	$disc = $form -> {'spinbutton57'} -> get_value_as_int();
	if( $disc eq 0 )
	{
		$content .= &main::encode( $disc , 8 );
	}
	elsif( $form -> {'percent'} -> active )
	{#表示為百分比
		if( $disc > 99 ){$disc = 99;}
		$disc = 100 - $disc;
		$content .= &main::encode( $disc , 8 );
	}
	else
	{#表示為直接扣除
		$disc = 2 ** 32 - $disc;
		$content .= &main::encode( $disc , 8 );
	}

	$mon = $form -> {'spinbutton12'} -> get_value_as_int() - 1;
	$mday = $form -> {'spinbutton13'} -> get_value_as_int();
	$year = $form -> {'spinbutton11'} -> get_value_as_int();
	$hour = $form -> {'spinbutton14'} -> get_value_as_int();
	$min = $form -> {'spinbutton15'} -> get_value_as_int();
	$sec = $form -> {'spinbutton16'} -> get_value_as_int();
	$timefrom1970 = timelocal( $sec, $min, $hour, $mday, $mon, $year );
	$timefrom2000 = $timefrom1970 - timelocal_nocheck( 0, 0, 0, 1, 0, 0 );
	$content .= &main::encode( $timefrom2000 , 8 );

	$mon = $form -> {'spinbutton18'} -> get_value_as_int() - 1;
	$mday = $form -> {'spinbutton19'} -> get_value_as_int();
	$year = $form -> {'spinbutton17'} -> get_value_as_int();
	$hour = $form -> {'spinbutton20'} -> get_value_as_int();
	$min = $form -> {'spinbutton21'} -> get_value_as_int();
	$sec = $form -> {'spinbutton22'} -> get_value_as_int();
	$timefrom1970 = timelocal( $sec, $min, $hour, $mday, $mon, $year );
	$timefrom2000 = $timefrom1970 - timelocal_nocheck( 0, 0, 0, 1, 0, 0 );
	$content .= &main::encode( $timefrom2000 , 8 );

	$uprice = $form -> {'spinbutton58'} -> get_value_as_int();
	$content .= &main::encode( $uprice , 6 );

	$prtare = $form -> {'spinbutton59'} -> get_value_as_int();
	$content .= &main::encode( $prtare , 6 );

	$name = $form -> {'entry11'} -> get_text;
	if( $name eq "" ){ return; }
	
	$name .= "\x0" x ( 20 - length( $name ) );
	$opstr = undef;
	$l = length( $name );
	for( $i = 0;$i < $l; $i++ )
	{
		$opstr .= &main::encode( ord( substr( $name, $i, 1) ), 2 );
	}
	$content .= $opstr;

	$number = $form -> {'entry12'} -> get_text;
	$number .= "\x0" x ( 20 - length( $number ) );
	$opstr = undef;
	$l = length( $number );
	for( $i = 0;$i < $l; $i++ )
	{
		$opstr .= &main::encode( ord( substr( $number, $i, 1) ), 2 );
	}
	$content .= $opstr;

	$unit = $form -> {'combo-entry8'} -> get_text;
	if( substr( $unit, 0, 1 ) eq 1 ){$content .= &main::encode( 255 , 2 );}
	else{	$content .= &main::encode( 0 , 2 );	}

	#cunit 暫時不用到
	#$cunit = &main::decode(substr($ll,127,2));
	$content .= &main::encode( 0, 2);

	$tdisc = $form -> {'checkbutton3'} -> active;
	$content .= &main::encode( $tdisc , 2 );

	$tax = $form -> {'spinbutton60'} -> get_value_as_int();
	$content .= &main::encode( $tax , 2 );

	$class = $form -> {'spinbutton61'} -> get_value_as_int();
	$content .= &main::encode( $class , 2 );

	$pf = $form -> {'spinbutton62'} -> get_value_as_int() - 1;
	$content .= &main::encode( $pf , 2 );

	&main::sendout( 'wrplu' . &main::encode( $suite , 4 ) . $content . "\015" );
	&main::get_res();


$form -> {'entry11'} -> set_text("");
$form -> {'spinbutton3'} -> set_value( $form -> {'spinbutton3'} -> get_value_as_int() + 1 );





















	
	my( $dbh, $sth );
	
	( $dbh = DBI -> connect( 'dbi:Pg:dbname=print_scale', 'allways','allways')) 
		or die "Can't connect to Pg database: $DBI::errstr\n";
	
	#check if this suite has already exists before?
	$sth = $dbh -> prepare( "select suite from plu where suite = ?;" );
	$sth -> execute( $suite );
	my $p = $sth -> fetchrow_array();

	if( defined $p )
	{# lt 0,the suite user indicate has ever existed before, then delete that record.
		$sth = $dbh -> prepare( "delete from plu where suite = ?;");
		$sth -> execute( $suite );
	}

	# eq 0,the suite user indicate is never existed before
	$sth = $dbh -> prepare( "insert into plu values( ?, ?, ? );" );
	$sth -> execute( $suite, $uprice, $prtare );

#	$sth->execute();
	
#	if( $suite  )
		
	# Prepare the statement handle
#	$sth = $dbh -> prepare( "insert into plu values( $suite, $uprice, $prtare )" );
#	$sth->execute();



# Fetch the data
	#@row = $sth->fetchrow_array();
	# while( @row = $sth->fetchrow_array())
	# {
	# #       print "Megalith site $row[0] is a $row[1]\n";
# print "Megalith site $row[0] . $row[1] \n";
	# }
	#
	# print "\n";
	#
	$sth->finish();
	#Disconnect from the database

	$dbh->disconnect();

} # End of sub on_plu_write_clicked

sub on_entry11_activate {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	
	&on_plu_write_clicked;
	$form -> {'entry11'} -> sensitive();
} # End of sub on_entry11_button_press_event

sub on_default_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my( $ll, $j ,$timefrom1970);
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
	&main::sendout( 'rddtm' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if($ll =~ /^\@/)
	{
		$j = &main::decode(substr($ll,1));
		$timefrom1970 = timelocal_nocheck( $j, 0, 0, 1, 0, 0 );
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime( $timefrom1970 );
		$mon += 1;
		$year += 1900;
		$wday eq 0 and $wday = "星期日";
		$wday eq 1 and $wday = "星期一"; $wday eq 2 and $wday = "星期二";$wday eq 3 and $wday = "星期三";
		$wday eq 4 and $wday = "星期四";$wday eq 5 and $wday = "星期五";$wday eq 6 and $wday = "星期六";

		$form -> { 'label31' } -> set_text( $wday );
		$form -> { 'spinbutton10' } -> set_value( $year );
		$form -> { 'spinbutton5' } -> set_value( $mon );
		$form -> { 'spinbutton6' } -> set_value( $mday );

		$form -> { 'label32' } -> set_text( $wday );
		$form -> { 'spinbutton7' } -> set_value( $year );
		$form -> { 'spinbutton8' } -> set_value( $mon );
		$form -> { 'spinbutton9' } -> set_value( $mday );

		$form -> { 'label29' } -> set_text( $wday );
		$form -> { 'spinbutton11' } -> set_value( $year );
		$form -> { 'spinbutton12' } -> set_value( $mon );
		$form -> { 'spinbutton13' } -> set_value( $mday );
		$form -> { 'spinbutton14' } -> set_value( $hour );
		$form -> { 'spinbutton15' } -> set_value( $min );
		$form -> { 'spinbutton16' } -> set_value( $sec );

		$form -> { 'label30' } -> set_text( $wday );
		$form -> { 'spinbutton17' } -> set_value( $year );
		$form -> { 'spinbutton18' } -> set_value( $mon );
		$form -> { 'spinbutton19' } -> set_value( $mday );
		$form -> { 'spinbutton20' } -> set_value( $hour );
		$form -> { 'spinbutton21' } -> set_value( $min );
		$form -> { 'spinbutton22' } -> set_value( $sec );
	}
	$form -> {'percent'} -> set_active( 1 );
	$form -> {'spinbutton57'} -> set_value( 50 );
	$form -> {'spinbutton58'} -> set_value( 0 );
	$form -> {'spinbutton59'} -> set_value( 0 );
	$form -> {'entry11'} -> set_text( "cargo" );
#	$form -> {'entry12'} -> set_text( "0001" );
	$form -> {'combo-entry8'} -> set_text( "1．個數" );
	$form -> {'checkbutton3'} -> set_active( 0 );
	$form -> {'spinbutton60'} -> set_value( 50 );

	$form -> {'spinbutton61'} -> set_value( 10 );
	$form -> {'spinbutton62'} -> set_value( 1 );

} # End of sub on_default_clicked

sub on_pluwritetofile_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my ( $path, $suite, $ll, $name, $i, $npl );
	$path = $form -> { 'combo-entry11' } -> get_text();

	#read number of plu
	&main::sendout( 'rdnpl' . "\015" );
	$ll = &main::get_res();
	&main::get_res();
	
	$npl = &main::decode( substr( $ll, 1 ) );
	
	open FILE,'> ' . $path;
	
	#scan all plu wheather if exist the value have set.
	for( $suite = 0; $suite < $npl; $suite++ )
	{
		&main::sendout('rdplu' . &main::encode( $suite, 4 ) . "\015" );
		$ll = &main::get_res();
		&main::get_res();
		
		#identify name exist whether if this plu is set or not.
		$name = undef;
	
		for( $i = 45; $i < 85; $i += 2 )
		{$name .= chr(&main::decode(substr($ll,$i,2)));}
		$name =~ s/\00//g;
		print $name . "\n";
		if( $name  ne "" )
		{
			$ll = substr($ll,1);
			print FILE $suite . ' ' . $ll . "\n";
		}
	}	
	close FILE;
}

sub on_pluwritetoscale_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	
	my ( $path, $line, @subopn );
	

	$path = $form -> { 'combo-entry11' } -> get_text();

	open FILE , '< ' . $path;

	while( $line = <FILE> )
	{
		chomp( $line );
		@subopn = split( /\s+/, $line );
		&main::sendout( 'wrplu' . &main::encode( $subopn[0] , 4 ) . $subopn[1] . "\015" );
		&main::get_res();
	}
	close FILE;
}

sub on_browse_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	
	fileselection1 -> app_run;
	$form -> {'combo-entry11'} -> set_text( $filename );
	$filename = undef;
	
} # End of sub on_browse_clicked
					

#==============================================================================
#=== This is the 'string' class
#==============================================================================
package string;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================
BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;
} # End of sub BEGIN
sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	$class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;
	
	my ( $ll, $suite, $j, $k, $tmp, $i );
	
	&main::sendout('rdstl' . "\015");
        $ll = &main::get_res();
	&main::get_res();
	
	if( ( $suite = &main::decode( substr( $ll, 1 ) ) ) gt 0 )
	{
		$suite--;
		for( 0 .. $suite )
		{
			&main::sendout('rdstr' . &main::encode( $_, 2 ) . "\015");
			$ll = &main::get_res();
			&main::get_res();
			
			if($ll =~ /^\@/)
			{
				$j = undef;
				$k = 0;
				$i = substr( $ll, 1 );
				while( $tmp =&main::decode( substr( $i, $k, 2 ) ) )
				{
					$k += 2;
					$j .= chr( $tmp );
				}
			}
			$window -> FORM -> {'clist1'} -> append( $_ , $j );
		}
	}
			

	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'string' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'string' class
#==============================================================================
sub on_string_delete_event {&destroy_Form;} # End of sub on_string_delete_event

sub on_string_read_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	my( $ll, $j, $k, $i, $tmp, $text, $suite );

	&main::sendout('rdstl' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if( &main::decode( substr( $ll, 1 ) ) eq 0 ){ return; }

	$suite = $form -> { 'spinbutton72' } -> get_value_as_int();

	if( $suite >= &main::decode( substr( $ll, 1 ) ) )#當目前指定的組數超過已建立的組數時
	{
		$suite = &main::decode( substr( $ll, 1 ) ) - 1 ;
		$form -> {'spinbutton72'} -> set_value( $suite );
	}
	
	
	$text = $form -> {'text3'};
	$text -> set_point( 0 );
	$text -> forward_delete( $text -> get_length() );


	&main::sendout('rdstr' . &main::encode( $suite, 2 ) . "\015");
	$ll = &main::get_res();
	&main::get_res();
	if($ll =~ /^\@/)
	{
		$j = undef;
		$k = 0;
		$i = substr( $ll, 1 );
		while( $tmp =&main::decode( substr( $i, $k, 2 ) ) )
		{
			$k += 2;
			$j .= chr( $tmp );
		}
		$text -> insert( undef, undef, undef, $j );
	}
} # End of sub on_string_read_clicked

sub on_string_write_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	my( $ll, $l, $i, $opstr, $content ,$text, $suite );

	$suite = $form -> { 'spinbutton72' } -> get_value_as_int();

	&main::sendout('rdstl' . "\015");
	$ll = &main::get_res();
	&main::get_res();
	
	if( $suite > &main::decode( substr( $ll, 1 ) ) )#當目前指定的組數超過已建立的組數時
	{
		$suite = &main::decode( substr( $ll, 1 ) );
		$form -> {'spinbutton72'} -> set_value( $suite );
	}
	
	$text = $form -> {'text3'};
	$content = $text -> get_chars( 0, $text -> get_length() );

	$opstr = undef;

	$content =~ s/\\n/\n/g;
	$content =~ s/\\/\\\\/g;
	$content =~ s/\\(.)/$1/g;
	$l = length( $content );
	for( $i = 0;$i < $l; $i++ )
	{
		$opstr .= &main::encode( ord( substr( $content, $i, 1) ), 2 );
	}

	if( $form -> { 'togglebutton1' } -> active() )
	{
		&main::sendout( 'wrsra' . &main::encode( $suite, 2) . &main::encode( $l, 2) . $opstr . "\015");
	}
	else
	{
		&main::sendout( 'wrstr' . &main::encode( $suite, 2) . &main::encode( $l, 2) . $opstr . "\015");
	}
	&main::get_res();
	$text -> set_point( 0 );
	$text -> forward_delete( $text -> get_length() );

	if( $suite eq &main::decode( substr( $ll, 1 ) ) )
	{#new suite
		$form -> {'clist1'} -> append( $suite, $content );
	}
	else
	{#change content of suite
		$form -> {'clist1'} -> set_text( $suite, 1, $content );
	}
	$form -> {'clist1'} -> set_sort_column( 0 );
	#execute the order of sort statement
	$form -> {'clist1'} -> sort;

} # End of sub on_string_write_clicked
sub on_string_load_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	fileselection1 -> app_run;

	foreach( @line )
	{
		$form -> { 'text3'} -> insert( undef, undef, undef, $_ );
	}
	@line = undef;

} # End of sub on_string_load_clicked

sub on_default_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	$form -> {'text3'} -> set_point( 0 );
	$form -> {'text3'} -> forward_delete( $form -> {'text3'} -> get_length() );
	$form -> {'text3'} -> insert( undef, undef, undef, "這是第一行的測試\n這是第二行的測試");

} # End of sub on_default_clicked

sub on_stringwritetofile_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};
	
	my ( $path, $suite, $ll, $len );
	$path = $form -> { 'combo-entry12' } -> get_text();

	#read number of string
	&main::sendout( 'rdstl' . "\015" );
	$ll = &main::get_res();
	&main::get_res();

	$len = &main::decode( substr( $ll, 1 ) );

	open FILE,'> ' . $path;

	#scan all plu wheather if exist the value have set.
	for( $suite = 0; $suite < $len; $suite++ )
	{
		&main::sendout('rdstr' . &main::encode( $suite, 2 ) . "\015");
		$ll = &main::get_res();
		&main::get_res();
		
		$ll = substr($ll,1);
		print FILE $suite . ' ' . length( $ll ) / 2 . ' ' . $ll . "\n";
	}
	close FILE;

}

sub on_stringwritetoscale_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	my ( $path, $line, @subopn );

	$path = $form -> { 'combo-entry12' } -> get_text();

	open FILE , '< ' . $path;

	while( $line = <FILE> )
	{
		chomp( $line );
		@subopn = split( /\s+/, $line );
		&main::sendout('wrstr' . &main::encode($subopn[0],2) . &main::encode($subopn[1],2) . $subopn[2] . "\015");
		&main::get_res();
	}
	close FILE;
}

sub on_browse_clicked {
	my ($class, $data, $object, $instance, $event) = @_;
	my $form = $__PACKAGE__::all_forms->{$instance};

	fileselection1 -> app_run;
	$form -> {'combo-entry12'} -> set_text( $filename );
	$filename = undef;

} # End of sub on_browse_clicked

#==============================================================================
#=== This is the 'about' class
#==============================================================================
package about;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;
} # End of sub BEGIN

sub app_run {
	my ($class, %params) = @_;
	$class->load_translations('print_scale');
	 # You can use the line below to load a test .mo file before it is installed in
	 # the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	 $class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;
	$window->TOPLEVEL->show;

	 # Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'about' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'about' class
#==============================================================================
sub on_about_button_clicked {&destroy_Form;} # End of sub on_about_button_clicked
sub on_about_delete_event {&destroy_Form;} # End of sub on_about_delete_event





#==============================================================================
#=== This is the 'sysinfo' class
#==============================================================================
package sysinfo;
require 5.000; use strict 'vars', 'refs', 'subs';
#==============================================================================

BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	use Gnome;
} # End of sub BEGIN

sub app_run {

	my ($class, %params) = @_;
	my( $serial, $prog_no, $ctrl_board, $cur_user, $weight , $result );

	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/print_scale.mo)
#	 $class->load_translations('print_scale', 'test', undef, '/home/allways/Projects/print_scale/ppo/print_scale.mo');
	Gnome->init("$PACKAGE", "$VERSION");
	my $window = $class->new;

	$weight = $window -> lookup_widget( 'label13');
	$serial = $window -> lookup_widget( 'label9');
	$prog_no = $window -> lookup_widget( 'label10');
	$ctrl_board = $window -> lookup_widget( 'label11');
	$cur_user = $window -> lookup_widget( 'label12');


	&main::sendout('rdwgt' . "\015");
	$result = &main::get_res();
	&main::get_res();
	( $result =~ /^\@/ ) && $weight -> set( $weight -> get() . ( &main::decode( substr( $result, 1 ) ) ) . "Kg");

	&main::sendout('rdsno' . "\015");
	$result = &main::get_res();
	&main::get_res();
	( $result =~ /^\@/ ) && $serial -> set( $serial -> get() . ( &main::decode( substr( $result, 1 ) ) ) );

	&main::sendout('rdpno' . "\015");
	$result = &main::get_res();
	&main::get_res();
	( $result =~ /^\@/ ) && $prog_no -> set( $prog_no -> get() . ( &main::decode( substr( $result, 1 ) ) ) );

	&main::sendout('rdcno' . "\015");
	$result = &main::get_res();
	&main::get_res();
	( $result =~ /^\@/ ) && $ctrl_board -> set( $ctrl_board -> get() . ( &main::decode( substr( $result, 1 ) ) ) );

	&main::sendout('rdcur' . "\015");
	$result = &main::get_res();
	&main::get_res();
	( $result =~ /^\@/ ) && $cur_user -> set( $cur_user -> get() . ( &main::decode( substr( $result, 1 ) ) ) );

	$window->TOPLEVEL->show;

	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals

	Gtk->main;

	$window->TOPLEVEL->destroy;

	return $window;

} # End of sub app_run

#===============================================================================
#=== Below are the default signal handlers for 'sysinfo' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#==============================================================================
#=== Below are the signal handlers for 'sysinfo' class
#==============================================================================
sub on_sysinfo_delete_event {&destroy_Form;} # End of sub on_sysinfo_delete_event

#===================================================================
#=== This is the 'main' class
#==============================================================================
package main;
require 5.000; use strict 'vars', 'refs', 'subs';
our( $port, $addr );
#==============================================================================
BEGIN {
	use src::print_scaleUI;
	# We need the Gnome bindings as well
	#use Gnome;

	use Socket;
	use IO::Handle;
	use Fcntl;

} # End of sub BEGIN

END {
	#sendout('lo' . "\015"); close SOCK;
}
sub app_run {
	my ($class, %params) = @_;
	Gtk->set_locale();
	$class->load_translations('print_scale');
	# You can use the line below to load a test .mo file before it is installed in
	# # the normal place (eg /usr/local/share/locale/zh_TW.Big5/LC_MESSAGES/Test.mo)
	# #	 $class->load_translations('Test', 'test', undef, '/home/allways/Projects/test/ppo/Test.mo');


	#Gnome->init("$PACKAGE", "$VERSION");
	Gtk -> init;
	my $window = $class->new;

	$window -> FORM -> { 'item3' } -> set_sensitive( 0 );
	$window -> lookup_widget( 'entry2' ) -> set_text("192.168.1.190");

	my ( $flags, $line, $proto, $iname, $lport, $oprnd, $scmd, $lport );

	$| = 1;
	$flags = fcntl(STDIN,F_GETFL,0);
	fcntl(STDIN,F_SETFL,$flags | O_NONBLOCK);
	$flags = fcntl(STDOUT,F_GETFL,0);
	fcntl(STDOUT,F_SETFL,$flags | O_SYNC);

	*lport = 0;
	$proto = getprotobyname('udp');
	socket(SOCK,PF_INET,SOCK_DGRAM,$proto) || die "socket: $!";
	$iname = sockaddr_in($lport,INADDR_ANY) || die "sockaddr_in: $!";
	bind(SOCK,$iname) || die "bind: $!";
	$flags = fcntl(SOCK,F_GETFL,0);
	fcntl(SOCK,F_SETFL,$flags | O_NONBLOCK);

	my ( $oprnd, $scmd, $username_length, $password_length, $result );

	$addr = inet_aton( $window -> lookup_widget( 'entry2' ) -> get_text() );
	$port = 0xabcd;

	*username_length = \10;
	*password_length = \8;
	$scmd = undef;
	$oprnd = undef;
	$scmd = pack 'a' . $username_length,$scmd;
	$oprnd = pack 'a' . $password_length,$oprnd;
	sendout('lg' . $scmd . $oprnd . "\015");
	$result = get_res();
	if( $result =~ m/0/ )
	{
		$window -> lookup_widget( 'item3' ) -> set_sensitive( 1 );
		$window -> lookup_widget( 'login' ) -> set_sensitive( 0 );
	}
	else
	{
		sendout( 'lo' . "\015" );
		get_res();
		sendout('lg' . $scmd . $oprnd . "\015");
		$result = get_res();
		$window -> lookup_widget( 'item3' ) -> set_sensitive( 1 );
		$window -> lookup_widget( 'login' ) -> set_sensitive( 0 );
	}

	$window->TOPLEVEL->show;
	# Put any extra UI initialisation (eg signal_connect) calls here

	# Now let Gtk handle signals
	Gtk->main;
	$window->TOPLEVEL->destroy;
	return $window;
} # End of sub app_run
#===============================================================================
#=== Below are the default signal handlers for 'main' class
#===============================================================================
sub destroy_Form {my ($class, $data, $object, $instance) = @_;	Gtk->main_quit;} # End of sub destroy_Form
#=====================================
#=== Below are the signal handlers for 'main' class
#===============================================================================

sub on_login_activate {

=cut
	my ( $oprnd, $scmd, $username_length, $password_length, $lport, $address );

	$address = $glade -> lookup_widget( 'entry2' ) -> get_text();

	$addr = inet_aton( $address );
	$port = 0xabcd;

	*username_length = \10;
	*password_length = \8;
	*lport = 0;

	$scmd = undef;
	$oprnd = undef;
	$scmd = pack 'a' . $username_length,$scmd;
	$oprnd = pack 'a' . $password_length,$oprnd;
	sendout('lg' . $scmd . $oprnd . "\015");


	$glade -> FORM -> {'logout'}  -> set_sensitive( 1 );
	$glade -> FORM -> { 'item3' } -> set_sensitive( 1 );
	$glade -> FORM -> {'login'}  -> set_sensitive( 0 );
=cut

} # End of sub on_login_activate

sub on_plu_activate {plu -> app_run;} # End of sub on_plu_activate
sub on_system_activate {sysinfo -> app_run;} # End of sub on_system_activate
sub on_date_activate {date -> app_run;} # End of sub on_date_activate
sub on_label_activate {label -> app_run;} # End of sub on_label_activate
sub on_string_activate {string -> app_run;} # End of sub on_string_activate
sub on_main_delete_event {sendout('lo' . "\015"); get_res(); close SOCK; &destroy_Form;} # End of sub on_main_delete_event
sub on_about_activate {about -> app_run;} # End of sub on_about_activate
sub on_exit_activate {&on_main_delete_event} # End of sub on_exit_activate
sub on_print_format_activate {print_format -> app_run;} # End of sub on_print_format_activate

# the subroutine under this line is my creation

sub sendout
{
	my ($str);
	($str) = @_;
	send(SOCK,$str,0,sockaddr_in($port,$addr));
	#print "#\n";
}

sub encode
{
	my($c,$l,$inp,$i,$rr);

	($c,$l) = @_;
	$inp = '';
	for($i = 0;$i < $l;$i++)
	{
		$inp .= chr(($c & 0xf) + ord('A'));
		$c >>= 4;
	}
	$rr = '';
	for($i = $l - 1;$i >= 0;$i--)
	{
		$rr .= substr($inp,$i,1);
	}
	return $rr;
}

sub decode	        # 2 chars
{
	my($i,$c,$inp,$cc);
	($inp) = @_;
	for($c = 0,$i = 0;$i < length($inp);$i++)
	{
		$cc = substr($inp,$i,1);
		if(ord($cc) <= ord('P') && ord($cc) >= ord('A'))
		{
			$c <<= 4;
			$c += ord($cc) - ord('A');
		}
	}
	return $c;
}

sub get_res	  # get result
{
	my($ln,$ll);
	$ll = undef;
	while(1)
	{
		if( defined( $ln = <SOCK>) )
		{
			$ln =~ s/\015/\012/g;
			$ll .= $ln;
			if(substr($ln,-1,1) eq "\n")
			{ last; }
		}
	}
	chomp($ll);
	return $ll;
}

1;

__END__

#===============================================================================
#==== Documentation
#===============================================================================
=pod

=head1 NAME

Test - version 0.01 週五 10月 25 10:31:11 CST 2002

No description

=head1 SYNOPSIS

 use Test;

 To construct the window object and show it call

 Gtk->init;
 my $window = window1->new;
 $window->TOPLEVEL->show;
 Gtk->main;

 OR use the shorthand for the above calls

 window1->app_run;

=head1 DESCRIPTION

Unfortunately, the author has not yet written any documentation :-(

=head1 AUTHOR

 <allways@allways.taipei.excell.com.tw>

=cut
