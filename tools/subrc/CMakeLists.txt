cmake_minimum_required(VERSION 3.10)
cmake_policy(VERSION 3.10)
project(subrc LANGUAGES C CXX VERSION 1.0.0)

find_package(Threads)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.11)
    #include(FetchContent)
endif()

# Convenience macros to fetch a github repo.
# Use as if FetchContent (roughly)
macro(FetchGitHub name owner_name tag)
    set(fetchgithub_dir "${CMAKE_BINARY_DIR}/_fetchgithub")
    string(REGEX REPLACE "^.+/" "" ${name}_repository ${owner_name})
    set(${name}_url "https://github.com/${owner_name}")
    message(STATUS "${${name}_repo}")
    if(COMMAND FetchContent_Declare)    
        FetchContent_Declare(
            ${name}
            GIT_REPOSITORY "${${name}_url}" 
            GIT_TAG "${tag}"
        )
        FetchContent_GetProperties(${name})
    else()
        set(${name}_tgz "${fetchgithub_dir}/_downloads/${name}.tar.gz")
        
        set(${name}_POPULATED FALSE)
        if(NOT EXISTS "${${name}_tgz}")
            file(DOWNLOAD "${${name}_url}/archive/refs/tags/${tag}.tar.gz" "${${name}_tgz}" TIMEOUT 60 TLS_VERIFY ON)
            execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xzf "${${name}_tgz}" WORKING_DIRECTORY "${fetchgithub_dir}")
            # GitHub takes some liberties with renaming the tag (ie v1.10 -> 1.10)
            file(GLOB ${name}_github_mangled LIST_DIRECTORIES true RELATIVE "${fetchgithub_dir}" "${fetchgithub_dir}/${${name}_repository}-*")
            message(STATUS "${fetchgithub_dir}/${${name}_repository}-* ${${name}_github_mangled}")
            execute_process(COMMAND ${CMAKE_COMMAND} -E rename "${${name}_github_mangled}" "${name}" WORKING_DIRECTORY "${fetchgithub_dir}")
        endif()

        set(${name}_SOURCE_DIR "${fetchgithub_dir}/${name}")
        set(${name}_BINARY_DIR "${PROJECT_BINARY_DIR}/_fetchgithub/${name}")
    endif()
endmacro()

macro(FetchGitHub_Populate name)
    if(NOT ${name}_POPULATED AND COMMAND FetchContent_Populate)
        FetchContent_Populate(${name})
    endif()
endmacro()

FetchGitHub(basisu binomialllc/basis_universal v1_15_update2)
if(NOT basisu_POPULATED)
    FetchGitHub_Populate(basisu)

    # As of 1.15, basis is not setup to be used as a library.
    # So roll our own based on its CMakeLists.txt.
    # We want two things: 
    #   * an encoder library (texture reprocessing), to be used by consumer projects.
    #   * the transcoder (runtime usage).
    add_library(basisu-encoder STATIC
        "${basisu_SOURCE_DIR}/encoder/basisu_backend.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_basis_file.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_comp.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_enc.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_etc.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_frontend.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_global_selector_palette_helpers.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_gpu_texture.cpp"
        "${basisu_SOURCE_DIR}/encoder/basisu_pvrtc1_4.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_resampler.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_resample_filters.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_ssim.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_astc_decomp.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_uastc_enc.cpp"
        "${basisu_SOURCE_DIR}/encoder/basisu_bc7enc.cpp"
	    "${basisu_SOURCE_DIR}/encoder/lodepng.cpp"
	    "${basisu_SOURCE_DIR}/encoder/apg_bmp.c"
	    "${basisu_SOURCE_DIR}/encoder/jpgd.cpp"
	    "${basisu_SOURCE_DIR}/encoder/basisu_kernels_sse.cpp"
	    "${basisu_SOURCE_DIR}/transcoder/basisu_transcoder.cpp"
        "${basisu_SOURCE_DIR}/zstd/zstd.c"
     )
    target_include_directories(basisu-encoder INTERFACE "${basisu_SOURCE_DIR}")
    target_link_libraries(basisu-encoder PUBLIC Threads::Threads)
    target_compile_definitions(basisu-encoder
        PRIVATE
            BASISD_SUPPORT_KTX2_ZSTD=1
            BASISU_SUPPORT_SSE=0
            "$<$<NOT:$<CXX_COMPILER_ID:MSVC>>:_LARGEFILE64_SOURCE=1;_FILE_OFFSET_BITS=64>"
            "$<$<CXX_COMPILER_ID:MSVC>:BASISU_NO_ITERATOR_DEBUG_LEVEL>"
    )
    target_compile_options(basisu-encoder
        PRIVATE
            "$<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-fvisibility=hidden;-fPIC;-fno-strict-aliasing;-Wall;-Wextra;-Wno-unused-local-typedefs;-Wno-unused-value;-Wno-unused-parameter;-Wno-unused-variable>"
    )
    target_compile_features(basisu-encoder PUBLIC cxx_std_11)
endif()

FetchGitHub(meshoptimizer zeux/meshoptimizer v0.16)
if(NOT meshoptimizer_POPULATED)
    FetchGitHub_Populate(meshoptimizer)
    add_subdirectory(${meshoptimizer_SOURCE_DIR} ${meshoptimizer_BINARY_DIR})
endif()

# Single/two-file libs
add_library(externals STATIC
    # https://github.com/nothings/stb/
    externals/stb_image.h

    # https://github.com/thisistherk/fast_obj/
    externals/fast_obj.h

    # https://github.com/emilk/loguru/
    externals/loguru.hpp externals/loguru.cpp)

target_include_directories(externals INTERFACE externals/ PRIVATE .)
target_compile_features(externals PUBLIC cxx_std_17)

# Loguru requirements.
target_link_libraries(externals PUBLIC Threads::Threads ${CMAKE_DL_LIBS})

add_executable(${PROJECT_NAME}
    src/main.cpp
    src/packBuilder.h src/packBuilder.cpp
    src/assetProcessor.h src/assetProcessor.cpp
    src/imageProcessor.h src/imageProcessor.cpp
    src/modelProcessor.h src/modelProcessor.cpp
    src/io.h src/log.h
)
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_BINARY_DIR}/single_files")
target_compile_definitions(${PROJECT_NAME} PUBLIC "$<$<CXX_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>")
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)
target_link_libraries(${PROJECT_NAME} meshoptimizer externals basisu-encoder)

install(TARGETS subrc)
