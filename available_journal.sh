available_journal(){
    sudo apt update
    # Install policykit-1 for polkit rules
    sudo apt install policykit-1
    sudo apt install polkitd pkexec

    # Create polkit rule to allow shutdown without password
    sudo mkdir -p /etc/polkit-1/rules.d

    sudo cat > /etc/polkit-1/rules.d/49-power.rules << 'EOF'
polkit.addRule(function(action, subject) {
    if (
        action.id == "org.freedesktop.login1.suspend" ||
        action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
        action.id == "org.freedesktop.login1.hibernate" ||
        action.id == "org.freedesktop.login1.reboot" ||
        action.id == "org.freedesktop.login1.power-off"
    ) {
        return polkit.Result.YES;
    }
});
EOF

    sudo systemctl restart polkit

    # Make journal files owned by 'users' group (or another group all accounts share)
    sudo chgrp -R users /var/log/journal
    sudo chmod -R g+r /var/log/journal

    # Also change the default ACL so new logs inherit it
    sudo setfacl -R -m g:users:r /var/log/journal
    sudo setfacl -d -m g:users:r /var/log/journal
}
