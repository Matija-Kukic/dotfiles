# Install script for directory: /home/matijak/dotfiles/.config/quickshell/plugin/src/Caelestia

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so"
         RPATH [[$ORIGIN:$ORIGIN/../lib64]])
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Caelestia/lib/libcaelestia-core.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Caelestia/lib" TYPE SHARED_LIBRARY FILES "/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/libcaelestia-core.so")
  if(EXISTS "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so"
         OLD_RPATH "::::::::::::::::::::::::"
         NEW_RPATH [[$ORIGIN:$ORIGIN/../lib64]])
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/Caelestia/lib/libcaelestia-core.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so"
         RPATH [[$ORIGIN:$ORIGIN/../lib64:$ORIGIN/lib]])
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Caelestia/libcaelestia-coreplugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Caelestia" TYPE MODULE FILES "/home/matijak/dotfiles/.config/quickshell/plugin/build/qml/Caelestia/libcaelestia-coreplugin.so")
  if(EXISTS "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so"
         OLD_RPATH "/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia:"
         NEW_RPATH [[$ORIGIN:$ORIGIN/../lib64:$ORIGIN/lib]])
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/Caelestia/libcaelestia-coreplugin.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Caelestia/qmldir")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Caelestia" TYPE FILE FILES "/home/matijak/dotfiles/.config/quickshell/plugin/build/qml/Caelestia/qmldir")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Caelestia/caelestia-core.qmltypes")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Caelestia" TYPE FILE FILES "/home/matijak/dotfiles/.config/quickshell/plugin/build/qml/Caelestia/caelestia-core.qmltypes")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Components/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Config/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Internal/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Models/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Services/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Blobs/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/Images/cmake_install.cmake")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/matijak/dotfiles/.config/quickshell/plugin/build/src/Caelestia/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
