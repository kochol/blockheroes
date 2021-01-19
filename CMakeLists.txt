#
# project: sky heroes
#
cmake_minimum_required(VERSION 3.6)

# include the fips main cmake file
get_filename_component(FIPS_ROOT_DIR "../fips" ABSOLUTE)
include("${FIPS_ROOT_DIR}/cmake/fips.cmake")
project(block_heroes)

fips_setup(PROJECT block_heroes)

if (FIPS_ANDROID)
    fips_begin_sharedlib(cari)
        fips_deps(
            cari_2d
            cari_core
            cari_en
            cari_gfx
            cari_gui
            cari_io
            cari_net            
        )
        fips_dir(cpp_src) 
        fips_files(
            dummy.cpp
        )
    fips_end_sharedlib()
endif()
    
    fips_begin_app(block_heroes cmdline)
    set(CMAKE_CXX_STANDARD 17)
    ari_setup()    


        ari_tex(assets/blocks.png ${texfmt})
        ari_tex(assets/menu.png ${texfmt})
        ari_assets()

        fips_vs_warning_level(3)
        fips_dir(cpp_src) 
        fips_files(
            main.cpp
        )

if (FIPS_ANDROID)
        link_directories(${CMAKE_SOURCE_DIR}/libs/android/${CMAKE_ANDROID_ARCH_ABI})
        fips_deps(cari)
        fips_libs(block-heroes curl z BeefRT ffi GLESv3 EGL android log)
endif()

    fips_end_app()

    ari_proj(block_heroes)

fips_finish()
