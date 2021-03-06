class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "http://code.qt.io/pyside/pyside-setup.git", :using => :git, :branch => "5.15.2"
  version "5.15.2"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.15.2" 

  depends_on "cmake" => :build
  depends_on "python@3.9" => :build
  depends_on "FreeCAD/freecad/pyside2"
  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "e64630744ab15424496579a5938ed83d06f731296b750525d021c52028706e6d" => :catalina
    sha256 "90ce8404911f99539b4147e220453698ed43c33044c48d480f40fb72d6fc8954" => :big_sur
  end

  def install
      mkdir "macbuild3.9" do
        args = std_cmake_args
        args << "-DUSE_PYTHON_VERSION=3.8"
        args << "../sources/pyside2-tools"

        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}", "install"
      end
  end
end
