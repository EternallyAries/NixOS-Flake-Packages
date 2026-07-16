{ lib, fetchurl, appimageTools }:

let
  pname = "rmg-k";
  version = "0.9.8";

  src = fetchurl {
    url = "https://github.com/Jay-Day/RMG-K/releases/download/v${version}/RMG-K-Portable-Linux64-v${version}.AppImage";
    hash = "sha256-tG9TzwnwtbU7wL5dCOdK/nyTyaMp2AEIPQUSvabg+SI=";
  };

  extracted = appimageTools.extractType2 { inherit pname version src; };

in
appimageTools.wrapType2 {
  inherit pname version src;

  meta = with lib; {
    description = "Rosalie's Mupen GUI with Kaillera netplay support (N64 frontend)";
    homepage = "https://github.com/Jay-Day/RMG-K";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = pname;
  };

  extraPkgs = pkgs: with pkgs; [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwebsockets
    sdl3
    vulkan-loader
    freetype
    libpng
    libusb1
    hidapi
    libsamplerate
    speexdsp
    minizip
    zlib
    libGL
    libx11
    libxcb
    libxi
    libxrandr
    libxinerama
    libxcursor
  ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/256x256/apps
    mkdir -p $out/share/icons/hicolor/scalable/apps

    # Install icons as "rmg-k" to avoid collision with upstream RMG
    for f in ${extracted}/*.png; do
      [ -f "$f" ] && cp "$f" $out/share/icons/hicolor/256x256/apps/rmg-k.png
    done
    for f in ${extracted}/*.svg; do
      [ -f "$f" ] && cp "$f" $out/share/icons/hicolor/scalable/apps/rmg-k.svg
    done

    # Custom desktop entry
    cat > $out/share/applications/rmg-k.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=RMG-K
Comment=Rosalie's Mupen GUI with Kaillera netplay support
Exec=rmg-k %f
TryExec=rmg-k
Icon=rmg-k
Terminal=false
Categories=Game;Emulator;
Keywords=RMG-K;RMG;Mupen;N64;emulator;Kaillera;netplay;
MimeType=application/x-n64-rom;
EOF
  '';

  postFixup = ''
    update-desktop-database $out/share/applications
  '';
}
