#!/usr/bin/perl6

use NativeCall;

class cef_main_args_t is repr('CStruct') {
    has int32 $.argc is rw;
    has CArray[Str] $.argv is rw;

    submethod BUILD(:@args) {
        $!argc = @args.elems;
        $!argv := CArray[Str].new(@args);
    }
}

class SizedStruct is repr('CStruct') {
    has size_t $.size is rw;

    submethod BUILD {
        $!size = nativesizeof(self);
    }
}

class cef_base_t is SizedStruct is repr('CStruct') {
    has Pointer[void] $.add_ref is rw;
    has Pointer[void] $.release is rw;
    has Pointer[void] $.has_one_ref is rw;
}
class cef_app_t is cef_base_t is repr('CStruct') {
    # TODO callbacks
    has Pointer[void] $.on_before_command_line_processing is rw;
    has Pointer[void] $.on_register_custom_schemes is rw;
    has Pointer[void] $.get_resource_bundle_handler is rw;
    has Pointer[void] $.get_browser_process_handler is rw;
    has Pointer[void] $.get_render_process_handler is rw;
}


# For some crazy reason, chromium allows switching internal string representations.
# For some even crazier reason, it uses UTF-16 by default.
class cef_string_utf16_t is repr('CStruct') {
    has CArray[uint16] $.str;
    has size_t $.length;
    has Pointer[void] $.dtor; # function pointer

    method new($s = Nil) {
        my $obj = nextwith();
        $obj.set: $s if $s.defined;
        $obj;
    }

    method set($s) {
        say "SET '$s'";
        my $utf = $s.encode('utf-16');
        $!str := CArray[uint16].new($utf);
        $!length = $utf.elems;
    }
};
class cef_string_t is cef_string_utf16_t is repr('CStruct') {}

sub cef_string_utf16_set(CArray[uint16] $src, size_t $src_len,
                                    cef_string_utf16_t $output, int32 $copy --> int32) { * }

constant LOGSEVERITY_VERBOSE = 1;

# include/internal/cef_types.h
class cef_settings_t is SizedStruct is repr('CStruct') {
    has int32 $.single_process is rw;
    has int32 $.no_sandbox is rw;
    HAS cef_string_t $.browser_subprocess_path is rw;
    HAS cef_string_t $.framework_dir_path is rw;
    has int32 $.multi_threaded_message_loop is rw;
    has int32 $.external_message_pump is rw;
    has int32 $.windowless_rendering_enabled is rw;
    has int32 $.command_line_args_disabled is rw;
    HAS cef_string_t $.cache_path is rw;
    HAS cef_string_t $.user_data_path is rw;
    has int32 $.persist_session_cookies is rw;
    has int32 $.persist_user_preferences is rw;
    HAS cef_string_t $.user_agent is rw;
    HAS cef_string_t $.product_version is rw;
    HAS cef_string_t $.locale is rw;
    HAS cef_string_t $.log_file is rw;
    has int32 $.log_severity is rw = LOGSEVERITY_VERBOSE;
    HAS cef_string_t $.javascript_flags is rw;
    HAS cef_string_t $.resources_dir_path is rw;
    HAS cef_string_t $.locales_dir_path is rw;
    has int32 $.pack_loading_disabled is rw;
    has int32 $.remote_debugging_port is rw;
    has int32 $.uncaught_exception_stack_size is rw;
    has int32 $.context_safety_implementation is rw;
    has int32 $.ignore_certificate_errors is rw;
    has int32 $.enable_net_security_expiration is rw;
    has uint32 $.background_color is rw;
    HAS cef_string_t $.accept_language_list is rw;

    submethod BUILD {
        $!browser_subprocess_path := cef_string_t.new;
    }
}

class cef_client_t is cef_base_t is repr('CStruct') {
    has Pointer[void] $.get_context_menu_handler is rw;
    has Pointer[void] $.get_dialog_handler is rw;
    has Pointer[void] $.get_display_handler is rw;
    has Pointer[void] $.get_download_handler is rw;
    has Pointer[void] $.get_drag_handler is rw;
    has Pointer[void] $.get_find_handler is rw;
    has Pointer[void] $.get_focus_handler is rw;
    has Pointer[void] $.get_geolocation_handler is rw;
    has Pointer[void] $.get_jsdialog_handler is rw;
    has Pointer[void] $.get_keyboard_handler is rw;
    has Pointer[void] $.get_life_span_handler is rw;
    has Pointer[void] $.get_load_handler is rw;
    has Pointer[void] $.get_render_handler is rw;
    has Pointer[void] $.get_request_handler is rw;
    has Pointer[void] $.on_process_message_received is rw;
}


class cef_window_info_t is repr('CStruct') {
    has uint32 $.x is rw;
    has uint32 $.y is rw;
    has uint32 $.width is rw;
    has uint32 $.height is rw;
    has uint64 $.parent_window is rw;
    has int32 $.windowless_rendering_enabled is rw;
    has int32 $.transparent_painting_enabled is rw;
    has uint64 $.window is rw;
};

class cef_request_context_t is cef_base_t is repr('CStruct') {
    has Pointer[void] $.is_same is rw;
    has Pointer[void] $.is_sharing_with is rw;
    has Pointer[void] $.is_global is rw;
    has Pointer[void] $.get_handler is rw;
    has Pointer[void] $.get_cache_path is rw;
    has Pointer[void] $.get_default_cookie_manager is rw;
    has Pointer[void] $.register_scheme_handler_factory is rw;
    has Pointer[void] $.clear_scheme_handler_factories is rw;
    has Pointer[void] $.purge_plugin_list_cache is rw;
    has Pointer[void] $.has_preference is rw;
    has Pointer[void] $.get_preference is rw;
    has Pointer[void] $.get_all_preferences is rw;
    has Pointer[void] $.can_set_preference is rw;
    has Pointer[void] $.set_preference is rw;
    has Pointer[void] $.clear_certificate_exceptions is rw;
    has Pointer[void] $.close_all_connections is rw;
    has Pointer[void] $.resolve_host is rw;
    has Pointer[void] $.resolve_host_cached is rw;
}

subset cef_state_t of int32;

class cef_browser_settings_t is SizedStruct is repr('CStruct') {
    has int32 $.windowless_frame_rate is rw;
  
    HAS cef_string_t $.standard_font_family is rw;
    HAS cef_string_t $.fixed_font_family is rw;
    HAS cef_string_t $.serif_font_family is rw;
    HAS cef_string_t $.sans_serif_font_family is rw;
    HAS cef_string_t $.cursive_font_family is rw;
    HAS cef_string_t $.fantasy_font_family is rw;
    has int32 $.default_font_size is rw;
    has int32 $.default_fixed_font_size is rw;
    has int32 $.minimum_font_size is rw;
    has int32 $.minimum_logical_font_size is rw;
    HAS cef_string_t $.default_encoding is rw;
    has int32 $.remote_fonts is rw;
    has int32 $.javascript is rw;
    has int32 $.javascript_open_windows is rw;
    has int32 $.javascript_close_windows is rw;
    has int32 $.javascript_access_clipboard is rw;
    has int32 $.javascript_dom_paste is rw;
    has int32 $.plugins is rw;
    has int32 $.universal_access_from_file_urls is rw;
    has int32 $.file_access_from_file_urls is rw;
    has int32 $.web_security is rw;
    has int32 $.image_loading is rw;
    has int32 $.image_shrink_standalone_to_fit is rw;
    has int32 $.text_area_resize is rw;
    has int32 $.tab_to_links is rw;
    has int32 $.local_storage is rw;
    has int32 $.databases is rw;
    has int32 $.application_cache is rw;
    has int32 $.webgl is rw;
    has uint32 $.background_color is rw;
    HAS cef_string_t $.accept_language_list is rw;
}

sub cef_execute_process(cef_main_args_t $args,
    cef_app_t $app, Pointer[void] $windows_sandbox_info --> int32) is native('cef') { * }
sub cef_initialize(cef_main_args_t $args,
    cef_settings_t $settings, cef_app_t $application,
    Pointer[void] $windows_sandbox_info --> int32) is native('cef') {*}
sub cef_browser_host_create_browser(
    cef_window_info_t $windowInfo, cef_client_t $client,
    cef_string_t $url, cef_browser_settings_t $settings,
    cef_request_context_t $request_context --> int32) is native('cef') { * }
sub cef_run_message_loop() is native('cef') { * }
sub cef_shutdown() is native('cef') { * }


my cef_main_args_t $args .= new(args => ($*PROGRAM-NAME, |@*ARGS));
say $args.argv.List;
say $args.argc;
my cef_app_t $app .= new;
my cef_settings_t $settings .= new;
$settings.browser_subprocess_path.set: $*PROGRAM-NAME;

say $settings.browser_subprocess_path.length;
say $settings.browser_subprocess_path.str.List;

cef_execute_process($args, $app, Pointer[void]);
cef_initialize($args, $settings, $app, Pointer[void]);

my cef_client_t $client .= new;
say $client.size;

my cef_window_info_t $win-info .= new;
my cef_browser_settings_t $browser-settings .= new;
my cef_string_utf16_t $cef-url .= new("http://www.perl6.org/");
say $cef-url.length;

cef_browser_host_create_browser($win-info, $client, $cef-url, $browser-settings, cef_request_context_t);

cef_run_message_loop;
cef_shutdown;

#$*IN.get;
