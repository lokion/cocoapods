#!/bin/bash

# VMSDK Version Update Script
# Updates all VMSDK podspec files to a new version
# Usage: ./update-version.sh [--force] <new_version> [source_version]
# Example: ./update-version.sh 2.2.2
# Example: ./update-version.sh 2.2.2 2.2.1
# Example: ./update-version.sh --force 2.2.2 2.2.1

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Pod names
PODS=("VMSDK_Core" "VMSDK_Legacy" "VMSDK_Wayfinding")

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Function to validate version format (semver)
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
        print_error "Invalid version format: $version"
        echo "Expected format: X.Y.Z or X.Y.Z-beta.N"
        exit 1
    fi
}

# Function to find the latest version directory for a pod
find_latest_version() {
    local pod=$1
    local latest_version=""
    local latest_dir=""

    if [ ! -d "$pod" ]; then
        print_error "Pod directory not found: $pod"
        exit 1
    fi

    # Find all version directories and get the most recently modified one
    for dir in "$pod"/*/ ; do
        if [ -d "$dir" ] && [ -f "${dir}${pod}.podspec" ]; then
            latest_dir="$dir"
            latest_version=$(basename "$dir")
        fi
    done

    if [ -z "$latest_version" ]; then
        print_error "No existing version found for $pod"
        exit 1
    fi

    echo "$latest_version"
}

# Parse arguments
FORCE=false
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --force|-f)
            FORCE=true
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            echo "Usage: $0 [--force] <new_version> [source_version]"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional arguments
set -- "${POSITIONAL_ARGS[@]}"

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 [--force] <new_version> [source_version]"
    echo "Example: $0 2.2.2"
    echo "Example: $0 2.2.2 2.2.1"
    echo "Example: $0 --force 2.2.2 2.2.1"
    exit 1
fi

NEW_VERSION=$1
SOURCE_VERSION=${2:-""}

# Strip 'v' prefix if present
NEW_VERSION=${NEW_VERSION#v}

# Validate version format
validate_version "$NEW_VERSION"

echo "======================================"
echo "VMSDK Version Update Script"
echo "======================================"
echo "Target version: $NEW_VERSION"
if [ "$FORCE" = true ]; then
    print_info "Force mode enabled - existing directories will be overwritten"
fi
echo ""

# Auto-detect source version if not provided
if [ -z "$SOURCE_VERSION" ]; then
    print_info "Auto-detecting source version..."
    SOURCE_VERSION=$(find_latest_version "${PODS[0]}")
    echo "Detected source version: $SOURCE_VERSION"
else
    SOURCE_VERSION=${SOURCE_VERSION#v}
    validate_version "$SOURCE_VERSION"
    echo "Using source version: $SOURCE_VERSION"
fi

echo ""

# Check if new version already exists
for POD in "${PODS[@]}"; do
    if [ -d "$POD/$NEW_VERSION" ]; then
        if [ "$FORCE" = true ]; then
            print_info "Removing existing directory: $POD/$NEW_VERSION"
            rm -rf "$POD/$NEW_VERSION"
        else
            print_error "Version $NEW_VERSION already exists for $POD"
            echo "Please remove existing directories, choose a different version, or use --force to overwrite."
            exit 1
        fi
    fi
done

# Process each pod
CREATED_DIRS=()
UPDATED_FILES=()

for POD in "${PODS[@]}"; do
    echo "Processing $POD..."

    SOURCE_DIR="$POD/$SOURCE_VERSION"
    TARGET_DIR="$POD/$NEW_VERSION"
    SOURCE_PODSPEC="$SOURCE_DIR/$POD.podspec"
    TARGET_PODSPEC="$TARGET_DIR/$POD.podspec"

    # Verify source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        print_error "Source directory not found: $SOURCE_DIR"
        exit 1
    fi

    if [ ! -f "$SOURCE_PODSPEC" ]; then
        print_error "Source podspec not found: $SOURCE_PODSPEC"
        exit 1
    fi

    # Create target directory
    mkdir -p "$TARGET_DIR"
    CREATED_DIRS+=("$TARGET_DIR")
    print_success "Created directory: $TARGET_DIR"

    # Copy podspec
    cp "$SOURCE_PODSPEC" "$TARGET_PODSPEC"
    print_success "Copied podspec to: $TARGET_PODSPEC"

    # Update version number (line 3)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version of sed
        sed -i '' "s/s\.version[[:space:]]*=[[:space:]]*'[^']*'/s.version          = '$NEW_VERSION'/" "$TARGET_PODSPEC"
    else
        # Linux version of sed
        sed -i "s/s\.version[[:space:]]*=[[:space:]]*'[^']*'/s.version          = '$NEW_VERSION'/" "$TARGET_PODSPEC"
    fi
    print_success "Updated version to: $NEW_VERSION"

    # Update GitHub release URL
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version of sed
        sed -i '' "s|releases/download/v[^/]*/|releases/download/v${NEW_VERSION}/|" "$TARGET_PODSPEC"
    else
        # Linux version of sed
        sed -i "s|releases/download/v[^/]*/|releases/download/v${NEW_VERSION}/|" "$TARGET_PODSPEC"
    fi
    print_success "Updated GitHub release URL to: v${NEW_VERSION}"

    UPDATED_FILES+=("$TARGET_PODSPEC")

    # Copy LICENSE.txt if it exists
    if [ -f "$SOURCE_DIR/LICENSE.txt" ]; then
        cp "$SOURCE_DIR/LICENSE.txt" "$TARGET_DIR/LICENSE.txt"
        UPDATED_FILES+=("$TARGET_DIR/LICENSE.txt")
        print_success "Copied LICENSE.txt"
    fi

    echo ""
done

# Print summary
echo "======================================"
echo "Summary"
echo "======================================"
print_success "Successfully updated VMSDK to version $NEW_VERSION"
echo ""
echo "Created directories:"
for dir in "${CREATED_DIRS[@]}"; do
    echo "  - $dir"
done
echo ""
echo "Updated files:"
for file in "${UPDATED_FILES[@]}"; do
    echo "  - $file"
done
echo ""
print_info "Next steps:"
echo "  1. Verify the changes are correct"
echo "  2. Ensure GitHub release v${NEW_VERSION} exists with the framework zips"
echo "  3. Test the podspecs locally if needed"
echo "  4. Commit the changes to git"
echo ""
print_success "Done!"
