class MedFile < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "http://www.salome-platform.org/"
  url "http://files.salome-platform.org/Salome/other/med-4.0.0.tar.gz"
  sha256 "a474e90b5882ce69c5e9f66f6359c53b8b73eb448c5f631fa96e8cd2c14df004"

  depends_on "cmake" => :build
  depends_on "gcc" => :build   # for gfortan
  depends_on "freecad/freecad/swig@4.0.2" => :build
  depends_on "hdf5@1.10"
  depends_on "freecad/freecad/python3.9"

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any
    sha256 "ca67562c163ebe38f3338ebe644851d2102b946e406271d967aeab9d047320ad" => :big_sur
    sha256 "d66199bb1cbd71baf8f17bbef258fe64f02fe6f7cfc21427555f3c5b31297e1d" => :catalina
  end

  def install

    python_prefix=`#{Formula["freecad/freecad/python3.9"].opt_bin}/python3-config --prefix`.chomp
    python_include=Dir["#{python_prefix}/include/*"].first

    #ENV.cxx11
    system "cmake", ".", "-DMEDFILE_BUILD_PYTHON=ON",
                         "-DMEDFILE_BUILD_TESTS=OFF",
                         "-DMEDFILE_INSTALL_DOC=OFF",
                         "-DPYTHON_INCLUDE_DIR=#{python_include}",
                         *std_cmake_args
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/medimport 2>&1", 255).chomp
    assert_match output, "Nombre de parametre incorrect : medimport filein [fileout]"
    (testpath/"test.c").write <<~EOS
      #include <med.h>
      int main() {
        med_int major, minor, release;
        return MEDlibraryNumVersion(&major, &minor, &release);
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-I#{Formula["hdf5"].opt_include}",
                   "-L#{lib}", "-lmedC", "-o", "test"
    system "./test"
  end
end

