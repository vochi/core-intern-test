set(OCV_DIR ${3RD_SRC_DIR}/opencv)
set(OCV_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/opencv-build)
set(OCV_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/opencv-installation)

set(OCV_INCLUDE_DIR ${OCV_INSTALL_DIR}/include)
set(OCV_LIBS_DIR ${OCV_INSTALL_DIR}/x64/vc16/staticlib)

if(WIN_PREFIX STREQUAL Debug)
    set(OCV_WORLD_LIB ${OCV_LIBS_DIR}/opencv_world430d.lib)
else()
    set(OCV_WORLD_LIB ${OCV_LIBS_DIR}/opencv_world430.lib)
endif()

if(WIN_PREFIX STREQUAL Debug)
    set(OPENCV_3RD_LIBS
        ${OCV_LIBS_DIR}/ade.lib
        ${OCV_LIBS_DIR}/IlmImfd.lib
        ${OCV_LIBS_DIR}/libjasperd.lib
        ${OCV_LIBS_DIR}/libjpeg-turbod.lib
        ${OCV_LIBS_DIR}/libpngd.lib
        ${OCV_LIBS_DIR}/libtiffd.lib
        ${OCV_LIBS_DIR}/libwebpd.lib
        ${OCV_LIBS_DIR}/quircd.lib
        ${OCV_LIBS_DIR}/zlibd.lib
    )
else()
    set(OPENCV_3RD_LIBS
        ${OCV_LIBS_DIR}/ade.lib
        ${OCV_LIBS_DIR}/IlmImf.lib
        ${OCV_LIBS_DIR}/libjasper.lib
        ${OCV_LIBS_DIR}/libjpeg-turbo.lib
        ${OCV_LIBS_DIR}/libpng.lib
        ${OCV_LIBS_DIR}/libtiff.lib
        ${OCV_LIBS_DIR}/libwebp.lib
        ${OCV_LIBS_DIR}/quirc.lib
        ${OCV_LIBS_DIR}/zlib.lib
    )
endif()

include(ExternalProject)

set(OCV_ADDITIONAL_PARAMS -DCMAKE_CXX_FLAGS_RELEASE="/MT" -DCMAKE_CXX_FLAGS_DEBUG="/MTd")

ExternalProject_Add(build-opencv
  SOURCE_DIR ${OCV_DIR}
  BINARY_DIR ${OCV_BIN_DIR}
  INSTALL_DIR ${OCV_INSTALL_DIR}
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  BUILD_BYPRODUCTS ${OCV_WORLD_LIB}
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${OCV_INSTALL_DIR}
    -DBUILD_opencv_world=ON
    -DCPU_BASELINE=SSE2,SSE4_2,AVX,AVX2
    -DCPU_DISPATCH=SSE2,SSE4_2,AVX,AVX2
    -DCPU_BASELINE_REQUIRE=SSE2
    -DOPENCV_EXTRA_MODULES_PATH=${3RD_SRC_DIR}/opencv_contrib/modules
    ${OCV_ADDITIONAL_PARAMS}
    -DENABLE_CXX_11=ON

    -DBUILD_LIST=core,imgproc,video,videoio,videostab,flann,features2d,calib3d,highgui,ximgproc
    -DBUILD_opencv_highgui=OFF
    -DOPENCV_FORCE_3RDPARTY_BUILD=ON

    -DWITH_EIGEN=ON

    -DWITH_PROTOBUF=OFF
    -DWITH_ITT=OFF
    -DWITH_FFMPEG=OFF
    -DWITH_QT=OFF
    -DWITH_GTK=OFF
    -DWITH_GSTREAMER=OFF
    -DWITH_GTK=OFF
    -DWITH_AVFOUNDATION=OFF
    -DWITH_IPP=OFF
    -DWITH_LAPACK=OFF
    -DWITH_OPENCL=OFF
    -DWITH_CAROTENE=OFF

    -DBUILD_ANDROID_PROJECTS=OFF
    -DBUILD_ANDROID_EXAMPLES=OFF
    -DBUILD_SHARED_LIBS=OFF
    -DBUILD_TESTS=OFF
    -DBUILD_PERF_TESTS=OFF
    -DBUILD_DOCS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_NEW_PYTHON_SUPPORT=OFF
    -DBUILD_WITH_DEBUG_INFO=OFF
    -DBUILD_PACKAGE=OFF
    -DBUILD_FAT_JAVA_LIB=OFF
)

add_library(opencv STATIC IMPORTED)
set_property(TARGET opencv PROPERTY IMPORTED_LOCATION ${OCV_WORLD_LIB})
target_link_libraries(opencv INTERFACE ${OPENCV_3RD_LIBS})
add_dependencies(opencv build-opencv)

include_directories(${OCV_INCLUDE_DIR})
set(OPENCV_LIBS opencv ${OPENCV_3RD_LIBS})

add_definitions(-DOCV_CONTRIB_AVAILABLE)
