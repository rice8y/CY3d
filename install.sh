#!/bin/bash

TOML_FILE="package.toml"
INSTALL_SCOPE="local"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --texmflocal)
            INSTALL_SCOPE="local"
            shift
            ;;
        --texmfhome)
            INSTALL_SCOPE="home"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--texmflocal|--texmfhome]"
            echo "  --texmflocal   Install into TEXMFLOCAL (requires sudo, default)"
            echo "  --texmfhome    Install into TEXMFHOME (user local tree)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

get_value_from_toml() {
  local key="$1"
  grep "$key" "$TOML_FILE" | sed -E 's/.*= "(.*)"/\1/' | tr -d '\r'
}

detect_tex_distribution() {
    if command -v tlmgr > /dev/null 2>&1; then
        TEX_DISTRO="texlive"
    elif command -v miktex > /dev/null 2>&1; then
        TEX_DISTRO="miktex"
    else
        echo "No supported TeX distribution found"
        exit 1
    fi
}

get_texmf_path() {
    case "$TEX_DISTRO" in
        "texlive")
            if [ "$INSTALL_SCOPE" = "home" ]; then
                TEXMF_PATH=$(kpsewhich -var-value=TEXMFHOME)
            else
                TEXMF_PATH=$(kpsewhich -var-value=TEXMFLOCAL)
            fi
            ;;
        "miktex")
            TEXMF_PATH=$(miktex-console --get-settings | grep 'CommonInstall')
            ;;
    esac
}

install_package_file() {
    INSTALL_DIR="$TEXMF_PATH/tex/latex/$PACKAGE_NAME"

    if [ ! -d "$INSTALL_DIR" ]; then
        if [ "$INSTALL_SCOPE" = "home" ]; then
            mkdir -p "$INSTALL_DIR"
        else
            sudo mkdir -p "$INSTALL_DIR"
        fi
    fi

    if [ "$INSTALL_SCOPE" = "home" ]; then
        cp "$PACKAGE_FILE" "$INSTALL_DIR"
    else
        sudo cp "$PACKAGE_FILE" "$INSTALL_DIR"
    fi

    case "$TEX_DISTRO" in
        "texlive")
            if [ "$INSTALL_SCOPE" = "home" ]; then
                echo "Installed to TEXMFHOME ($TEXMF_PATH). No mktexlsr needed."
                echo "Package $PACKAGE_NAME version $PACKAGE_VERSION installed successfully!"
            else
                MK_TEXLSR_PATH=$(which mktexlsr)
                if [ -z "$MK_TEXLSR_PATH" ]; then
                    echo "mktexlsr not found or not executable."
                    exit 1
                fi
                if [ -x "$MK_TEXLSR_PATH" ]; then
                    sudo "$MK_TEXLSR_PATH"
                    echo "Package $PACKAGE_NAME version $PACKAGE_VERSION installed successfully!"
                else
                    echo "mktexlsr not found or not executable."
                    exit 1
                fi
            fi
            ;;
        "miktex")
            sudo PATH=$PATH miktex-console --update-fndb
            if [ $? -eq 0 ]; then
                echo "Package $PACKAGE_NAME version $PACKAGE_VERSION installed successfully!"
            else
                echo "Failed to update MiKTeX file database."
                exit 1
            fi
            ;;
    esac
}

main() {
    PACKAGE_NAME=$(get_value_from_toml "name")
    PACKAGE_VERSION=$(get_value_from_toml "version")
    PACKAGE_FILE=$(get_value_from_toml "entrypoint")
    detect_tex_distribution
    get_texmf_path
    install_package_file
}

main
