{ lib
, fetchFromGitHub
, nixosTests
, python3
, python3Packages
}:

python3.pkgs.buildPythonApplication rec {
  pname = "calibre-web";
  version = "0.6.13";

  src = fetchFromGitHub {
    owner = "janeczku";
    repo = "calibre-web";
    rev = version;
    sha256 = "sha256-zU7ujvFPi4UaaEglIK3YX3TJxBME35NEKKblnJRt0tM=";
  };

  prePatch = ''
    substituteInPlace setup.cfg \
      --replace "requests>=2.11.1,<2.25.0" "requests" \
      --replace "cps = calibreweb:main" "calibre-web = calibreweb:main" \
      --replace "PyPDF3>=1.0.0,<1.0.4" "PyPDF3>=1.0.0" \
      --replace "unidecode>=0.04.19,<1.3.0" "unidecode>=0.04.19"
  '';

  patches = [
    # default-logger.patch switches default logger to /dev/stdout. Otherwise calibre-web tries to open a file relative
    # to its location, which can't be done as the store is read-only. Log file location can later be configured using UI
    # if needed.
    ./default-logger.patch
    # DB migrations adds an env var __RUN_MIGRATIONS_ANDEXIT that, when set, instructs calibre-web to run DB migrations
    # and exit. This is gonna be used to configure calibre-web declaratively, as most of its configuration parameters
    # are stored in the DB.
    ./db-migrations.patch
  ];

  # calibre-web doesn't follow setuptools directory structure. The following is taken from the script
  # that calibre-web's maintainer is using to package it:
  # https://github.com/OzzieIsaacs/calibre-web-test/blob/master/build/make_release.py
  postPatch = ''
    mkdir -p src/calibreweb
    mv cps.py src/calibreweb/__init__.py
    mv cps src/calibreweb
  '';

  # Upstream repo doesn't provide any tests.
  doCheck = false;

  propagatedBuildInputs = with python3Packages; [
    backports_abc
    flask-babel
    flask_login
    flask_principal
    iso-639
    lxml
    pypdf3
    requests
    sqlalchemy
    tornado
    unidecode
    Wand
  ];

  passthru.tests.calibre-web = nixosTests.calibre-web;

  meta = with lib; {
    description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
    maintainers = with maintainers; [ pborzenkov ];
    homepage = "https://github.com/janeczku/calibre-web";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
