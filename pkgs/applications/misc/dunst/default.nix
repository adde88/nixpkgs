{ stdenv, lib, fetchFromGitHub, makeWrapper
, pkg-config, which, perl, libXrandr
, cairo, dbus, systemd, gdk-pixbuf, glib, libX11, libXScrnSaver
, wayland, wayland-protocols
, libXinerama, libnotify, pango, xorgproto, librsvg
}:

stdenv.mkDerivation rec {
  pname = "dunst";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "dunst-project";
    repo = "dunst";
    rev = "v${version}";
    sha256 = "sha256-BWbvGetXXCXbfPRY+u6gEfzBmX8PLSnI6a5vfCByiC0=";
  };

  nativeBuildInputs = [ perl pkg-config which systemd makeWrapper ];

  buildInputs = [
    cairo dbus gdk-pixbuf glib libX11 libXScrnSaver
    libXinerama libnotify pango xorgproto librsvg libXrandr
    wayland wayland-protocols
  ];

  outputs = [ "out" "man" ];

  makeFlags = [
    "PREFIX=$(out)"
    "VERSION=$(version)"
    "SYSCONFDIR=$(out)/etc"
    "SERVICEDIR_DBUS=$(out)/share/dbus-1/services"
    "SERVICEDIR_SYSTEMD=$(out)/lib/systemd/user"
  ];

  postInstall = ''
    wrapProgram $out/bin/dunst \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';

  meta = with lib; {
    description = "Lightweight and customizable notification daemon";
    homepage = "https://dunst-project.org/";
    license = licenses.bsd3;
    # NOTE: 'unix' or even 'all' COULD work too, I'm not sure
    platforms = platforms.linux;
    maintainers = with maintainers; [ domenkozar ];
  };
}
