{ lib, mkCoqDerivation, coq, version ? null
, ssreflect
, deriving
}:
with lib;

(mkCoqDerivation {
  pname = "extructures";
  owner = "arthuraa";

  inherit version;
  defaultVersion = with versions; switch coq.coq-version [
    { case = range "8.11" "8.14"; out = "0.3.0"; }
    { case = range "8.10" "8.12"; out = "0.2.2"; }
  ] null;

  releaseRev = v: "v${v}";

  release."0.3.0".sha256 = "sha256:14rm0726f1732ldds495qavg26gsn30w6dfdn36xb12g5kzavp38";
  release."0.2.2".sha256 = "sha256:1clzza73gccy6p6l95n6gs0adkqd3h4wgl4qg5l0qm4q140grvm7";

  propagatedBuildInputs = [ ssreflect ];

  meta = {
    description = "Finite data structures with extensional reasoning";
    license = licenses.mit;
    maintainers = [ maintainers.vbgl ];
  };

}).overrideAttrs (o: {
  propagatedBuildInputs = o.propagatedBuildInputs
  ++ optional (versionAtLeast o.version "0.3.0") deriving;
})
