# myPackge.nixjdk17_headless
{ stdenv
, buildMavenRepositoryFromLockFile
, makeWrapper
, maven
, jdk17_headless
, nix-gitignore
, ...
}:

with {
  gitsrc = builtins.fetchGit {
    url = "ssh://git@git.zsh2517.com/mutangxiang/backend.git";
    submodules = true;
    allRefs = true;
    rev = "f5b889b428e2a766f3e6b141ae2ad3e3db62714b";
  };
};
let
  mavenRepository = buildMavenRepositoryFromLockFile { file = gitsrc.outPath + "/mvn2nix-lock.json"; };
in
stdenv.mkDerivation rec {
  pname = "mutangxiang";
  version = "0.0.1-SNAPSHOT";
  name = "${pname}-${version}";
  src = gitsrc.outPath;

  nativeBuildInputs = [ jdk17_headless maven makeWrapper ];
  buildPhase = ''
    echo "Building with maven repository ${mavenRepository}"
    mvn package --offline -Dmaven.repo.local=${mavenRepository}
  '';

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a symbolic link for the lib directory
    ln -s ${mavenRepository} $out/lib

    # copy out the JAR
    # Maven already setup the classpath to use m2 repository layout
    # with the prefix of lib/
    cp target/${name}.jar $out/

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk17_headless}/bin/java $out/bin/${pname} \
          --add-flags "-jar $out/${name}.jar"
  '';
}
