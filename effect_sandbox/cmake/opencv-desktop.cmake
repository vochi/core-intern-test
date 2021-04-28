include(ExternalProject)

set(OCV_DIR ${3RD_SRC_DIR}/opencv)
set(OCV_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR}/build-opencv-prefix/src/build-opencv-build)
set(OCV_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/opencv-installation)
set(OCV_INCLUDE_DIR ${OCV_INSTALL_DIR}/include/opencv4)
set(OCV_LIBS_DIR ${OCV_INSTALL_DIR}/lib)
set(OCV_3RD_LIBS_DIR ${OCV_INSTALL_DIR}/lib/opencv4/3rdparty)
set(OCV_WORLD_LIB ${OCV_LIBS_DIR}/libopencv_world.a)

if(APPLE)
    set(WITH_QT OFF)
    set(WITH_GTK OFF)
    set(WITH_GUI OFF)
else()
    set(WITH_QT OFF  CACHE BOOL "use qt5")
    set(WITH_GTK OFF  CACHE BOOL "use gtk3")
    if(WITH_QT)
        set(WITH_GTK OFF)
    endif()
    if(WITH_QT OR WITH_GTK) 
        set(WITH_GUI ON)
    else()
        set(WITH_GUI OFF)
    endif()
endif()

if(WITH_GUI) 
    add_definitions(-DGUI_AVAILABLE)
endif()

set(OPENCV_3RD_LIBS
    ${OCV_3RD_LIBS_DIR}/libIlmImf.a
    ${OCV_3RD_LIBS_DIR}/libade.a
    ${OCV_3RD_LIBS_DIR}/libittnotify.a
    ${OCV_3RD_LIBS_DIR}/liblibjasper.a
    ${OCV_3RD_LIBS_DIR}/liblibjpeg-turbo.a
    ${OCV_3RD_LIBS_DIR}/liblibpng.a
    ${OCV_3RD_LIBS_DIR}/liblibtiff.a
    ${OCV_3RD_LIBS_DIR}/liblibwebp.a
    ${OCV_3RD_LIBS_DIR}/libzlib.a
)

include(ExternalProject)

CMAKE_POLICY(SET CMP0006 OLD)
#set(CV_MODS core,imgproc,video,videoio,videostab,flann,features2d,calib3d,highgui,ximgproc)
set(CV_MODS core,imgproc,video,videoio,videostab,flann,features2d,calib3d,ximgproc)
set(CV_FLAGS -DWITH_FFMPEG=ON
    -DWITH_QT=${WITH_QT}
    -DWITH_GTK=${WITH_GTK}
    -DCPU_BASELINE=SSE2,SSE4_2,AVX,AVX2 -DCPU_DISPATCH=SSE2,SSE4_2,AVX,AVX2 -DCPU_BASELINE_REQUIRE=SSE2)
if(IOS)
    set(CV_FLAGS -DAPPLE_FRAMEWORK=ON -DENABLE_ARC=FALSE)
endif()

ExternalProject_Add(build-opencv
  SOURCE_DIR ${OCV_DIR}
  BINARY_DIR ${OCV_BIN_DIR}
  INSTALL_DIR ${OCV_INSTALL_DIR}
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  BUILD_BYPRODUCTS ${OCV_WORLD_LIB} ${OPENCV_3RD_LIBS}
  STEP_TARGETS configure
  CMAKE_ARGS
    -DCMAKE_FIND_FRAMEWORK=LAST #fix fckin macos libpng
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${OCV_INSTALL_DIR}
    -DBUILD_opencv_world=ON
    -DOPENCV_EXTRA_MODULES_PATH=${3RD_SRC_DIR}/opencv_contrib/modules
    -DENABLE_CXX_11=ON

    -DBUILD_LIST=${CV_MODS}
    -DBUILD_opencv_highgui=${WITH_GUI}
    -DWITH_EIGEN=ON
    -DOPENCV_FORCE_3RDPARTY_BUILD=ON

    -DWITH_VTK=OFF
    -DWITH_GSTREAMER=OFF
    -DWITH_AVFOUNDATION=OFF
    -DWITH_IPP=OFF
    -DWITH_LAPACK=OFF
    -DWITH_OPENCL=OFF
    -DWITH_OPENJPEG=OFF
    -DWITH_CAROTENE=OFF
    -DWITH_1394=OFF

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

    "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
    ${CV_FLAGS}
)
ExternalProject_Add_Step(build-opencv clean
  DEPENDERS configure
  COMMAND ${CMAKE_COMMAND} -E remove_directory "${OCV_INSTALL_DIR}"
  COMMAND ${CMAKE_COMMAND} -E remove_directory "${OCV_BIN_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OCV_BIN_DIR}"
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OCV_INCLUDE_DIR}"
  DEPENDS ${OCV_DIR}/modules/core/include/opencv2/core/version.hpp
)
file(MAKE_DIRECTORY ${OCV_INCLUDE_DIR}) #hack


if((NOT APPLE))
    list(APPEND OPENCV_3RD_LIBS -lz pthread dl)
endif()
if(WITH_QT)
    find_package(Qt5 COMPONENTS Widgets Test REQUIRED)
    list(APPEND OPENCV_3RD_LIBS Qt5::Widgets Qt5::Test)
elseif(WITH_GTK)
    execute_process(COMMAND pkg-config --libs gtk+-3.0
                    OUTPUT_VARIABLE GTK_LIBS
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    list(APPEND OPENCV_3RD_LIBS ${GTK_LIBS})
endif()
list(APPEND OPENCV_3RD_LIBS swscale avcodec avformat avutil avdevice)


add_library(opencv STATIC IMPORTED)
set_target_properties(opencv PROPERTIES
    IMPORTED_LOCATION ${OCV_WORLD_LIB}
    INTERFACE_INCLUDE_DIRECTORIES "${OCV_INCLUDE_DIR}")
target_link_libraries(opencv INTERFACE ${OPENCV_3RD_LIBS})
add_dependencies(opencv build-opencv)
set(OPENCV_LIBS opencv ${OPENCV_3RD_LIBS})

add_definitions(-DOCV_CONTRIB_AVAILABLE)
