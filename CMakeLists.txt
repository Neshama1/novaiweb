cmake_minimum_required(VERSION 3.16)

project(novaiweb VERSION 0.1.6)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QT_MIN_VERSION "5.15.2")
set(KF5_MIN_VERSION "5.92.0")

set(PROJECT_URI "org.kde.${PROJECT_NAME}")
add_definitions(-DPROJECT_URI="${PROJECT_URI}")

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED COMPONENTS Core Quick Qml Widgets WebEngine)
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS I18n CoreAddons)

find_package(Qt5QuickCompiler)
set_package_properties(Qt5QuickCompiler PROPERTIES
    DESCRIPTION "Compile QML at build time"
    TYPE OPTIONAL
    )

find_package(MauiKit3)
find_package(MauiKit3 REQUIRED COMPONENTS FileBrowsing)

if(ECM_SOURCE_UNDER_VERSION_CONTROL)
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )

    # Get the latest abbreviated commit hash of the working branch
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )

    add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
    add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

else()
    add_definitions(-DGIT_COMMIT_HASH="${PROJECT_VERSION}")
    add_definitions(-DGIT_BRANCH="${CMAKE_BUILD_TYPE}")
endif()

ecm_setup_version(${PROJECT_VERSION}
    VARIABLE_PREFIX PROJECT
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/project_version.h"
    )

add_subdirectory(src)

ki18n_install(po)

install(FILES src/data/project.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR} RENAME ${PROJECT_URI}.appdata.xml)

install(FILES src/data/project.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME ${PROJECT_URI}.desktop)

install(FILES src/assets/logo.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps RENAME ${PROJECT_NAME}.svg)

#install(FILES data/org.kde.index.notifyrc DESTINATION ${KNOTIFYRC_INSTALL_DIR})

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

