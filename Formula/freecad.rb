class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  version "0.19pre"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  stable do
    # a tested commit that builds on macos high sierra 10.13, mojave 10.14, Catalina 10.15 & BigSur 11.0
    url "https://github.com/freecad/freecad.git",
      revision: "f35d30bc58cc2000754d4f30cf29d063416cfb9e"
    version "0.19pre-dev"
  end

  bottle do
    root_url "https:/dl.bintray.com/vejmarie/freecad"
    sha256 big_sur:  "f9bc13c49a0ab3d72437dd721aa362d77638b68ad05f2bdcaeadf91b6d5e537b"
    sha256 cataline: "8ef75eb7cea8ca34dc4037207fb213332b9ed27976106fd83c31de1433c2dd29"
  end

  option "with-debug", "Enable debug build"
  option "with-macos-app", "Build MacOS App bundle"
  option "with-packaging-utils", "Optionally install packaging dependencies"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"

  depends_on "ccache" => :build
  depends_on "cmake" => :build
  depends_on "swig" => :build
  depends_on "freecad/freecad/boost@1.75.0"
  depends_on "freecad/freecad/boost-python3@1.75.0"
  depends_on "freecad/freecad/coin@4.0.0"
  depends_on "freecad/freecad/matplotlib"
  depends_on "freecad/freecad/med-file"
  depends_on "freecad/freecad/nglib"
  depends_on "freecad/freecad/opencamlib"
  depends_on "freecad/freecad/pivy"
  depends_on "freecad/freecad/pyside2"
  depends_on "freecad/freecad/pyside2-tools"
  depends_on "freecad/freecad/shiboken2"
  depends_on "freetype"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "freecad/freecad/opencascade@7.5.0"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "freecad/freecad/python3.9"
  depends_on "freecad/freecad/qt5152"
  depends_on "freecad/freecad/vtk@8.2.0"
  depends_on "webp"
  depends_on "xerces-c"

  def install
    if !File.exist?('/usr/local/lib/python3.9/site-packages/six.py')
      system "pip3", "install", "six"
    end

    # NOTE: brew clang compilers req, Xcode nowork on macOS 10.13 or 10.14
    if MacOS.version <= :mojave
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
    end

    args = std_cmake_args + %W[
      -DBUILD_QT5=ON
      -DUSE_PYTHON3=1
      -DPYTHON_EXECUTABLE=/usr/local/opt/python3.9/bin/python3
      -std=c++14
      -DCMAKE_CXX_STANDARD=14
      -DBUILD_ENABLE_CXX_STD:STRING=C++14
      -DBUILD_FEM_NETGEN=1
      -DBUILD_FEM=1
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
    ]

    args << '-DCMAKE_PREFIX_PATH="' + Formula["freecad/freecad/qt5152"].opt_prefix + "/lib/cmake;" + Formula["freecad/freecad/nglib"].opt_prefix + "/Contents/Resources;" + Formula["freecad/freecad/vtk@8.2.0"].opt_prefix + "/lib/cmake;" + Formula["freecad/freecad/opencascade@7.5.0"].opt_prefix + "/lib/cmake;"+ Formula["freecad/freecad/med-file"].opt_prefix + "/share/cmake/;" + Formula["freecad/freecad/shiboken2"].opt_prefix + "/lib/cmake;" + Formula["freecad/freecad/pyside2"].opt_prefix+ "/lib/cmake;" + Formula["freecad/freecad/coin@4.0.0"].opt_prefix+ "/lib/cmake;" + Formula["freecad/freecad/boost@1.75.0"].opt_prefix+ "/lib/cmake;" + Formula["freecad/freecad/boost-python3@1.75.0"].opt_prefix+ "/lib/cmake;"

    args << "-DFREECAD_CREATE_MAC_APP=1" if build.with? "macos-app"
    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    system "node", "install", "-g", "app_dmg" if build.with? "packaging-utils"

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
    (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
  end

  def post_install
    if !File.exist?("/usr/local/lib/python3.9/site-packages/six.py")
      system "pip3", "install", "six"
    end
    bin.install_symlink "../MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "../MacOS/FreeCADCmd" => "FreeCADCmd"
    if !File.exist?("/usr/local/Cellar/freecad/0.19pre/lib/python3.9/site-packages/homebrew-freecad-bundle.pth")
      (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/MacOS/\n"
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
