
# Compatibility
package_manager_detect() {
    elif is_command pacman; then
        PKG_MANAGER="pacman"
        UPDATE_PKG_CACHE="${PKG_MANAGER} -Sy"
        PKG_INSTALL="${PKG_MANAGER} -S --noconfirm --needed"
        PKG_REMOVE="${PKG_MANAGER} -Rns --noconfirm"
        # Arch No upgrade -s
        PKG_COUNT="true"

}

build_dependency_package(){
    elif is_command pacman; then
        # Arch: just install dependencies directly
        local str="Installing dependency packages with pacman"
        printf "  %b %s..." "${INFO}" "${str}"
        eval "${PKG_INSTALL}" curl git iproute2 sudo dialog newt
        printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${str}"

}



install_dependent_packages() {
    elif is_command pacman; then
        local str="Installing Pi-hole dependency packages with pacman"
        printf "  %b %s..." "${INFO}" "${str}"

        if eval "${PKG_INSTALL}" curl git iproute2 sudo dialog newt &>/dev/null; then
            printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${str}"
        else
            printf "%b  %b %s\\n" "${OVER}" "${CROSS}" "${str}"
            printf "  %b Error: Unable to install Pi-hole dependency packages.\\n" "${COL_RED}"
            return 1
        fi

}

