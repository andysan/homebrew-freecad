class Nglib < Formula
  desc "C++ Library of NETGEN's tetrahedral mesh generator"
  homepage "https://sourceforge.net/projects/netgen-mesher/"
  url "https://github.com/NGSolve/netgen.git", :using => :git, :tag => "v6.2.2007"
  version "v6.2.2007"

  depends_on "opencascade" => :required
  depends_on "cmake" => :build

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "f4983c240f1500f5a6779018ba4cf0688515f4e6c394c77b4761583aaf16820d" => :catalina
    sha256 "c950b0410951c9e9e5a42a6b99996769ff4a905e60c8105f775a31779c50359c" => :big_sur
  end

  def install
    mkdir "Build" do
     system "cmake", "-DUSE_PYTHON=OFF" , "-DUSE_GUI=OFF" , "-DUSE_OCC=ON" , *std_cmake_args , ".."
     system "make", "-j#{ENV.make_jobs}" , "install"
    end

    # The nglib installer doesn't include some important headers by default.
    # This follows a pattern used on other platforms to make a set of sub
    # directories within include/ to contain these headers.
    subdirs = ["csg", "general", "geom2d", "gprim", "include", "interface",
               "linalg", "meshing", "occ", "stlgeom", "visualization"]
    subdirs.each do |subdir|
      (include/"netgen"/subdir).mkpath
      (include/"netgen"/subdir).install Dir.glob("libsrc/#{subdir}/*.{h,hpp}")
    end
  end
end
