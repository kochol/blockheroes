#
# project: sky heroes
#
cmake_minimum_required(VERSION 3.6)

# include the fips main cmake file
get_filename_component(FIPS_ROOT_DIR "../fips" ABSOLUTE)
include("${FIPS_ROOT_DIR}/cmake/fips.cmake")
project(block_heroes)

fips_setup(PROJECT block_heroes)

    set(CMAKE_CXX_STANDARD 17)
    
    fips_begin_app(block_heroes cmdline)

        ari_setup()
        ari_tex(assets/block.png ${texfmt})
        ari_tex(assets/menu.jpg ${texfmt})
        ari_assets()

        fips_vs_warning_level(3)
        fips_dir(cpp_src) 
        fips_files(
            main.cpp
        )

if (FIPS_ANDROID)
        link_directories(${CMAKE_SOURCE_DIR}/libs)
        fips_libs(block-heroes cari BeefRT ffi GLESv3 EGL android log)
endif()

    fips_end_app()

    ari_proj(block_heroes)

fips_finish()
