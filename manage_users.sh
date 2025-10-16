#!/bin/bash

HTPASSWD_FILE="auth/htpasswd"

# Check if htpasswd command is available
if ! command -v htpasswd &> /dev/null; then
    echo "Error: htpasswd command not found. Please install apache2-utils (Debian/Ubuntu) or httpd-tools (RHEL/CentOS)."
    exit 1
fi

# Check that auth folder exists
if [ ! -d "auth" ]; then
    mkdir auth
    echo "Created 'auth' directory."
fi

# Check that htpasswd file exists, if not create it
if [ ! -f "$HTPASSWD_FILE" ]; then
    touch "$HTPASSWD_FILE"
    chmod 600 "$HTPASSWD_FILE"
    echo "Created empty htpasswd file at '$HTPASSWD_FILE'."
fi

function get_user() {
    # Username can be passed as argument, if not, it will be prompted
    if [ -n "$2" ]; then
        username="$2"
    else
        read -p "Username: " username
    fi
    
    # Only validate if check_exists is true (third parameter)
    if [ "$3" = "check_exists" ]; then
        if ! grep -q "^${username}:" "$HTPASSWD_FILE" 2>/dev/null; then
            echo "Error: User '$username' not found"
            exit 1
        fi
    elif [ "$3" = "check_not_exists" ]; then
        if grep -q "^${username}:" "$HTPASSWD_FILE" 2>/dev/null; then
            echo "Error: User '$username' already exists"
            exit 1
        fi
    fi
}

function add_user() {
    get_user "$@" "check_not_exists"
    htpasswd -B "$HTPASSWD_FILE" "$username"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add user '$username'"
        exit 1
    fi
    echo "User '$username' added successfully"
}

function delete_user() {
    get_user "$@" "check_exists"
    htpasswd -D "$HTPASSWD_FILE" "$username"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to delete user '$username'"
        exit 1
    fi
    echo "User '$username' deleted successfully"
}

function list_users() {
    if [ ! -f "$HTPASSWD_FILE" ]; then
        echo "No users found (htpasswd file doesn't exist)"
        exit 0
    fi
    echo "Registry users:"
    cut -d: -f1 "$HTPASSWD_FILE"
}

function change_password() {
    get_user "$@" "check_exists"
    htpasswd -B "$HTPASSWD_FILE" "$username"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to change password for user '$username'"
        exit 1
    fi
    echo "Password for '$username' changed successfully"
}

case "$1" in
    add)
        add_user "$@"
        ;;
    delete)
        delete_user "$@"
        ;;
    list)
        list_users
        ;;
    passwd)
        change_password "$@"
        ;;
    *)
        echo "Usage: $0 {add|delete|list|passwd} [username]"
        echo ""
        echo "Commands:"
        echo "  add [username]     - Add a new user"
        echo "  delete [username]  - Delete an existing user"
        echo "  list               - List all users"
        echo "  passwd [username]  - Change user password"
        echo ""
        echo "Examples:"
        echo "  $0 add              # Interactive mode"
        echo "  $0 add john         # Direct mode"
        echo "  $0 delete john      # Delete user john"
        echo "  $0 passwd john      # Change password for john"
        exit 1
        ;;
esac

# Restart registry to apply changes only if docker container is running and user made changes
if [ "$1" = "list" ]; then
    exit 0
fi

if ! docker ps | grep -q "registry"; then
    echo "Docker registry container is not running. Please start it manually to apply changes."
    exit 0
fi

echo ""
read -p "Restart registry to apply changes? (y/n): " restart
if [ "$restart" = "y" ]; then
    docker-compose restart registry
    echo "Registry restarted"
fi