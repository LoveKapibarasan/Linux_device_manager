disable_time(){
# Disable time change for all users

sudo mkdir -p /etc/polkit-1/localauthority/50-local.d
sudo cat >> /etc/polkit-1/localauthority/50-local.d/disable-time-change.pkla << 'EOF'
[Disable time change]
Identity=unix-user:*
Action=org.freedesktop.timedate1.set-time
ResultAny=no
ResultInactive=no
ResultActive=no
EOF

sudo cat >> /etc/polkit-1/rules.d/60-deny-time-change.rules << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.timedate1.set-time" ||
        action.id == "org.freedesktop.timedate1.set-timezone" ||
        action.id == "org.freedesktop.timedate1.set-ntp") {
        return polkit.Result.NO;
    }
});
EOF
}